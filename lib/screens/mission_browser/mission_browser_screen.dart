import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/services/database_service.dart';
import 'dart:math';

// 탐색 탭 전용 미션 모델
class BrowserMission {
  final String id;
  final String title;
  final String description;
  final String tag;
  final IconData icon;
  final String author;
  final int likes;
  final Color color;
  final int addedCount;
  final List<String> photos;

  BrowserMission({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
    required this.author,
    required this.likes,
    required this.color,
    required this.addedCount,
    required this.photos,
  });

  // ✅ Firestore 문서에서 BrowserMission 생성
  factory BrowserMission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrowserMission(
      id: doc.id,
      title: data['title'] ?? '제목 없음',
      description: data['description'] ?? '설명 없음',
      tag: data['tag'] ?? 'star',
      icon: IconData(data['icon_code'] ?? Icons.star.codePoint, fontFamily: 'MaterialIcons'),
      author: data['author'] ?? '익명',
      likes: data['likes'] ?? 0,
      color: _getColorFromTag(data['tag']),
      addedCount: Random().nextInt(500) + 50,
      photos: [],
    );
  }

  static Color _getColorFromTag(String? tag) {
    switch (tag) {
      case 'coffee':
        return const Color(0xFFFFC6A5);
      case 'leaf':
        return const Color(0xFFCAFFBF);
      case 'heart':
        return const Color(0xFFFFD6E8);
      case 'book':
        return const Color(0xFFA0C4FF);
      case 'sun':
        return const Color(0xFFFFD6A5);
      case 'star':
        return const Color(0xFFFDFD96);
      default:
        return const Color(0xFFFFE4B5);
    }
  }
}

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

  void _handleAddClick(BrowserMission bm) {
    if (widget.addedMissionIds.contains(bm.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 미션입니다.')),
      );
      return;
    }

    final newMission = Mission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: bm.title,
      description: bm.description,
      tag: bm.tag,
      icon: bm.tag,
      source: 'imported',
      color: '#${bm.color.value.toRadixString(16).substring(2).toUpperCase()}',
    );

    widget.onAddMission(newMission, bm.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${bm.title}을(를) 추가했습니다!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getMissionsStream(), // ✅ 실시간 구독!
        builder: (context, snapshot) {
          // 1. 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('샘플 미션을 추가했습니다!')),
                      );
                    },
                    child: const Text('샘플 미션 추가하기'),
                  ),
                ],
              ),
            );
          }

          // 4. ✅ 데이터 있음 - 실시간 업데이트!
          final allMissions = snapshot.data!.docs
              .map((doc) => BrowserMission.fromFirestore(doc))
              .toList();

          // 필터링 및 정렬
          var filteredMissions = allMissions.where((m) {
            final matchQuery = m.title.contains(_searchQuery) ||
                m.author.contains(_searchQuery);
            final matchTag = _selectedFilterTag == null || m.tag == _selectedFilterTag;
            return matchQuery && matchTag;
          }).toList();

          if (_sortBy == 'likes') {
            filteredMissions.sort((a, b) => b.likes.compareTo(a.likes));
          }

          return CustomScrollView(
            slivers: [
              // 1. 상단 검색바
              _buildSearchBar(),

              // 2. 추천 섹션
              SliverToBoxAdapter(
                child: _buildFeaturedSection(allMissions),
              ),

              // 3. 리스트 헤더
              _buildListHeader(),

              // 4. 미션 리스트
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
            color: _selectedFilterTag != null ? Colors.orange : Colors.grey.shade600,
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
            children: const [
              CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 14,
                child: Icon(Icons.favorite, size: 16, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                "좋아요를 많이 받은 SHH",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...featured.map((m) => Container(
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
                Icon(Icons.thumb_up_rounded, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text("${m.likes}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )).toList(),
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
              child: Text(
                _sortBy == 'latest' ? '최신순' : '좋아요순',
                style: const TextStyle(color: Colors.grey),
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
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: missions.length,
          onPageChanged: (idx) => setState(() => _currentSlideIndex = idx),
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: _buildMissionSliderCard(mission),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMissionGridCard(BrowserMission m) {
    final isAdded = widget.addedMissionIds.contains(m.id);

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
              Row(
                children: [
                  const Icon(Icons.thumb_up, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text("${m.likes}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              GestureDetector(
                onTap: () => _handleAddClick(m),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: isAdded ? Colors.grey : Colors.green,
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMissionSliderCard(BrowserMission m) {
    final isAdded = widget.addedMissionIds.contains(m.id);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: m.color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(m.icon, size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text(
            m.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text("by ${m.author}", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isAdded ? null : () => _handleAddClick(m),
            icon: const Icon(Icons.add),
            label: Text(isAdded ? '추가됨' : '내 미션에 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildViewModeBtn(IconData icon, String mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade300 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey),
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
          children: ['coffee', 'leaf', 'heart', 'book', 'sun', 'star'].map((tag) {
            return ChoiceChip(
              label: Text(tag),
              selected: _selectedFilterTag == tag,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterTag = selected ? tag : null;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}