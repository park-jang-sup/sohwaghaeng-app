import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:b612_1/app_shell.dart';
import 'package:b612_1/models/mission.dart';

class HistoryTabScreen extends StatefulWidget {
  final Map<String, bool> attendanceData;
  final List<Mission> missionHistory;
  final VoidCallback onOpenProfile;
  final UserProfile userProfile;

  const HistoryTabScreen({
    super.key,
    required this.attendanceData,
    required this.missionHistory,
    required this.onOpenProfile,
    required this.userProfile,
  });

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  String _selectedCategory = 'planet'; // planet, calendar, gallery
  Color _planetColor = const Color(0xFFFF8C42); // 기본 주황색
  DateTime _selectedDate = DateTime.now();

  // --- 갤러리 필터 상태 변수 ---
  bool _isSearchOpen = false;
  String _searchQuery = "";
  String? _selectedMonthFilter;
  List<IconData> _selectedIconFilters = [];

  // [데이터] 갤러리 사진 데이터
  final List<Map<String, dynamic>> _galleryPhotos = [
    {'id': '1', 'title': '아침 스트레칭 10분', 'date': '2024-12-05', 'month': '12월', 'icon': Icons.wb_sunny_rounded, 'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400', 'color': Colors.red.shade100},
    {'id': '2', 'title': '커피 한 잔의 여유', 'date': '2024-12-04', 'month': '12월', 'icon': Icons.coffee_rounded, 'image': 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400', 'color': Colors.brown.shade100},
    {'id': '3', 'title': '산책하기', 'date': '2024-12-03', 'month': '12월', 'icon': Icons.directions_walk_rounded, 'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400', 'color': Colors.orange.shade100},
    {'id': '4', 'title': '일몰 감상', 'date': '2024-11-29', 'month': '11월', 'icon': Icons.wb_twilight_rounded, 'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400', 'color': Colors.blue.shade100},
  ];

  final List<IconData> _availableIcons = [
    Icons.wb_sunny_rounded, Icons.coffee_rounded, Icons.directions_walk_rounded,
    Icons.wb_twilight_rounded, Icons.music_note_rounded, Icons.menu_book_rounded,
    Icons.cake_rounded, Icons.self_improvement_rounded, Icons.spa_rounded,
    Icons.landscape_rounded, Icons.pedal_bike_rounded, Icons.waves_rounded,
  ];

  // [통계]
  Map<String, dynamic> get _stats {
    final total = widget.missionHistory.length;
    final now = DateTime.now();
    final thisMonth = widget.missionHistory.where((m) {
      if (m.completedAt == null) return false;
      // [수정] DateTime.parse 삭제
      final d = m.completedAt!;
      return d.year == now.year && d.month == now.month;
    }).length;

    return {
      'mostUsedIcon': '☕',
      'mostFrequentMood': '편안',
      'myMissionsCount': 12,
      'totalMissionsCompleted': total,
      'thisMonthCompleted': thisMonth,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 상단 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.userProfile.bio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      GestureDetector(
                        onTap: widget.onOpenProfile,
                        child: const Text("성향 테스트 결과 보기 >", style: TextStyle(fontSize: 12, color: Colors.orange)),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.settings_outlined), onPressed: widget.onOpenProfile),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. 카테고리 탭
            _buildCategoryTabs(),
            const SizedBox(height: 16),

            // 3. 컨텐츠 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildContent(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Column(
      children: [
        Row(
          children: [
            _buildTabItem('planet', '내 행성'),
            _buildTabItem('calendar', '달력'),
            _buildTabItem('gallery', '갤러리'),
          ],
        ),
        Stack(
          children: [
            Container(height: 2, color: Colors.grey.shade200),
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment: _selectedCategory == 'planet' ? Alignment.centerLeft : (_selectedCategory == 'calendar' ? Alignment.center : Alignment.centerRight),
              child: Container(width: MediaQuery.of(context).size.width / 3, height: 2, color: Colors.orange),
            )
          ],
        )
      ],
    );
  }

  Widget _buildTabItem(String id, String label) {
    final isSelected = _selectedCategory == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedCategory) {
      case 'planet': return _buildPlanetView();
      case 'calendar': return _buildCalendarView();
      case 'gallery': return _buildGalleryView();
      default: return Container();
    }
  }

  // ==========================================
  // [1] 내 행성 뷰
  // ==========================================
  Widget _buildPlanetView() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('이번달 아이콘', _stats['mostUsedIcon'], sub: '커피')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('나의 기분', _stats['mostFrequentMood'])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('MY 소확행', "${_stats['myMissionsCount']}개", highlight: true)),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _showTotalHistoryList,
                child: _buildStatCard('전체 완료', "${_stats['totalMissionsCompleted']}개", highlight: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0, right: 0,
                child: IconButton(icon: const Icon(Icons.palette_outlined), onPressed: _showColorPicker),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_planetColor, _planetColor.withOpacity(0.6)],
                      ),
                      boxShadow: [BoxShadow(color: _planetColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${_stats['thisMonthCompleted']}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("${DateTime.now().month}월 달성", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("총 완료한 미션", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {String? sub, bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          if (sub != null) ...[
            Text(value, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ] else ...[
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: highlight ? Colors.orange : Colors.black87)),
          ]
        ],
      ),
    );
  }

  // ==========================================
  // [2] 달력 뷰
  // ==========================================
  Widget _buildCalendarView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _selectedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
          });
          _showDayDetailModal(selectedDay);
        },
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          markerDecoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        ),
        eventLoader: (day) {
          final count = widget.missionHistory.where((m) {
            if (m.completedAt == null) return false;
            // [수정] DateTime.parse 삭제
            return isSameDay(m.completedAt!, day);
          }).length;

          String key = day.toIso8601String().split('T')[0];
          if (count > 0 || widget.attendanceData[key] == true) {
            return ['mission'];
          }
          return [];
        },
      ),
    );
  }

  // ==========================================
  // [3] 갤러리 뷰
  // ==========================================
  Widget _buildGalleryView() {
    // 1. 필터링 로직
    List<Map<String, dynamic>> filteredPhotos = _galleryPhotos.where((photo) {
      if (_searchQuery.isNotEmpty && !photo['title'].toString().contains(_searchQuery)) return false;
      if (_selectedIconFilters.isNotEmpty && !_selectedIconFilters.contains(photo['icon'])) return false;
      if (_selectedMonthFilter != null && photo['month'] != _selectedMonthFilter) return false;
      return true;
    }).toList();

    // 2. 월별 그룹화
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var photo in filteredPhotos) {
      String month = photo['month'];
      if (!groupedData.containsKey(month)) {
        groupedData[month] = [];
      }
      groupedData[month]!.add(photo);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 갤러리 헤더 (검색 및 필터 버튼)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _isSearchOpen
                    ? TextField(
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "미션 제목 검색...",
                    border: InputBorder.none,
                    hintStyle: const TextStyle(fontSize: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() {
                        _isSearchOpen = false;
                        _searchQuery = "";
                      }),
                    ),
                  ),
                )
                    : const Text("사진 인증", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              if (!_isSearchOpen)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, size: 24, color: Colors.black54),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _isSearchOpen = true),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined, size: 22, color: _selectedMonthFilter != null ? Colors.orange : Colors.black54),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _showMonthFilterDialog,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.filter_list, size: 24, color: _selectedIconFilters.isNotEmpty ? Colors.orange : Colors.black54),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _showIconFilterDialog,
                    ),
                  ],
                )
            ],
          ),
          const SizedBox(height: 24),

          // 갤러리 리스트 렌더링
          if (filteredPhotos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("조건에 맞는 사진이 없습니다.", style: TextStyle(color: Colors.grey))),
            )
          else
            ...groupedData.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final photo = entry.value[index];
                      String dayStr = photo['date'].toString().split('-').last + "일";
                      return GestureDetector(
                        onTap: () => _showPhotoDetailDialog(photo),
                        child: Container(
                          decoration: BoxDecoration(
                            color: photo['color'],
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: NetworkImage(photo['image']), fit: BoxFit.cover),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0, left: 0, right: 0, height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.5)]),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(dayStr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
        ],
      ),
    );
  }

  // ==========================================
  // [모달] 팝업 다이얼로그 함수들
  // ==========================================

  void _showPhotoDetailDialog(Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(photo['image'], width: double.infinity, height: 300, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(photo['icon'], color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Expanded(child: Text(photo['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(photo['date'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.5), child: const Icon(Icons.close, color: Colors.white, size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("월 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              ..._galleryPhotos.map((e) => e['month']).toSet().map((month) => InkWell(
                onTap: () { setState(() => _selectedMonthFilter = month); Navigator.pop(context); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: _selectedMonthFilter == month ? Colors.orange.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(month, style: TextStyle(color: _selectedMonthFilter == month ? Colors.orange : Colors.black87, fontWeight: _selectedMonthFilter == month ? FontWeight.bold : FontWeight.normal)),
                ),
              )).toList(),
              if (_selectedMonthFilter != null)
                TextButton(onPressed: () { setState(() => _selectedMonthFilter = null); Navigator.pop(context); }, child: const Text("필터 해제", style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  void _showIconFilterDialog() {
    List<IconData> tempSelected = List.from(_selectedIconFilters);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("아이콘 필터", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => Navigator.pop(context))]),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        itemCount: _availableIcons.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = tempSelected.contains(icon);
                          return GestureDetector(
                            onTap: () => setStateDialog(() => isSelected ? tempSelected.remove(icon) : tempSelected.add(icon)),
                            child: Container(
                              decoration: BoxDecoration(color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: isSelected ? Border.all(color: Colors.orange) : null),
                              child: Icon(icon, size: 24, color: isSelected ? Colors.orange : Colors.grey.shade400),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: () => setStateDialog(() => tempSelected.clear()), child: const Text("초기화", style: TextStyle(color: Colors.grey))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () { setState(() => _selectedIconFilters = tempSelected); Navigator.pop(context); },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        child: const Text("적용"),
                      ),
                    ])
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  void _showDayDetailModal(DateTime date) {
    // 3번 사진 스타일의 상세 뷰
    final dayMissions = widget.missionHistory.where((m) {
      if (m.completedAt == null) return false;
      // [수정] DateTime.parse 삭제
      return isSameDay(m.completedAt!, date);
    }).toList();

    final dateStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            if (dayMissions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("이 날 완료한 미션이 없어요.", style: TextStyle(color: Colors.grey))),
              ),

            ...dayMissions.map((mission) {
              final timeStr = mission.completedAt != null
              // [수정] DateTime.parse 삭제
                  ? DateFormat('a h:mm', 'ko_KR').format(mission.completedAt!)
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
                      child: Icon(mission.iconData, color: Colors.grey.shade700, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mission.title, style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                          if (timeStr.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
                      child: Icon(Icons.check, size: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTotalHistoryList() {
    // 전체 완료 미션 보기
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            children: [
              const Text("전체 완료한 미션", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (widget.missionHistory.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("아직 기록이 없어요."))),

              ...widget.missionHistory.reversed.map((mission) {
                final dateStr = mission.completedAt != null
                // [수정] DateTime.parse 삭제
                    ? DateFormat('yyyy.MM.dd a h:mm', 'ko_KR').format(mission.completedAt!)
                    : '';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(mission.iconData, color: Colors.orange),
                  ),
                  title: Text(mission.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(dateStr),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text("색상 변경"), content: Wrap(spacing: 10, children: [Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.pink].map((c) => GestureDetector(onTap: () { setState(() => _planetColor = c); Navigator.pop(context); }, child: CircleAvatar(backgroundColor: c))).toList())));
  }
}