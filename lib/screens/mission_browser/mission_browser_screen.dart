import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/browser_mission.dart';
import 'package:b612_1/widgets/mission_grid_card.dart';
import 'package:b612_1/widgets/mission_detail_card.dart';

enum BrowserView { grid, detail }

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
  String _searchQuery = '';
  List<BrowserMission> _availableMissions = [];
  List<BrowserMission> _filteredMissions = [];

  bool _showSearch = false;
  BrowserView _currentView = BrowserView.grid;
  int _selectedMissionIndex = 0;

  Set<String> _likedMissions = <String>{};
  Map<String, int> _localLikes = {};

  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeMissions();
    _searchController.addListener(_handleSearch);
  }

  void _initializeMissions() {
    final initialLikes = <String, int>{};
    for (var mission in allSampleMissions) {
      initialLikes[mission.id] = mission.likes;
    }

    final available = allSampleMissions
        .where((m) => !widget.addedMissionIds.contains(m.id))
        .toList();

    setState(() {
      _localLikes = initialLikes;
      _availableMissions = available;
      _filteredMissions = available;
    });
  }

  @override
  void didUpdateWidget(covariant MissionBrowserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.addedMissionIds != oldWidget.addedMissionIds) {
      final available = _availableMissions
          .where((m) => !widget.addedMissionIds.contains(m.id))
          .toList();
      setState(() {
        _availableMissions = available;
        _filteredMissions = available.where((m) =>
        m.title.toLowerCase().contains(_searchQuery) ||
            m.description.toLowerCase().contains(_searchQuery) ||
            m.tag.toLowerCase().contains(_searchQuery)).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredMissions = _availableMissions.where((mission) =>
      mission.title.toLowerCase().contains(query) ||
          mission.description.toLowerCase().contains(query) ||
          mission.tag.toLowerCase().contains(query)).toList();

      if (_currentView == BrowserView.detail) {
        _currentView = BrowserView.grid;
        _selectedMissionIndex = 0;
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));

    final currentIds = _availableMissions.map((m) => m.id).toSet();
    final remaining = allSampleMissions
        .where((m) =>
    !widget.addedMissionIds.contains(m.id) && !currentIds.contains(m.id))
        .toList();

    List<BrowserMission> newMissions = [];
    if (remaining.isNotEmpty) {
      remaining.shuffle();
      newMissions = remaining.take(4).toList();
    } else {
      _availableMissions.shuffle();
      newMissions = _availableMissions.take(12).toList();
    }

    setState(() {
      if (remaining.isNotEmpty) {
        _availableMissions =
            [...newMissions, ..._availableMissions].take(12).toList();
      } else {
        _availableMissions = newMissions;
      }
      _handleSearch();
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('새로운 미션을 불러왔습니다!'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _handleAddMission(BrowserMission mission) {
    widget.onAddMission(
      Mission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: mission.title,
        description: mission.description,
        tag: mission.tag,
        icon: mission.icon,
        completed: false,
      ),
      mission.id,
    );

    final newAvailable =
    _availableMissions.where((m) => m.id != mission.id).toList();
    final newFiltered =
    _filteredMissions.where((m) => m.id != mission.id).toList();

    setState(() {
      _availableMissions = newAvailable;
      _filteredMissions = newFiltered;
    });

    if (_currentView == BrowserView.detail) {
      if (newFiltered.isEmpty) {
        _handleBackToGrid();
      } else {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  void _handleToggleLike(String missionId) {
    setState(() {
      final newLikedMissions = Set<String>.from(_likedMissions);
      final newLocalLikes = Map<String, int>.from(_localLikes);

      if (newLikedMissions.contains(missionId)) {
        newLikedMissions.remove(missionId);
        newLocalLikes[missionId] = (newLocalLikes[missionId] ?? 1) - 1;
      } else {
        newLikedMissions.add(missionId);
        newLocalLikes[missionId] = (newLocalLikes[missionId] ?? 0) + 1;
      }

      _likedMissions = newLikedMissions;
      _localLikes = newLocalLikes;
    });
  }

  void _handleMissionSelect(int index) {
    setState(() {
      _currentView = BrowserView.detail;
      _selectedMissionIndex = index;
    });
  }

  void _handleBackToGrid() {
    setState(() {
      _currentView = BrowserView.grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _currentView == BrowserView.grid
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: _buildGridView(context),
      secondChild: _buildDetailView(context),
    );
  }

  // [수정 1] Scaffold -> Container로 변경 (중첩 방지)
  Widget _buildGridView(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF7ED),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.grey.shade600),
                        onPressed: _handleRefresh,
                        tooltip: '새로고침',
                      ),
                      Text(
                        '오늘의 미션 둘러보기',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.grey.shade600),
                        onPressed: () =>
                            setState(() => _showSearch = !_showSearch),
                        tooltip: '검색',
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showSearch ? 80.0 : 0.0,
                  padding: _showSearch
                      ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                      : EdgeInsets.zero,
                  child: OverflowBox(
                    minHeight: 0.0,
                    maxHeight: 80.0,
                    child: _showSearch
                        ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "어떤 미션을 찾고 있나요?",
                        prefixIcon: Icon(Icons.search,
                            size: 20.0, color: Colors.grey.shade400),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close,
                              size: 20.0, color: Colors.grey.shade400),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _showSearch = false);
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color:
                              Colors.grey.shade200.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0),
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
              ),

              _filteredMissions.isEmpty
                  ? SliverToBoxAdapter(
                child: _buildEmptyState(),
              )
                  : SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final mission = _filteredMissions[index];
                      return MissionGridCard(
                        mission: mission,
                        isLiked: _likedMissions.contains(mission.id),
                        likeCount: _localLikes[mission.id] ?? 0,
                        onTap: () => _handleMissionSelect(index),
                        onLike: () => _handleToggleLike(mission.id),
                      );
                    },
                    childCount: _filteredMissions.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [수정 2] Scaffold -> Container 변경 및 Expanded 제거로 무한 높이 오류 해결
  Widget _buildDetailView(BuildContext context) {
    if (_filteredMissions.isEmpty) {
      return _buildGridView(context);
    }

    return Container(
      color: const Color(0xFFFFF7ED),
      child: SafeArea(
        // [수정 3] SingleChildScrollView와 Column(MainAxisSize.min) 조합 사용
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.grey.shade600),
                      onPressed: _handleBackToGrid,
                      tooltip: '뒤로가기',
                    ),
                    Text(
                      '미션 상세 (${_selectedMissionIndex + 1}/${_filteredMissions.length})',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 48.0),
                  ],
                ),
              ),

              // [수정 4] Expanded 제거! (여기가 오류의 핵심 원인이었습니다)
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _filteredMissions.length,
                itemBuilder: (context, index, realIndex) {
                  final mission = _filteredMissions[index];
                  return MissionDetailCard(
                    mission: mission,
                    isLiked: _likedMissions.contains(mission.id),
                    likeCount: _localLikes[mission.id] ?? 0,
                    onAdd: () => _handleAddMission(mission),
                    onLike: () => _handleToggleLike(mission.id),
                  );
                },
                options: CarouselOptions(
                  height: 420.0, // 고정 높이 사용
                  initialPage: _selectedMissionIndex,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _selectedMissionIndex = index;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_filteredMissions.length, (index) {
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _selectedMissionIndex == index ? 32.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: _selectedMissionIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side:
        BorderSide(color: Colors.grey.shade300.withOpacity(0.5), width: 2.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48.0, color: Colors.grey.shade400),
            const SizedBox(height: 16.0),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 16.0, color: Colors.grey.shade500),
            ),
            Text(
              '다른 키워드로 검색해보세요',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}