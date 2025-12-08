import 'package:flutter/material.dart';

class CreateMissionModal extends StatefulWidget {
  final Function(String title, String icon, String color, bool isPublic, String? time) onCreateMission;

  const CreateMissionModal({
    super.key,
    required this.onCreateMission,
  });

  @override
  State<CreateMissionModal> createState() => _CreateMissionModalState();
}

class _CreateMissionModalState extends State<CreateMissionModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _selectedIconId = 'sun';
  String _selectedColorId = 'white';
  bool _isPublic = false;

  // 아이콘 데이터 (React 코드와 매핑)
  final List<Map<String, dynamic>> _iconOptions = [
    {'id': 'sun', 'icon': Icons.wb_sunny_rounded, 'label': '해'},
    {'id': 'book', 'icon': Icons.menu_book_rounded, 'label': '책'},
    {'id': 'leaf', 'icon': Icons.eco_rounded, 'label': '나뭇잎'},
    {'id': 'heart', 'icon': Icons.favorite_rounded, 'label': '하트'},
    {'id': 'coffee', 'icon': Icons.coffee_rounded, 'label': '커피'},
    {'id': 'star', 'icon': Icons.star_rounded, 'label': '별'},
    {'id': 'tree', 'icon': Icons.park_rounded, 'label': '나무'},
    {'id': 'zap', 'icon': Icons.bolt_rounded, 'label': '번개'},
    {'id': 'flame', 'icon': Icons.local_fire_department_rounded, 'label': '불'},
  ];

  // 색상 데이터 (React 코드와 매핑)
  final List<Map<String, dynamic>> _colorOptions = [
    {'id': 'white', 'color': 0xFFFFFFFF, 'darkColor': 0xFF6B7280},
    {'id': 'orange', 'color': 0xFFFFD6A5, 'darkColor': 0xFFFF9A56},
    {'id': 'yellow', 'color': 0xFFFDFD96, 'darkColor': 0xFFE8E86E},
    {'id': 'green', 'color': 0xFFCAFFBF, 'darkColor': 0xFF84E8A4},
    {'id': 'blue', 'color': 0xFFA0C4FF, 'darkColor': 0xFF6B9FE8},
    {'id': 'purple', 'color': 0xFFDBC4FF, 'darkColor': 0xFFB896E8},
    {'id': 'pink', 'color': 0xFFFFD6E8, 'darkColor': 0xFFFFADD2},
    {'id': 'red', 'color': 0xFFFFADAD, 'darkColor': 0xFFFF7A7A},
    {'id': 'peach', 'color': 0xFFFFC6A5, 'darkColor': 0xFFFF9270},
  ];

  // 현재 선택된 색상 정보 가져오기
  Map<String, dynamic> get _currentColor =>
      _colorOptions.firstWhere((c) => c['id'] == _selectedColorId);

  // 시간 선택 피커
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // HH:mm 포맷으로 저장
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  void _handleSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    // 선택된 색상의 Hex Code String (#RRGGBB) 형태로 변환하여 전달
    String colorHex = '#${Color(_currentColor['color']).value.toRadixString(16).substring(2).toUpperCase()}';

    widget.onCreateMission(
      _titleController.text,
      _selectedIconId,
      colorHex,
      _isPublic,
      _timeController.text.isEmpty ? null : _timeController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // 키보드가 올라왔을 때 화면이 가려지지 않도록 패딩 처리
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 화면의 85% 높이
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "새 미션 만들기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 스크롤 가능한 폼 영역
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 제목 입력
                const Text("제목", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "입력",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (value) => setState(() {}), // 버튼 활성화를 위해 리빌드
                ),

                const SizedBox(height: 24),

                // 아이콘 선택
                const Text("아이콘", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final option = _iconOptions[index];
                    final isSelected = _selectedIconId == option['id'];
                    // 선택된 아이콘은 현재 선택된 색상의 다크 버전으로 틴트
                    final activeColor = Color(_currentColor['darkColor']);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconId = option['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          option['icon'],
                          color: isSelected ? activeColor : Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 색상 선택
                const Text("카드 색상", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorOptions.map((option) {
                    final isSelected = _selectedColorId == option['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorId = option['id']),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(option['color']),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.grey.shade800 : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)
                          ] : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 20, color: Colors.grey.shade800)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // 시간 설정
                const Text("시간 (선택사항)", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectTime,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: "--:--",
                        suffixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 공개 설정
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _isPublic,
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _isPublic = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("다른 사용자와 공유하기"),
                  ],
                ),

                // 하단 여백 확보
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 하단 버튼 영역
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("취소", style: TextStyle(color: Colors.grey.shade800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _titleController.text.trim().isNotEmpty ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}