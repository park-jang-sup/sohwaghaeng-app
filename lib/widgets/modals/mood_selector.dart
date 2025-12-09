import 'package:flutter/material.dart';

class MoodSelector extends StatefulWidget {
  final Function(String) onSelectMood;

  const MoodSelector({super.key, required this.onSelectMood});

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  final TextEditingController _customMoodController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'id': 'comfortable', 'label': '편안', 'icon': Icons.sentiment_satisfied_alt_rounded, 'bgColor': 0xFFDBEAFE, 'textColor': 0xFF2563EB}, // Blue
    {'id': 'excited', 'label': '기대', 'icon': Icons.auto_awesome_rounded, 'bgColor': 0xFFFEF9C3, 'textColor': 0xFFCA8A04}, // Yellow
    {'id': 'regretful', 'label': '아쉬움', 'icon': Icons.cloud_off_rounded, 'bgColor': 0xFFF3F4F6, 'textColor': 0xFF4B5563}, // Gray
    {'id': 'happy', 'label': '행복', 'icon': Icons.favorite_rounded, 'bgColor': 0xFFFCE7F3, 'textColor': 0xFFDB2777}, // Pink
    {'id': 'annoyed', 'label': '짜증', 'icon': Icons.sentiment_dissatisfied_rounded, 'bgColor': 0xFFFEE2E2, 'textColor': 0xFFDC2626}, // Red
    {'id': 'depressed', 'label': '우울', 'icon': Icons.cloud_rounded, 'bgColor': 0xFFE0E7FF, 'textColor': 0xFF4F46E5}, // Indigo
    {'id': 'satisfied', 'label': '만족', 'icon': Icons.thumb_up_rounded, 'bgColor': 0xFFDCFCE7, 'textColor': 0xFF16A34A}, // Green
    {'id': 'lethargic', 'label': '무기력', 'icon': Icons.battery_alert_rounded, 'bgColor': 0xFFF3E8FF, 'textColor': 0xFF9333EA}, // Purple
    {'id': 'sad', 'label': '슬픔', 'icon': Icons.sentiment_very_dissatisfied_rounded, 'bgColor': 0xFFF1F5F9, 'textColor': 0xFF475569}, // Slate
  ];

  String get _timeOfDayGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '아침';
    if (hour < 18) return '점심';
    return '저녁';
  }

  void _handleCustomSubmit() {
    if (_customMoodController.text.trim().isNotEmpty) {
      widget.onSelectMood(_customMoodController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 투명 배경 (AppShell에서 이미 오버레이 처리됨)
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 인사말
                Text(
                  "좋은 $_timeOfDayGreeting이에요,",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 4),
                const Text(
                  "오늘의 기분은 어떤가요?",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                // 기분 그리드
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    return GestureDetector(
                      onTap: () => widget.onSelectMood(mood['label']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(mood['bgColor']),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(mood['icon'], color: Color(mood['textColor']), size: 28),
                            const SizedBox(height: 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                color: Color(mood['textColor']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 직접 입력
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _customMoodController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onSubmitted: (_) => _handleCustomSubmit(),
                    decoration: InputDecoration(
                      hintText: "직접 입력",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: _handleCustomSubmit,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}