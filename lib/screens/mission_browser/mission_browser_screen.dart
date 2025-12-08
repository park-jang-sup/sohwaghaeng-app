import 'package:flutter/material.dart';
import 'package:b612_1/models/mission.dart'; // 메인 미션 모델
import 'dart:math';

// 탐색 탭 전용 미션 모델 (작성자, 좋아요 등 포함)
class BrowserMission {
  final String id;
  final String title;
  final String description;
  final String tag; // iconType
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
  List<BrowserMission> _allMissions = [];
  List<BrowserMission> _filteredMissions = [];

  // 상태
  String _sortBy = 'latest'; // latest, likes, photos
  String _viewMode = 'grid'; // grid, slider
  int _currentSlideIndex = 0;
  Set<String> _likedMissions = {};
  String? _selectedFilterTag;

  @override
  void initState() {
    super.initState();
    _allMissions = _generateSampleMissions();
    _filteredMissions = List.from(_allMissions);
  }

  // 샘플 데이터 생성
  List<BrowserMission> _generateSampleMissions() {
    // React 코드의 데이터 기반
    final rawData = [
      {'title': '아침에 따뜻한 차 한 잔', 'author': '차러버', 'tag': 'coffee', 'icon': Icons.coffee_rounded, 'color': 0xFFFFC6A5, 'likes': 234},
      {'title': '점심 후 10분 산책', 'author': '산책왕', 'tag': 'leaf', 'icon': Icons.eco_rounded, 'color': 0xFFCAFFBF, 'likes': 189},
      {'title': '하루에 한 번 웃기', 'author': '웃음천사', 'tag': 'heart', 'icon': Icons.favorite_rounded, 'color': 0xFFFFD6E8, 'likes': 567},
      {'title': '책 10페이지 읽기', 'author': '독서광', 'tag': 'book', 'icon': Icons.menu_book_rounded, 'color': 0xFFA0C4FF, 'likes': 412},
      {'title': '창문 열고 환기하기', 'author': '환기마스터', 'tag': 'sun', 'icon': Icons.wb_sunny_rounded, 'color': 0xFFFFD6A5, 'likes': 156},
      {'title': '감사 일기 쓰기', 'author': '감사러', 'tag': 'star', 'icon': Icons.star_rounded, 'color': 0xFFFDFD96, 'likes': 891},
    ];

    return List.generate(rawData.length, (index) {
      final m = rawData[index];
      return BrowserMission(
        id: 'browse-$index',
        title: m['title'] as String,
        description: '설명...',
        tag: m['tag'] as String,
        icon: m['icon'] as IconData,
        author: m['author'] as String,
        likes: m['likes'] as int,
        color: Color(m['color'] as int),
        addedCount: Random().nextInt(500) + 50,
        photos: [], // 실제 URL 대신 빈 리스트
      );
    });
  }

  void _filterMissions(String query) {
    setState(() {
      _filteredMissions = _allMissions.where((m) {
        final matchQuery = m.title.contains(query) || m.author.contains(query);
        final matchTag = _selectedFilterTag == null || m.tag == _selectedFilterTag;
        return matchQuery && matchTag;
      }).toList();
      _sortMissions();
    });
  }

  void _sortMissions() {
    setState(() {
      if (_sortBy == 'likes') {
        _filteredMissions.sort((a, b) => b.likes.compareTo(a.likes));
      } else {
        // latest (기본 순서 유지)
        _filteredMissions = _allMissions.where((m) => _filteredMissions.contains(m)).toList();
      }
    });
  }

  void _handleAddClick(BrowserMission bm) {
    if (widget.addedMissionIds.contains(bm.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 추가된 미션입니다.')));
      return;
    }

    final newMission = Mission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: bm.title,
      description: bm.description,
      tag: bm.tag,
      icon: bm.tag, // 태그를 아이콘 ID로 사용
      source: 'imported',
      // color 필드 변환 필요 (Hex String)
      color: '#${bm.color.value.toRadixString(16).substring(2).toUpperCase()}',
    );

    widget.onAddMission(newMission, bm.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED), // Orange-50
      body: CustomScrollView(
        slivers: [
          // 1. 상단 검색바
          SliverAppBar(
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
                onChanged: _filterMissions,
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
                    _selectedFilterTag = null;
                    _filteredMissions = List.from(_allMissions);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: _selectedFilterTag != null ? Colors.orange : Colors.grey.shade600),
                onPressed: _showFilterDialog,
              ),
            ],
          ),

          // 2. 추천 섹션 (좋아요 TOP)
          SliverToBoxAdapter(
            child: _buildFeaturedSection(),
          ),

          // 3. 리스트 헤더 (보기 방식, 정렬)
          SliverToBoxAdapter(
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
                        _sortMissions();
                      });
                    },
                    child: Text(_sortBy == 'latest' ? '최신순' : '좋아요순',
                        style: const TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ),

          // 4. 미션 리스트 (Grid or Slider)
          _viewMode == 'grid'
              ? _buildGridList()
              : _buildSliderList(),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    // 좋아요 상위 2개
    final topMissions = List.from(_allMissions)..sort((a, b) => b.likes.compareTo(a.likes));
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
              CircleAvatar(backgroundColor: Colors.orange, radius: 14, child: Icon(Icons.favorite, size: 16, color: Colors.white)),
              SizedBox(width: 8),
              Text("좋아요를 많이 받은 SHH", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...featured.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
                  child: Icon(m.icon, color: Colors.grey.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w500))),
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

  Widget _buildGridList() {
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
            final mission = _filteredMissions[index];
            return _buildMissionGridCard(mission);
          },
          childCount: _filteredMissions.length,
        ),
      ),
    );
  }

  Widget _buildSliderList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: _filteredMissions.length,
          onPageChanged: (idx) => setState(() => _currentSlideIndex = idx),
          itemBuilder: (context, index) {
            final mission = _filteredMissions[index];
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
          Text(m.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
    // 간단한 필터 다이얼로그 예시
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
                  _filterMissions(_searchController.text);
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