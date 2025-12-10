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

  // 상태
  String _sortBy = 'latest'; // latest, likes
  String _viewMode = 'grid'; // grid, slider
  Set<String> _likedMissions = {};
  String? _selectedFilterTag;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLikedMissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 로컬에 저장된 좋아요 목록 불러오기
  Future<void> _loadLikedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_missions') ?? [];
    setState(() {
      _likedMissions = liked.toSet();
    });
  }

  // 좋아요 토글 (Firestore 업데이트 + 로컬 저장)
  Future<void> _toggleLike(String missionId) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection('missions').doc(missionId);
      final isLiked = _likedMissions.contains(missionId);

      if (isLiked) {
        await ref.update({'likes': FieldValue.increment(-1)});
        _likedMissions.remove(missionId);
      } else {
        await ref.update({'likes': FieldValue.increment(1)});
        _likedMissions.add(missionId);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_missions', _likedMissions.toList());

      setState(() {});
    } catch (e) {
      debugPrint("좋아요 토글 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleAddClick(BrowserMission bm) {
    if (widget.addedMissionIds.contains(bm.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 미션입니다.')),
      );
      return;
    }

    final colorHex =
        '#${bm.color.value.toRadixString(16).substring(2).toUpperCase()}';

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
          children:
          ['coffee', 'leaf', 'heart', 'book', 'sun', 'star'].map((tag) {
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
        stream: DatabaseService().getPublicMissionsStream(),
        builder: (context, snapshot) {
          // 1. 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          // 2. 에러 발생
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('에러: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 3. 데이터 없음
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('아직 미션이 없습니다'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await DatabaseService().uploadSampleMissions();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('샘플 미션을 추가했습니다!')),
                        );
                      }
                    },
                    child: const Text('샘플 미션 추가하기'),
                  ),
                ],
              ),
            );
          }

          // 4. 데이터 있음
          final allMissions = snapshot.data!.docs
              .map((doc) => BrowserMission.fromFirestore(doc))
              .toList();

          // 필터링 로직
          var filteredMissions = allMissions.where((m) {
            final authorName = m.author ?? '';
            final matchQuery = m.title.contains(_searchQuery) ||
                authorName.contains(_searchQuery);
            final matchTag =
                _selectedFilterTag == null || m.tag == _selectedFilterTag;
            return matchQuery && matchTag;
          }).toList();

          // 정렬 로직
          if (_sortBy == 'likes') {
            filteredMissions.sort((a, b) => b.likes.compareTo(a.likes));
          } else {
            filteredMissions.sort((a, b) {
              final aTime = a.timestamp ?? DateTime(2000);
              final bTime = b.timestamp ?? DateTime(2000);
              return bTime.compareTo(aTime);
            });
          }

          // 슬라이더 모드
          if (_viewMode == 'slider') {
            return MissionSliderView(
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