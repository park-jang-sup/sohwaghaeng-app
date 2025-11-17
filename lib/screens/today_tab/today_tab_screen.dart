import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/widgets/planet_progress_indicator.dart';

// [수정] TodayTabScreen은 이제 상태와 핸들러를 부모로부터 전달받습니다.
class TodayTabScreen extends StatefulWidget {
  final List<Mission> missions;
  final Map<String, bool> attendanceData;
  final Function(String) onToggleMission;
  final VoidCallback onAddMission; // AppShell의 모달 여는 함수
  final Function(String, String?) onAddPhoto; // AppShell의 사진 추가/삭제 핸들러
  final Function(String) onDeleteMission;

  const TodayTabScreen({
    super.key,
    required this.missions,
    required this.attendanceData,
    required this.onToggleMission,
    required this.onAddMission,
    required this.onAddPhoto,
    required this.onDeleteMission,
  });

  @override
  State<TodayTabScreen> createState() => _TodayTabScreenState();
}

class _TodayTabScreenState extends State<TodayTabScreen> {
  // [삭제] missions, attendanceData, customTags 상태 (이제 widget에서 받음)

  Mission? _missionToDelete;
  final Set<String> _expandedMissions = <String>{};
  final Set<String> _showDeleteButtons = <String>{};
  final ImagePicker _picker = ImagePicker();
  String _currentDateFormatted = '';

  @override
  void initState() {
    super.initState();
    _currentDateFormatted =
        DateFormat.yMMMMd('ko_KR').add_EEEE().format(DateTime.now());

    // [삭제] _missions, _attendanceData, _customTags 초기화 로직 (widget에서 받음)
  }

  // [삭제] _onToggleMission (widget.onToggleMission 사용)
  // [삭제] _onAddMission (widget.onAddMission 사용)
  // [삭제] _handleAddNewMission (AppShell로 이동됨)
  // [삭제] _handleAddNewCustomTag (AppShell로 이동됨)

  // [수정] _onAddPhoto는 ImagePicker를 실행하고, 부모의 핸들러(widget.onAddPhoto)를 호출
  Future<void> _onAddPhoto(String missionId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onAddPhoto(missionId, image.path);
    }
  }

  // [수정] _onRemovePhoto는 부모의 핸들러(widget.onAddPhoto)에 null을 전달하여 호출
  void _onRemovePhoto(String missionId) {
    widget.onAddPhoto(missionId, null);
  }

  // [삭제] _onDeleteMission (widget.onDeleteMission 사용)

  void _showDeleteDialog(Mission mission) {
    setState(() => _missionToDelete = mission);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('미션을 삭제하시겠습니까?'),
        content:
        Text('"${_missionToDelete!.title}"을(를) 삭제합니다. 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              setState(() => _missionToDelete = null);
              Navigator.pop(context);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
            onPressed: () {
              if (_missionToDelete != null) {
                // [수정] widget.onDeleteMission 호출
                widget.onDeleteMission(_missionToDelete!.id);
              }
              setState(() => _missionToDelete = null);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _toggleExpandMission(String id) {
    setState(() {
      _expandedMissions.contains(id)
          ? _expandedMissions.remove(id)
          : _expandedMissions.add(id);
    });
  }

  void _toggleDeleteMode(String id) {
    setState(() {
      _showDeleteButtons.clear();
      _showDeleteButtons.add(id);
    });
  }

  void _hideAllDeleteModes() {
    if (_showDeleteButtons.isNotEmpty) {
      setState(() => _showDeleteButtons.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] 상태를 widget에서 직접 참조
    final completedCount = widget.missions.where((m) => m.completed).length;
    final bool isCompleted =
        widget.missions.isNotEmpty && completedCount == widget.missions.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddMission, // [수정] AppShell의 모달 여는 함수 호출
        backgroundColor: Colors.orange,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(bottom: 80.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEFE9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GestureDetector(
          onTap: _hideAllDeleteModes,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, completedCount, widget.missions.length), // [수정]
                  Text(_currentDateFormatted,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      )),
                  const SizedBox(height: 24),
                  _buildAttendanceRow(context),
                  const SizedBox(height: 16),
                  if (isCompleted)
                    Center(
                      child: Text(
                        "🌟 행성이 완전히 채워졌습니다! 🌟",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildMissionList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completedCount, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '오늘의 소확행',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        PlanetProgressIndicator(
          completedCount: completedCount,
          totalCount: total,
        )
      ],
    );
  }

  Widget _buildAttendanceRow(BuildContext context) {
    final today = DateTime.now();
    final List<Widget> dayWidgets = [];

    for (int i = -3; i <= 3; i++) {
      final date = today.add(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      // [수정] _attendanceData -> widget.attendanceData
      final bool completed = widget.attendanceData[dateKey] ?? false;
      final bool isToday = i == 0;
      final bool isFutureDay = i > 0;

      String label = i == -1
          ? '어제'
          : i == 0
          ? '오늘'
          : i == 1
          ? '내일'
          : DateFormat.E('ko_KR').format(date);

      dayWidgets.add(
        _buildAttendanceDay(
          dayLabel: label,
          dateNum: date.day.toString(),
          completed: completed,
          isToday: isToday,
          isFutureDay: isFutureDay,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: dayWidgets,
    );
  }

  Widget _buildAttendanceDay({
    required String dayLabel,
    required String dateNum,
    required bool completed,
    required bool isToday,
    required bool isFutureDay,
  }) {
    Color boxColor = Colors.grey.shade100;
    Color borderColor = Colors.grey.shade300;
    Color dayLabelColor = Colors.grey.shade500;
    Color dateNumColor = Colors.grey.shade400;

    if (completed) {
      boxColor = Colors.green.shade500;
      borderColor = Colors.green.shade500;
      dayLabelColor = Colors.grey.shade600;
    }

    if (isToday) {
      borderColor = Colors.orange;
      dayLabelColor = Colors.orange;
      dateNumColor = Colors.orange;
      boxColor = completed ? Colors.orange : Colors.orange.shade50;
    }

    if (isFutureDay) {
      boxColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade200;
    }

    return Column(
      children: [
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 12,
            color: dayLabelColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2,
              style: (isToday && !completed)
                  ? BorderStyle.solid // DottedBorder 패키지 사용 시 BorderStyle.dashed
                  : BorderStyle.solid,
            ),
          ),
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : (isToday
              ? Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.5),
              ),
            ),
          )
              : null),
        ),
        const SizedBox(height: 6),
        Text(
          dateNum,
          style: TextStyle(
            fontSize: 12,
            color: dateNumColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _buildMissionList(BuildContext context) {
    // [수정] _missions -> widget.missions
    if (widget.missions.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 2,
            style: BorderStyle.solid, // DottedBorder 패키지 사용 시 BorderStyle.dashed
          ),
        ),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(LucideIcons.smile,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  '오늘의 첫 번째 소확행을\n추가해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      // [수정] _missions -> widget.missions
      children:
      widget.missions.map((m) => _buildMissionCard(context, m)).toList(),
    );
  }

  Widget _buildMissionCard(BuildContext context, Mission mission) {
    final bool isCompleted = mission.completed;
    final bool hasPhoto = mission.photo != null && mission.photo!.isNotEmpty;
    final bool isExpanded = _expandedMissions.contains(mission.id);
    final bool isDeleteMode = _showDeleteButtons.contains(mission.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: ValueKey(mission.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _showDeleteDialog(mission),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.trash2, color: Colors.white),
              SizedBox(height: 4),
              Text('삭제', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        child: GestureDetector(
          onLongPress: () => _toggleDeleteMode(mission.id),
          onDoubleTap: () => _toggleExpandMission(mission.id),
          onTap: _hideAllDeleteModes,
          child: Card(
            elevation: isCompleted ? 1 : 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDeleteMode
                    ? Colors.red.shade200
                    : isExpanded
                    ? Colors.blue.shade200
                    : Colors.transparent,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                image: (isCompleted && hasPhoto)
                    ? DecorationImage(
                  image: FileImage(File(mission.photo!)),
                  fit: BoxFit.cover,
                )
                    : null,
                color: (isCompleted && !hasPhoto)
                    ? Colors.grey.shade50
                    : Colors.white,
              ),
              child: Stack(
                children: [
                  if (isCompleted && hasPhoto)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isCompleted,
                              // [수정] widget.onToggleMission 호출
                              onChanged: (_) => widget.onToggleMission(mission.id),
                              activeColor: Colors.orange,
                              fillColor:
                              MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.orange;
                                }
                                return hasPhoto
                                    ? Colors.white
                                    : Colors.grey.shade300;
                              }),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (isCompleted && hasPhoto)
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(mission.icon,
                                  size: 16, color: Colors.orange.shade700),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  mission.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDeleteMode
                                    ? LucideIcons.trash2
                                    : LucideIcons.ellipsis,
                                color: isDeleteMode
                                    ? Colors.red.shade600
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () {
                                if (isDeleteMode) {
                                  _showDeleteDialog(mission);
                                } else {
                                  _toggleDeleteMode(mission.id);
                                }
                              },
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: _buildExpandedDescription(mission),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, left: 44),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isCompleted && hasPhoto)
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#${mission.tag}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              if (isCompleted && !isDeleteMode)
                                hasPhoto
                                    ? _buildPhotoActionButton(
                                  icon: LucideIcons.x,
                                  onPressed: () =>
                                      _onRemovePhoto(mission.id),
                                )
                                    : _buildPhotoActionButton(
                                  icon: LucideIcons.camera,
                                  text: "사진 추가",
                                  onPressed: () =>
                                      _onAddPhoto(mission.id),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDescription(Mission mission) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 44, right: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mission.description,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "💡 다시 더블클릭하면 숨겨집니다",
            style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoActionButton({
    required IconData icon,
    String? text,
    required VoidCallback onPressed,
  }) {
    if (text != null) {
      return OutlinedButton.icon(
        icon: Icon(icon, size: 14),
        label: Text(text, style: const TextStyle(fontSize: 12)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          backgroundColor: Colors.white.withOpacity(0.5),
          side: BorderSide(
            color: Colors.grey.shade400,
            style: BorderStyle.solid, // DottedBorder 패키지 사용 시 BorderStyle.dashed
          ),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, size: 16),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.grey.shade600,
      ),
    );
  }
}