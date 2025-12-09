import 'package:flutter/material.dart';

// [중요] 클래스 이름이 CreateMissionModal 이어야 합니다.
class CreateMissionModal extends StatefulWidget {
  // HomeTabScreen에서 넘겨주는 파라미터와 모양이 같아야 합니다.
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
  String _selectedColorId = 'orange'; // 기본값 설정
  bool _isPublic = false;

  // 아이콘 옵션
  final List<Map<String, dynamic>> _iconOptions = [
    {'id': 'sun', 'icon': Icons.wb_sunny_rounded},
    {'id': 'book', 'icon': Icons.menu_book_rounded},
    {'id': 'leaf', 'icon': Icons.eco_rounded},
    {'id': 'heart', 'icon': Icons.favorite_rounded},
    {'id': 'coffee', 'icon': Icons.coffee_rounded},
    {'id': 'star', 'icon': Icons.star_rounded},
    {'id': 'tree', 'icon': Icons.park_rounded},
    {'id': 'zap', 'icon': Icons.bolt_rounded},
    {'id': 'flame', 'icon': Icons.local_fire_department_rounded},
  ];

  // 색상 옵션
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
      _colorOptions.firstWhere(
            (c) => c['id'] == _selectedColorId,
        orElse: () => _colorOptions[0],
      );

  // 시간 선택 피커
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  void _handleSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    // 선택된 색상의 Hex Code String (#RRGGBB) 변환
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: const Text("새 미션 만들기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text("제목", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "입력",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                const Text("아이콘", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final option = _iconOptions[index];
                    final isSelected = _selectedIconId == option['id'];
                    final activeColor = Color(_currentColor['darkColor']);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconId = option['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected ? Colors.orange.shade300 : Colors.grey.shade200, width: 2),
                        ),
                        child: Icon(option['icon'], color: isSelected ? activeColor : Colors.grey.shade400),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const Text("카드 색상", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _colorOptions.map((option) {
                    final isSelected = _selectedColorId == option['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorId = option['id']),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Color(option['color']),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected ? Colors.grey.shade800 : Colors.grey.shade300, width: isSelected ? 2 : 1),
                        ),
                        child: isSelected ? Icon(Icons.check, size: 20, color: Colors.grey.shade800) : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _selectTime,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: "시간 (선택사항)",
                        suffixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("취소"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _titleController.text.trim().isNotEmpty ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    child: const Text("완료"),
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