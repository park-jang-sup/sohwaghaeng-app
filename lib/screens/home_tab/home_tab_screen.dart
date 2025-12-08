import 'package:flutter/material.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/widgets/mission_card.dart';
import 'package:b612_1/widgets/modals/create_mission_modal.dart';

class HomeTabScreen extends StatefulWidget {
  final List<Mission> missions;
  final Function(String) onToggleMission;
  final Function(String title, String icon, String color, bool isPublic, String? time) onAddMission;
  final Function(String) onDeleteMission;
  final Function(String, String?) onAddPhoto;

  // [신규] 상위로 이벤트를 전달하기 위한 콜백 추가
  final VoidCallback onFinishDay;   // 하루 마무리
  final VoidCallback onSortMissions; // 미션 정렬
  final VoidCallback onResetMissions; // 완료 미션 초기화

  final String? currentMood;
  final int streakDays;

  const HomeTabScreen({
    super.key,
    required this.missions,
    required this.onToggleMission,
    required this.onAddMission,
    required this.onDeleteMission,
    required this.onAddPhoto,
    required this.onFinishDay,    // 추가
    required this.onSortMissions, // 추가
    required this.onResetMissions,// 추가
    this.currentMood,
    required this.streakDays,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  DateTime _selectedWeekDate = DateTime.now();
  String _filterTab = 'all';

  // 날짜 포맷팅
  String get _dateString => "${_selectedWeekDate.month}월 ${_selectedWeekDate.day}일";
  String get _dayOfWeek => ['월', '화', '수', '목', '금', '토', '일'][_selectedWeekDate.weekday - 1];

  // 주간 날짜 계산
  List<DateTime> _getWeekDates() {
    final current = _selectedWeekDate;
    final currentWeekday = current.weekday == 7 ? 0 : current.weekday;
    final sunday = current.subtract(Duration(days: currentWeekday));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  double _getCompletionRate(DateTime date) {
    if (date.day != DateTime.now().day) return 0.0;
    if (widget.missions.isEmpty) return 0.0;
    final completed = widget.missions.where((m) => m.completed).length;
    return (completed / widget.missions.length);
  }

  List<Mission> get _filteredMissions {
    // 탭 필터링
    List<Mission> result = widget.missions;
    if (_filterTab == 'mine') {
      result = widget.missions.where((m) => m.source == 'mine').toList();
    } else if (_filterTab == 'imported') {
      result = widget.missions.where((m) => m.source == 'imported').toList();
    }
    return result;
  }

  // [신규] 하루 마무리 다이얼로그 표시
  void _showFinishDialog() {
    final now = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 닫기 버튼 (우상단)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
                ),
              ),
              const Text(
                "오늘 하루 마무리",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "${now.month}월 ${now.day}일을 마치겠어요?",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("아니요", style: TextStyle(color: Colors.grey.shade700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onFinishDay(); // 부모 콜백 호출
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00), // 오렌지색
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text("네", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final todayRate = _getCompletionRate(_selectedWeekDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 상단 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_dateString, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("$_dayOfWeek요일", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCircleBtn(Icons.add, Colors.orange, Colors.white, () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => CreateMissionModal(onCreateMission: widget.onAddMission),
                            );
                          }),
                          const SizedBox(width: 8),
                          _buildCircleBtn(Icons.share, Colors.grey.shade100, Colors.grey.shade700, () {}),
                          const SizedBox(width: 8),

                          // [수정] 더보기 메뉴 버튼 (PopupMenuButton)
                          PopupMenuButton<String>(
                            offset: const Offset(0, 45), // 메뉴 위치 조정
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 4,
                            onSelected: (value) {
                              if (value == 'sort') widget.onSortMissions();
                              if (value == 'reset') widget.onResetMissions();
                              // 'alarm', 'template'은 추후 구현
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              _buildPopupItem('sort', '미션 정렬'),
                              _buildPopupItem('alarm', '알림 설정'),
                              _buildPopupItem('template', '미션 템플릿'),
                              const PopupMenuDivider(), // 구분선
                              _buildPopupItem('reset', '완료 미션 초기화'),
                            ],
                            // 아이콘 버튼 모양 유지
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekDates.map((date) => _buildDayItem(date)).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. 메인 컨텐츠
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽: 게이지
                Column(
                  children: [
                    if (widget.currentMood != null) ...[
                      const Text("기분", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(widget.currentMood!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                    ],
                    Container(
                      width: 50, height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25))),
                          FractionallySizedBox(
                            heightFactor: todayRate == 0 ? 0.05 : todayRate,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.orange.shade300, Colors.orange.shade500],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                "${(todayRate * 100).toInt()}%",
                                style: TextStyle(fontWeight: FontWeight.bold, color: todayRate > 0.5 ? Colors.white : Colors.grey.shade700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // [수정] 깃발 버튼 - 다이얼로그 연결
                    GestureDetector(
                      onTap: _showFinishDialog,
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.flag, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // 오른쪽: 리스트
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildFilterTab('all', '전체'),
                            _buildFilterTab('mine', 'MY'),
                            _buildFilterTab('imported', '탐색'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 리스트 렌더링
                      if (_filteredMissions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Icon(Icons.add_circle_outline, size: 40, color: Colors.orange.shade200),
                              const SizedBox(height: 8),
                              Text("아직 리스트가 없어요", style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      else ...[
                        // 미완료
                        if (_filteredMissions.any((m) => !m.completed)) ...[
                          const Align(alignment: Alignment.centerLeft, child: Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4),
                            child: Text("진행 중", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          )),
                          ..._filteredMissions.where((m) => !m.completed).map((m) => MissionCard(
                            mission: m,
                            onToggle: widget.onToggleMission,
                            onEdit: (id) {},
                            onDelete: widget.onDeleteMission,
                            onAddPhoto: widget.onAddPhoto,
                          )),
                        ],
                        // 완료
                        if (_filteredMissions.any((m) => m.completed)) ...[
                          const SizedBox(height: 16),
                          const Align(alignment: Alignment.centerLeft, child: Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4),
                            child: Text("완료", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          )),
                          ..._filteredMissions.where((m) => m.completed).map((m) => MissionCard(
                            mission: m,
                            onToggle: widget.onToggleMission,
                            onEdit: (id) {},
                            onDelete: widget.onDeleteMission,
                            onAddPhoto: widget.onAddPhoto,
                          )),
                        ]
                      ]
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- 위젯 헬퍼 ---

  Widget _buildCircleBtn(IconData icon, Color bg, Color contentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: contentColor),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildFilterTab(String id, String label) {
    final isSelected = _filterTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(DateTime date) {
    final isSelected = date.day == _selectedWeekDate.day;
    final isToday = date.day == DateTime.now().day;
    final dayName = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
    final completion = (date.day == DateTime.now().day) ? (_getCompletionRate(date) * 100).toInt() : 0;

    return GestureDetector(
      onTap: () => setState(() => _selectedWeekDate = date),
      child: Column(
        children: [
          Text(dayName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : (isToday ? Colors.orange.shade100 : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${date.day}",
                style: TextStyle(
                  color: isSelected ? Colors.white : (isToday ? Colors.orange.shade800 : Colors.grey.shade800),
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text("$completion%", style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}