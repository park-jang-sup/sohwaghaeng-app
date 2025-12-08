import 'package:flutter/material.dart';

class NicknameSetupScreen extends StatefulWidget {
  final Function(String) onComplete;
  final VoidCallback onBack;

  const NicknameSetupScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  void _handleSubmit() {
    if (_nicknameController.text.trim().isNotEmpty) {
      widget.onComplete(_nicknameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE5D6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 뒤로가기
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey, size: 32),
                    onPressed: widget.onBack,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 이모지 아이콘
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: const Center(child: Text("🌟", style: TextStyle(fontSize: 32))),
                      ),
                      const SizedBox(height: 24),
                      const Text("환영합니다!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      const Text("어떻게 불러드릴까요?", style: TextStyle(fontSize: 16, color: Colors.grey)),

                      const SizedBox(height: 32),

                      // 입력 카드
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nicknameController,
                              decoration: InputDecoration(
                                hintText: "닉네임을 입력해주세요",
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              maxLength: 20,
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                            const Text("최대 20자까지 입력 가능해요", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 완료 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: const Text("소확행 시작하기! 🌟", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}