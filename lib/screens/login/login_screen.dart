import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:b612_1/widgets/social_login_button.dart';

// .tsx 파일의 onSocialLogin 콜백에서 'google' | 'kakao' | 'apple' 타입을
// Flutter의 enum으로 더 안전하게 정의합니다.
enum SocialLoginProvider { google, kakao, apple }

class LoginScreen extends StatelessWidget {
  // .tsx 파일의 Props 인터페이스에 해당합니다.
  // Flutter에서는 final 변수와 생성자로 콜백을 전달받습니다.
  final VoidCallback onGuestLogin;
  final Function(SocialLoginProvider) onSocialLogin;

  const LoginScreen({
    super.key,
    required this.onGuestLogin,
    required this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    // `div`의 `min-h-screen`과 그라데이션 배경에 해당합니다.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // style: background: linear-gradient(...)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5D6), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // 화면 상단 (노치) 등을 피하기 위해 SafeArea를 사용합니다.
        // `flex flex-col items-center justify-center`
        // -> Center와 SingleChildScrollView를 조합하여
        //    내용이 길어져도 스크롤이 가능하게 만듭니다.
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // `p-6` (24.0)와 하단 여백을 설정합니다.
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // 자식 위젯이 가로로 꽉 차게
                children: [
                  // --- 로고 및 타이틀 섹션 ---
                  _buildLogoSection(),
                  // `mb-12` (48.0)
                  const SizedBox(height: 48.0),

                  // --- 로그인 카드 섹션 ---
                  // `Card` (`w-full max-w-sm shadow-xl border-0`)
                  Card(
                    elevation: 8.0, // `shadow-xl`
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    // `border-0`
                    semanticContainer: false,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      // `CardContent` (`p-6`)
                      padding: const EdgeInsets.all(24.0),
                      // `space-y-4` (SizedBox로 대체)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // `h2` (`text-center text-lg ...`)
                          const Text(
                            '시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // `mb-6`
                          const SizedBox(height: 24.0),

                          // --- 소셜 로그인 버튼들 ---
                          // 2. _(언더바)가 없는 SocialLoginButton으로 변경
                          SocialLoginButton(
                            text: 'Google로 시작하기',
                            icon: const Icon(LucideIcons.mail, size: 20, color: Color(0xFFEF4444)),
                            borderColor: Colors.grey.shade200,
                            onPressed: () => onSocialLogin(SocialLoginProvider.google),
                          ),
                          const SizedBox(height: 16.0), // `space-y-4`

                          SocialLoginButton(
                            text: '카카오로 시작하기',
                            icon: const Icon(LucideIcons.messageCircle, size: 20, color: Color(0xFFD97706)),
                            borderColor: Colors.yellow.shade200,
                            onPressed: () => onSocialLogin(SocialLoginProvider.kakao),
                          ),
                          const SizedBox(height: 16.0), // `space-y-4`

                          SocialLoginButton(
                            text: 'Apple로 시작하기',
                            icon: SvgPicture.asset(
                              'assets/icons/apple_logo.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF1F2937), // `border-gray-800`
                                BlendMode.srcIn,
                              ),
                            ),
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

                          // --- 게스트 버튼 ---
                          TextButton.icon(
                            onPressed: onGuestLogin,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              minimumSize: const Size(double.infinity, 48.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(LucideIcons.user, size: 20),
                            label: const Text('게스트로 둘러보기'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 하단 텍스트 ---
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

  // 로고 섹션을 별도 위젯으로 분리 (가독성을 위해)
  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 96.0,
          height: 96.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0), // `rounded-3xl`
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // `shadow-lg`
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