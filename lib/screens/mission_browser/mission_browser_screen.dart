import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/browser_mission.dart';
import 'package:b612_1/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mission_browser_widgets.dart';
import 'mission_slider_view.dart';

class MissionBrowserScreen extends StatefulWidget {
  final Function(Mission, String?) onAddMission;
  final Set<String> addedMissionIds;

  const MissionBrowserScreen({
    super.key,
    required this.onAddMission,
    required this.addedMissionIds,
  });

  @override
  State<MissionBrowserScreen> createState() => _MissionBrowserScreenState();
}

class _MissionBrowserScreenState extends State<MissionBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 상태 변수들
  String _sortBy = 'latest';
  String _viewMode = 'grid';
  Set<String> _likedMissions = {};
  String? _selectedFilterTag;
  String _searchQuery = '';
  bool _isLoading = false;

  // ✅ [수정 1] 컨트롤러와 스트림을 변수로 선언
  late PageController _pageController;
  late Stream<QuerySnapshot> _missionsStream; // 스트림을 잡아둘 변수

  @override
  void initState() {
    super.initState();
    _loadLikedMissions();

    // ✅ [수정 2] 한 번만 생성되도록 initState에 배치
    _pageController = PageController(viewportFraction: 0.85);
    _missionsStream = DatabaseService().getPublicMissionsStream(); // 스트림 고정
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ... (기존 _loadLikedMissions, _toggleLike, _handleAddClick, _showFilterDialog 코드는 그대로 유지) ...
  // (스크롤 압박을 줄이기 위해 이 부분은 기존 코드를 그대로 사용하세요)
  Future<void> _loadLikedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_missions') ?? [];
    setState(() {
      _likedMissions = liked.toSet();
    });
  }

  Future<void> _toggleLike(String missionId) async {
    // 로딩 인디케이터(_isLoading)를 사용하면 화면이 멈칫할 수 있으니
    // Firestore 업데이트는 백그라운드에서 하되, UI 갱신은 Stream이 알아서 하게 두는 게 좋습니다.
    if (_isLoading) return;

    // setState(() => _isLoading = true); // ⚠️ 이 부분을 주석 처리하면 더 부드럽습니다.

    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection('missions').doc(missionId);
      final isLiked = _likedMissions.contains(missionId);

      // 로컬 상태 즉시 반영 (반응속도 향상)
      setState(() {
        if (isLiked) {
          _likedMissions.remove(missionId);
        } else {
          _likedMissions.add(missionId);
        }
      });

      // Firestore 업데이트
      if (isLiked) {
        await ref.update({'likes': FieldValue.increment(-1)});
      } else {
        await ref.update({'likes': FieldValue.increment(1)});
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_missions', _likedMissions.toList());

    } catch (e) {
      debugPrint("좋아요 토글 에러: $e");
      // 에러 시 롤백 로직이 필요할 수 있음
    } finally {
      // setState(() => _isLoading = false); // ⚠️ 주석 처리
    }
  }

  void _handleAddClick(BrowserMission bm) {
    if (widget.addedMissionIds.contains(bm.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 미션입니다.')),
      );
      return;
    }

    final colorHex = '#${bm.color.value.toRadixString(16).substring(2).toUpperCase()}';
    final newMission = Mission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: bm.title,
      description: bm.description,
      tag: bm.tag,
      icon: bm.tag,
      source: 'imported',
      color: colorHex,
    );

    widget.onAddMission(newMission, bm.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${bm.title}을(를) 추가했습니다!')),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태그 필터'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['coffee', 'leaf', 'heart', 'book', 'sun', 'star'].map((tag) {
            return ChoiceChip(
              label: Text(tag),
              selected: _selectedFilterTag == tag,
              selectedColor: Colors.orange.shade200,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterTag = selected ? tag : null;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedFilterTag = null);
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ [수정 3] 여기서 함수를 호출하지 않고, initState에서 만든 변수를 사용
        stream: _missionsStream,
        builder: (context, snapshot) {
          // 1. 로딩 중 (초기 데이터 없을 때만)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          // 2. 에러
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }

          // 3. 데이터 없음
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('아직 미션이 없습니다'));
          }

          final allMissions = snapshot.data!.docs
              .map((doc) => BrowserMission.fromFirestore(doc))
              .toList();

          // 필터링
          var filteredMissions = allMissions.where((m) {
            final authorName = m.author ?? '';
            final matchQuery = m.title.contains(_searchQuery) ||
                authorName.contains(_searchQuery);
            final matchTag =
                _selectedFilterTag == null || m.tag == _selectedFilterTag;
            return matchQuery && matchTag;
          }).toList();

          // 정렬
          if (_sortBy == 'likes') {
            filteredMissions.sort((a, b) => b.likes.compareTo(a.likes));
          } else {
            filteredMissions.sort((a, b) {
              final aTime = a.timestamp ?? DateTime(2000);
              final bTime = b.timestamp ?? DateTime(2000);
              return bTime.compareTo(aTime);
            });
          }

          // 화면 모드에 따른 분기
          if (_viewMode == 'slider') {
            return MissionSliderView(
              // ✅ 부모가 관리하는 컨트롤러 전달
              pageController: _pageController,
              allMissions: allMissions,
              filteredMissions: filteredMissions,
              addedMissionIds: widget.addedMissionIds,
              likedMissions: _likedMissions,
              sortBy: _sortBy,
              viewMode: _viewMode,
              selectedFilterTag: _selectedFilterTag,
              searchQuery: _searchQuery,
              searchController: _searchController,
              onAddMission: _handleAddClick,
              onToggleLike: _toggleLike,
              onSortChanged: (sort) => setState(() => _sortBy = sort),
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
              onSearchChanged: (query) => setState(() => _searchQuery = query),
              onRefresh: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedFilterTag = null;
                });
              },
              onFilterTap: _showFilterDialog,
            );
          }

          // 그리드 모드
          return CustomScrollView(
            slivers: [
              _buildSearchBar(),
              SliverToBoxAdapter(
                child: _buildFeaturedSection(allMissions),
              ),
              _buildListHeader(),
              _buildGridList(filteredMissions),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
    );
  }

  // (이하 그리드 뷰용 서브 위젯들: _buildSearchBar 등 기존 코드 유지)
  // ...
  Widget _buildSearchBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: '소확행을 검색하세요',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
              _selectedFilterTag = null;
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: _selectedFilterTag != null
                ? Colors.orange
                : Colors.grey.shade600,
          ),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(List<BrowserMission> allMissions) {
    if (allMissions.isEmpty) return const SizedBox.shrink();

    final topMissions = List<BrowserMission>.from(allMissions)
      ..sort((a, b) => b.likes.compareTo(a.likes));
    final featured = topMissions.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange.shade50, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeaturedSectionHeader(),
          const SizedBox(height: 12),
          ...featured.map((m) => FeaturedMissionCard(
            mission: m,
            isLiked: _likedMissions.contains(m.id),
            onLikeTap: () => _toggleLike(m.id),
          )),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ViewModeButton(
                  icon: Icons.grid_view_rounded,
                  mode: 'grid',
                  currentMode: _viewMode,
                  onModeChanged: (mode) => setState(() => _viewMode = mode),
                ),
                const SizedBox(width: 8),
                ViewModeButton(
                  icon: Icons.view_carousel_rounded,
                  mode: 'slider',
                  currentMode: _viewMode,
                  onModeChanged: (mode) => setState(() => _viewMode = mode),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _sortBy = _sortBy == 'latest' ? 'likes' : 'latest';
                });
              },
              child: Row(
                children: [
                  Icon(
                    _sortBy == 'latest' ? Icons.access_time : Icons.favorite,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortBy == 'latest' ? '최신순' : '좋아요순',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridList(List<BrowserMission> missions) {
    if (missions.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              '검색 결과가 없습니다',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final mission = missions[index];
            return MissionGridCard(
              mission: mission,
              isAdded: widget.addedMissionIds.contains(mission.id),
              isLiked: _likedMissions.contains(mission.id),
              onAddTap: () => _handleAddClick(mission),
              onLikeTap: () => _toggleLike(mission.id),
            );
          },
          childCount: missions.length,
        ),
      ),
    );
  }
}