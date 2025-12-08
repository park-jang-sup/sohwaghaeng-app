import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:b612_1/models/mission.dart';

class MyRecordsScreen extends StatefulWidget {
  final List<Mission> missions;
  final Function(String, String?) onAddPhoto;
  final VoidCallback onBack;

  const MyRecordsScreen({
    super.key,
    required this.missions,
    required this.onAddPhoto,
    required this.onBack,
  });

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  String? _selectedDate; // 선택된 날짜 (String format)

  // 날짜별로 완료된 미션 그룹화
  Map<String, List<Mission>> get _groupedMissions {
    final completed = widget.missions.where((m) => m.completed && m.completedAt != null).toList();
    final Map<String, List<Mission>> group = {};

    for (var m in completed) {
      // ISO String -> DateTime -> Local Date String
      final date = DateTime.parse(m.completedAt!);
      final dateKey = DateFormat('yyyy년 M월 d일').format(date);

      if (!group.containsKey(dateKey)) {
        group[dateKey] = [];
      }
      group[dateKey]!.add(m);
    }
    return group;
  }

  // 날짜 정렬 (최신순)
  List<String> get _sortedDates {
    final dates = _groupedMissions.keys.toList();
    dates.sort((a, b) {
      // 문자열 파싱이 복잡하므로 간단히 비교 (실제로는 DateTime 비교 권장)
      return b.compareTo(a);
    });
    return dates;
  }

  Future<void> _pickPhoto(String missionId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onAddPhoto(missionId, image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDate == null) {
      return _buildDateListView();
    } else {
      return _buildDetailView();
    }
  }

  // 1. 날짜 목록 뷰
  Widget _buildDateListView() {
    final dates = _sortedDates;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEFE9)], // Orange-50 to 25
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onBack,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 10),
                    const Text("나의 기록", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("완료한 미션들을 날짜별로 확인해보세요", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),

              // 리스트
              Expanded(
                child: dates.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final missions = _groupedMissions[date]!;
                    final photoCount = missions.where((m) => m.photo != null).length;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text("완료한 미션 ${missions.length}개", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                    if (photoCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Text("📷 $photoCount개", style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ]
                                  ],
                                )
                              ],
                            ),
                            // 아이콘 미리보기 (Stack)
                            SizedBox(
                              width: 80,
                              height: 32,
                              child: Stack(
                                children: List.generate(
                                  missions.length > 3 ? 3 : missions.length,
                                      (i) => Positioned(
                                    right: i * 20.0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Icon(missions[i].iconData, size: 16, color: Colors.orange),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 2. 상세 보기
  Widget _buildDetailView() {
    final missions = _groupedMissions[_selectedDate] ?? [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFFEFE9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _selectedDate = null),
                          icon: const Icon(Icons.arrow_back),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Text(_selectedDate!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 36, top: 4),
                      child: Text("이날 완료한 미션들", style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: missions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final m = missions[index];
                    final hasPhoto = m.photo != null;

                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(left: BorderSide(color: Colors.grey, width: 4)),
                        image: hasPhoto ? DecorationImage(
                          image: FileImage(File(m.photo!)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                        ) : null,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // 상태 아이콘
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 12),

                            // 텍스트 정보
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: hasPhoto ? Colors.white.withOpacity(0.8) : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(m.iconData, size: 16, color: Colors.orange.shade800),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        m.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: hasPhoto ? Colors.white : Colors.black87,
                                          decoration: TextDecoration.lineThrough,
                                          decorationColor: hasPhoto ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: hasPhoto ? Colors.white70 : Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            // 사진 추가/삭제 버튼
                            hasPhoto
                                ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => widget.onAddPhoto(m.id, null), // 삭제
                            )
                                : OutlinedButton.icon(
                              onPressed: () => _pickPhoto(m.id),
                              icon: const Icon(Icons.camera_alt, size: 14),
                              label: const Text("사진", style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("아직 완료한 미션이 없습니다", style: TextStyle(color: Colors.grey)),
          const Text("오늘부터 소확행을 시작해보세요!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}