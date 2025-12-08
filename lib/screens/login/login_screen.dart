import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onGuestLogin;
  final Function(String) onSocialLogin;

  const LoginScreen({
    super.key,
    required this.onGuestLogin,
    required this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 전체 배경 그라데이션
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE5D6), Colors.white],
              ),
            ),
          ),

          // 2. 하단 소행성 배경 (둥근 언덕 모양)
          Positioned(
            bottom: -100, // 화면 아래로 살짝 내림
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF8C42), Color(0xFFFFA07A)],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(300, 100), // 타원형 둥근 모서리
                ),
              ),
            ),
          ),

          // 3. 메인 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "로그인",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 48),

                  // 카드 영역
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "시작하기",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),

                        // 네이버 로그인 버튼
                        _buildSocialButton(
                          text: "네이버로 시작하기",
                          textColor: Colors.white, // 네이버는 보통 흰 글씨
                          backgroundColor: const Color(0xFF03C75A),
                          borderColor: const Color(0xFF03C75A),
                          icon: const Text("N", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onTap: () => onSocialLogin('naver'),
                        ),
                        const SizedBox(height: 12),

                        // 카카오 로그인 버튼
                        _buildSocialButton(
                          text: "카카오로 시작하기",
                          textColor: Colors.brown,
                          backgroundColor: const Color(0xFFFEE500),
                          borderColor: const Color(0xFFFEE500),
                          icon: const Icon(Icons.chat_bubble, size: 18, color: Colors.brown),
                          onTap: () => onSocialLogin('kakao'),
                        ),
                        const SizedBox(height: 12),

                        // 구글 로그인 버튼
                        _buildSocialButton(
                          text: "Google로 시작하기",
                          textColor: Colors.black87,
                          backgroundColor: Colors.white,
                          borderColor: Colors.grey.shade300,
                          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red), // 임시 아이콘
                          onTap: () => onSocialLogin('google'),
                        ),

                        const SizedBox(height: 24),

                        // 구분선
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("또는", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 게스트 로그인
                        TextButton.icon(
                          onPressed: onGuestLogin,
                          icon: const Icon(Icons.person_outline, color: Colors.grey),
                          label: const Text("게스트로 둘러보기", style: TextStyle(color: Colors.grey)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 하단 약관 텍스트
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "계속 진행하시면 서비스 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}