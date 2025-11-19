import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // [수정] SVG 삭제
// import 'package:lucide_flutter/lucide_flutter.dart'; // [수정] LucideIcons 삭제

import 'package:b612_1/widgets/social_login_button.dart';

enum SocialLoginProvider { google, kakao, apple }

class LoginScreen extends StatelessWidget {
  final VoidCallback onGuestLogin;
  final Function(SocialLoginProvider) onSocialLogin;

  const LoginScreen({
    super.key,
    required this.onGuestLogin,
    required this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5D6), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 48.0),

                  Card(
                    elevation: 8.0,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    semanticContainer: false,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // --- 소셜 로그인 버튼들 (Icons로 교체) ---

                          // 1. Google (LucideIcons.mail -> Icons.email)
                          SocialLoginButton(
                            text: 'Google로 시작하기',
                            icon: const Icon(Icons.email, size: 20, color: Color(0xFFEF4444)),
                            borderColor: Colors.grey.shade200,
                            onPressed: () => onSocialLogin(SocialLoginProvider.google),
                          ),
                          const SizedBox(height: 16.0),

                          // 2. Kakao (LucideIcons.messageCircle -> Icons.chat_bubble)
                          SocialLoginButton(
                            text: '카카오로 시작하기',
                            icon: const Icon(Icons.chat_bubble, size: 20, color: Color(0xFFD97706)),
                            borderColor: Colors.yellow.shade200,
                            onPressed: () => onSocialLogin(SocialLoginProvider.kakao),
                          ),
                          const SizedBox(height: 16.0),

                          // 3. Apple (SvgPicture -> Icons.apple)
                          // * 참고: Icons.apple은 Flutter 최신 버전에서 지원됩니다.
                          // * 만약 아이콘이 안 보이면 Icons.phone_iphone 등을 사용하세요.
                          SocialLoginButton(
                            text: 'Apple로 시작하기',
                            icon: const Icon(Icons.apple, size: 20, color: Color(0xFF1F2937)),
                            borderColor: Colors.grey.shade800,
                            foregroundColor: Colors.grey.shade800,
                            onPressed: () => onSocialLogin(SocialLoginProvider.apple),
                          ),

                          // --- '또는' 구분선 ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade200)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade200)),
                              ],
                            ),
                          ),

                          // --- 게스트 버튼 (LucideIcons.user -> Icons.person) ---
                          TextButton.icon(
                            onPressed: onGuestLogin,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              minimumSize: const Size(double.infinity, 48.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(Icons.person, size: 20),
                            label: const Text('게스트로 둘러보기'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '계속 진행하시면 서비스 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 96.0,
          height: 96.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌟', style: TextStyle(fontSize: 40.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          '소확행',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          '작은 행복을 찾아가는 여정',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}