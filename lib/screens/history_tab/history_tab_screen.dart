import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:b612_1/models/completed_mission.dart';
// 1. [추가] tag_colors.dart import (getCategoryColor를 사용하기 위함)
import 'package:b612_1/utils/tag_colors.dart';

class HistoryTabScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;
  final String profileEmoji;
  final String userBio;

  const HistoryTabScreen({
    super.key,
    required this.onOpenProfile,
    required this.profileEmoji,
    required this.userBio,
  });

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final Set<String> _expandedMissions = <String>{};
  CompletedMission? _selectedMissionForPhoto;

  late List<CompletedMission> _completedMissions;
  late Map<DateTime, List<CompletedMission>> _missionsByDate;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 임시 샘플 데이터 사용
    _completedMissions = sampleCompletedMissions;
    _missionsByDate = _groupMissionsByDate(_completedMissions);
  }

  Map<DateTime, List<CompletedMission>> _groupMissionsByDate(List<CompletedMission> missions) {
    Map<DateTime, List<CompletedMission>> map = {};
    for (var mission in missions) {
      final dateKey = DateUtils.dateOnly(mission.completedAt);
      if (map[dateKey] == null) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(mission);
    }
    return map;
  }

  List<CompletedMission> _getMissionsForDay(DateTime day) {
    return _missionsByDate[DateUtils.dateOnly(day)] ?? [];
  }

  String _formatDate(DateTime date) {
    return DateFormat('M월 d일 EEEE', 'ko_KR').format(date);
  }

  void _handleMissionDoubleClick(String missionId) {
    setState(() {
      if (_expandedMissions.contains(missionId)) {
        _expandedMissions.remove(missionId);
      } else {
        _expandedMissions.add(missionId);
      }
    });
  }

  void _handlePhotoClick(CompletedMission mission) {
    setState(() {
      _selectedMissionForPhoto = mission;
    });
    showDialog(
      context: context,
      builder: (context) => _buildPhotoDialog(context, mission),
    );
  }

  Future<void> _handleAddPhoto(CompletedMission mission) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // TODO: AppShell의 핸들러를 호출하도록 수정
    setState(() {
      final updatedMission = _completedMissions.firstWhere((m) => m.id == mission.id);
      updatedMission.photos = [image.path];
      updatedMission.representativePhoto = image.path;
      updatedMission.hasPhoto = true;

      if (_selectedMissionForPhoto != null && _selectedMissionForPhoto!.id == mission.id) {
        _selectedMissionForPhoto = updatedMission;
      }
      _missionsByDate = _groupMissionsByDate(_completedMissions);
    });

    Navigator.pop(context); // 이전 다이얼로그 닫기
    _handlePhotoClick(mission); // 새 정보로 다이얼로그 다시 열기
  }

  void _handleDeletePhoto(String missionId) {
    // TODO: AppShell의 핸들러를 호출하도록 수정
    setState(() {
      final updatedMission = _completedMissions.firstWhere((m) => m.id == missionId);
      updatedMission.photos = [];
      updatedMission.representativePhoto = null;
      updatedMission.hasPhoto = false;

      _missionsByDate = _groupMissionsByDate(_completedMissions);
    });
    Navigator.pop(context); // 다이얼로그 닫기
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateMissions = _getMissionsForDay(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5D6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 180.0,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileSection(context),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 4.0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                color: Colors.white.withOpacity(0.9),
                child: const SizedBox(height: 100.0, child: Center(child: Text('통계 데이터 (비어있음)'))),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 4.0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTableCalendar(context),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
            sliver: SliverToBoxAdapter(
              child: _buildMissionListHeader(context, selectedDateMissions),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
            sliver: _buildMissionList(context, selectedDateMissions),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Row(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(widget.profileEmoji, style: const TextStyle(fontSize: 32.0)),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Text(
                  '# ${widget.userBio}',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            IconButton(
              icon: const Icon(LucideIcons.settings, size: 24.0),
              color: Colors.grey.shade600,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                elevation: 4.0,
              ),
              onPressed: widget.onOpenProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCalendar(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: _focusedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDate = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDate = focusedDay;
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        formatButtonVisible: false,
        leftChevronIcon: Icon(LucideIcons.chevronLeft, size: 20.0, color: Colors.grey.shade500),
        rightChevronIcon: Icon(LucideIcons.chevronRight, size: 20.0, color: Colors.grey.shade500),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.orange, width: 2.0),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        selectedDecoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold),
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final missions = _getMissionsForDay(day);
          if (missions.isNotEmpty) {
            final photoMission = missions.firstWhere(
                  (m) => m.hasPhoto && (m.photos?.isNotEmpty ?? false),  // ← 수정
              orElse: () => missions.first,
            );

            if (photoMission.hasPhoto && (photoMission.photos?.isNotEmpty ?? false)) {  // ← 수정
              return Positioned(
                bottom: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    photoMission.representativePhoto ?? photoMission.photos!.first,
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildCalendarDot(getCategoryColor(missions.first.category)),
                  ),
                ),
              );
            }
            return Positioned(
              bottom: 6.0,
              child: _buildCalendarDot(getCategoryColor(missions.first.category)),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCalendarDot(Color color) {
    return Container(
      width: 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMissionListHeader(BuildContext context, List<CompletedMission> missions) {
    if (missions.isEmpty) {
      return Card(
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4.0),
              Text('개의 미션', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12.0),
              // 5. [수정] calendarDays -> calendar (존재하는 아이콘으로)
              Icon(LucideIcons.calendar, size: 24.0, color: Colors.grey.shade400),
              const SizedBox(height: 8.0),
              Text('이 날에는 완료한 미션이 없습니다', style: TextStyle(color: Colors.grey.shade500, fontSize: 14.0)),
              Text('다른 날짜를 선택해보세요 ✨', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.0)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(_selectedDate),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Text(
              '완료한 미션',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8.0),
            Text(
              '${missions.length}',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionList(BuildContext context, List<CompletedMission> missions) {
    if (missions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final mission = missions[index];
          final isExpanded = _expandedMissions.contains(mission.id);

          return GestureDetector(
            onDoubleTap: () => _handleMissionDoubleClick(mission.id),
            child: Card(
              elevation: 2.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: getCategoryColor(mission.category), width: 2.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  if (mission.hasPhoto && mission.representativePhoto != null)
                    Positioned.fill(
                      child: Image.network(
                        mission.representativePhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade100),
                      ),
                    ),
                  if (mission.hasPhoto && mission.representativePhoto != null)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                        child: Container(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.title,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              mission.description,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: getCategoryColor(mission.category).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                mission.category,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: getCategoryColor(mission.category).withOpacity(1.0),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (mission.hasPhoto) {
                                  _handlePhotoClick(mission);
                                } else {
                                  _handleAddPhoto(mission);
                                }
                              },
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: mission.hasPhoto
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: mission.hasPhoto
                                      ? null
                                      : Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      mission.hasPhoto ? LucideIcons.camera : LucideIcons.plus,
                                      size: 14.0,
                                      color: mission.hasPhoto ? Colors.grey.shade600 : Colors.grey.shade400,
                                    ),
                                    if (!mission.hasPhoto)
                                      Icon(
                                        LucideIcons.camera,
                                        size: 14.0,
                                        color: Colors.grey.shade400,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: missions.length,
      ),
    );
  }

  Widget _buildPhotoDialog(BuildContext context, CompletedMission mission) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                color: Colors.orange.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: getCategoryColor(mission.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        mission.category,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: getCategoryColor(mission.category).withOpacity(1.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          mission.title,
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.grey.shade800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.orange.shade100.withOpacity(0.5),
                child: (mission.photos?.isNotEmpty ?? false)  // ← 수정
                    ? Image.network(
                  mission.photos!.first,
                  height: 300.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(height: 300.0, child: Center(child: Text('이미지 로드 실패'))),
                )
                    : Container(
                  height: 300.0,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.camera, size: 48.0, color: Colors.orange.shade400),
                      const SizedBox(height: 16.0),
                      Text('첨부된 사진이 없습니다', style: TextStyle(fontSize: 16.0, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (mission.hasPhoto) ...[
                      TextButton.icon(
                        // 8. [수정] pencil -> edit
                        icon: const Icon(LucideIcons.pencil, size: 14.0),
                        label: const Text('변경'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange.shade600,
                          backgroundColor: Colors.orange.shade50,
                        ),
                        onPressed: () {
                          _handleAddPhoto(mission);
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(LucideIcons.trash2, size: 14.0),
                        label: const Text('삭제'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          backgroundColor: Colors.red.shade50,
                        ),
                        onPressed: () {
                          _handleDeletePhoto(mission.id);
                        },
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        icon: const Icon(LucideIcons.plus, size: 14.0),
                        label: const Text('사진 추가하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _handleAddPhoto(mission);
                        },
                      ),
                    ],
                    TextButton(
                      child: Text('닫기', style: TextStyle(color: Colors.grey.shade600)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}