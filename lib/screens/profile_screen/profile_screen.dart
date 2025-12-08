import 'package:flutter/material.dart';
import 'package:b612_1/app_shell.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onBack,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nickController;

  // 알림 설정 상태
  bool _notiEnabled = true;
  bool _reminderEnabled = true;
  bool _weeklyReportEnabled = false;

  @override
  void initState() {
    super.initState();
    _nickController = TextEditingController(text: widget.userProfile.nickname);
  }

  void _toggleEdit() {
    if (_isEditing) {
      // 실제로는 여기서 서버로 닉네임 변경 요청을 보내야 합니다.
      setState(() {
        widget.userProfile.nickname = _nickController.text;
      });
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Figma 배경색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: widget.onBack,
        ),
        title: const Text("프로필 & 설정", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. 프로필 정보 카드
            _buildCard(
              title: "프로필 정보",
              action: TextButton.icon(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 16),
                label: Text(_isEditing ? "저장" : "편집"),
                onPressed: _toggleEdit,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7F50), // Figma 주황색
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              children: [
                // 닉네임
                if (_isEditing)
                  TextField(
                    controller: _nickController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(widget.userProfile.nickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),

                const SizedBox(height: 4),
                // 성향 타입
                Text(widget.userProfile.personalityType, style: const TextStyle(color: Colors.grey, fontSize: 13)),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // 계정 정보 섹션 (Figma 디자인 반영)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("계정", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    if (widget.userProfile.isGuest)
                    // 게스트일 경우: '게스트 로그인' 텍스트 + 주황색 로그인 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("게스트 로그인", style: TextStyle(fontSize: 14, color: Colors.black87)),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 로그인 화면으로 이동
                              print("로그인 화면으로 이동");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text("로그인", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    else
                    // 로그인 유저일 경우: 이메일 + 로그아웃 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.userProfile.email, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          OutlinedButton(
                            onPressed: widget.onLogout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("로그아웃", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 16),

            // 2. [NEW] 성향 테스트 다시하기 카드 (Figma 반영)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: InkWell(
                onTap: () {
                  // TODO: 성향 테스트 다시하기 로직
                  print("성향 테스트 다시하기");
                },
                child: Row(
                  children: [
                    // 아이콘 (Sparkles)
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    const Text("성향 테스트 다시하기", style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    // 현재 성향 표시
                    Text(widget.userProfile.personalityType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. 알림 설정 카드
            _buildCard(
              title: "알림 설정",
              icon: Icons.notifications,
              iconColor: Colors.orange,
              children: [
                _buildSwitchRow("푸시 알림", "앱 알림 받기", _notiEnabled, (v) => setState(() => _notiEnabled = v)),
                _buildSwitchRow("미션 리마인더", "완료하지 않은 미션 알림", _reminderEnabled, (v) => setState(() => _reminderEnabled = v)),
                _buildSwitchRow("주간 리포트", "주간 달성 결과 받기", _weeklyReportEnabled, (v) => setState(() => _weeklyReportEnabled = v)),
              ],
            ),

            const SizedBox(height: 16),

            // 4. 기타 메뉴 카드
            _buildCard(
              children: [
                _buildMenuRow(Icons.lock_outline, "개인정보 처리방침"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                _buildMenuRow(Icons.help_outline, "고객센터"),
              ],
            ),

            const SizedBox(height: 16),

            // 5. [NEW] 로그아웃 카드 (Figma 반영 - 하단 별도 배치)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text("로그아웃", style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 탈퇴하기 링크
            GestureDetector(
              onTap: () {
                // 탈퇴 로직
              },
              child: const Text(
                "탈퇴하기",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 카드 위젯 빌더
  Widget _buildCard({String? title, IconData? icon, Color? iconColor, Widget? action, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: iconColor ?? Colors.black),
                      const SizedBox(width: 8)
                    ],
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                if (action != null) action,
              ],
            ),
            if (action == null) const SizedBox(height: 16) else const SizedBox(height: 8),
          ],
          ...children
        ],
      ),
    );
  }

  // 스위치 행 빌더
  Widget _buildSwitchRow(String title, String sub, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.orange,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
            ),
          )
        ],
      ),
    );
  }

  // 메뉴 행 빌더
  Widget _buildMenuRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}