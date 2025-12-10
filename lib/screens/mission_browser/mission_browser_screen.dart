import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/browser_mission.dart';
import 'package:b612_1/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _currentSlideIndex = 0;
  Set<String> _likedMissions = {};
  String? _selectedFilterTag;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLikedMissions();
  }

  // ✅ 로컬에 저장된 좋아요 목록 불러오기
  Future<void> _loadLikedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_missions') ?? [];
    setState(() {
      _likedMissions = liked.toSet();
    });
  }

  // ✅ 좋아요 토글 (Firestore 업데이트 + 로컬 저장)
  Future<void> _toggleLike(String missionId) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection('missions').doc(missionId);
      final isLiked = _likedMissions.contains(missionId);

      if (isLiked) {
        // 좋아요 취소
        await ref.update({'likes': FieldValue.increment(-1)});
        _likedMissions.remove(missionId);
      } else {
        // 좋아요 추가
        await ref.update({'likes': FieldValue.increment(1)});
        _likedMissions.add(missionId);
      }

      // 로컬에 저장
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

    // BrowserMission -> Mission 변환
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // ✅ 정렬 로직 개선
          if (_sortBy == 'likes') {
            filteredMissions.sort((a, b) => b.likes.compareTo(a.likes));
          } else {
            // 최신순 정렬 (timestamp 기준)
            filteredMissions.sort((a, b) {
              final aTime = a.timestamp ?? DateTime(2000);
              final bTime = b.timestamp ?? DateTime(2000);
              return bTime.compareTo(aTime);
            });
          }

          return CustomScrollView(
            slivers: [
              _buildSearchBar(),
              SliverToBoxAdapter(
                child: _buildFeaturedSection(allMissions),
              ),
              _buildListHeader(),
              _viewMode == 'grid'
                  ? _buildGridList(filteredMissions)
                  : _buildSliderList(filteredMissions),
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 14,
                child: Icon(Icons.favorite, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                "좋아요를 많이 받은 SHH",
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...featured.map((m) => _buildFeaturedCard(m)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BrowserMission m) {
    final isLiked = _likedMissions.contains(m.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
            child: Icon(m.icon, color: Colors.grey.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              m.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // ✅ 좋아요 버튼 (탭 가능)
          GestureDetector(
            onTap: () => _toggleLike(m.id),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 14,
                  color: isLiked ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  "${m.likes}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isLiked ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
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
                _buildViewModeBtn(Icons.grid_view_rounded, 'grid'),
                const SizedBox(width: 8),
                _buildViewModeBtn(Icons.view_carousel_rounded, 'slider'),
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
            return _buildMissionGridCard(mission);
          },
          childCount: missions.length,
        ),
      ),
    );
  }

  // ✅ 슬라이더 + 인디케이터 추가
  Widget _buildSliderList(List<BrowserMission> missions) {
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

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 320, // ✅ 높이 증가 (300 → 320)
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: missions.length,
              onPageChanged: (idx) => setState(() => _currentSlideIndex = idx),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: _buildMissionSliderCard(mission),
                );
              },
            ),
          ),
          // ✅ 페이지 인디케이터
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                missions.length > 10 ? 10 : missions.length, // 최대 10개만 표시
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentSlideIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentSlideIndex
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionGridCard(BrowserMission m) {
    final isAdded = widget.addedMissionIds.contains(m.id);
    final isLiked = _likedMissions.contains(m.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: m.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(m.icon, size: 40, color: Colors.grey.shade700),
          const SizedBox(height: 12),
          Text(
            m.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 좋아요 버튼 (탭 가능)
              GestureDetector(
                onTap: () => _toggleLike(m.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 12,
                      color: isLiked ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${m.likes}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isLiked ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _handleAddClick(m),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: isAdded ? Colors.grey : Colors.green,
                  child: Icon(
                    isAdded ? Icons.check : Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ✅ 오버플로우 수정: 크기 조정
  Widget _buildMissionSliderCard(BrowserMission m) {
    final isAdded = widget.addedMissionIds.contains(m.id);
    final isLiked = _likedMissions.contains(m.id);

    return Container(
      padding: const EdgeInsets.all(20), // ✅ 패딩 축소 (24 → 20)
      decoration: BoxDecoration(
        color: m.color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ 최소 크기로 설정
        children: [
          Icon(m.icon, size: 48, color: Colors.grey.shade700), // ✅ 아이콘 축소 (60 → 48)
          const SizedBox(height: 12), // ✅ 간격 축소 (20 → 12)
          Text(
            m.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // ✅ 폰트 축소 (20 → 18)
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // ✅ 간격 축소 (8 → 4)
          Text(
            "by ${m.author ?? '익명'}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 8), // ✅ 간격 축소 (12 → 8)
          // ✅ 좋아요 버튼
          GestureDetector(
            onTap: () => _toggleLike(m.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // ✅ 패딩 축소
              decoration: BoxDecoration(
                color: isLiked ? Colors.orange.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 14, // ✅ 아이콘 축소 (16 → 14)
                    color: isLiked ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 4), // ✅ 간격 축소 (6 → 4)
                  Text(
                    "${m.likes}",
                    style: TextStyle(
                      color: isLiked ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12), // ✅ 간격 축소 (16 → 12)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAdded ? null : () => _handleAddClick(m),
              icon: Icon(isAdded ? Icons.check : Icons.add, size: 18),
              label: Text(
                isAdded ? '추가됨' : '내 미션에 추가',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdded ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // ✅ 패딩 축소
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildViewModeBtn(IconData icon, String mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _viewMode = mode;
        _currentSlideIndex = 0; // 모드 변경 시 인덱스 초기화
      }),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade300 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
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
}