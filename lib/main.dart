import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'firebase_options.dart';
import 'package:b612_1/services/auth_service.dart';
import 'package:b612_1/app_shell.dart';
import 'package:b612_1/screens/login/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. 플러터 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 카카오 SDK 초기화
  kakao.KakaoSdk.init(nativeAppKey: 'b5edb9f1862a0c6c7a43e426918be57c');

  try {
    String hash = await kakao.KakaoSdk.origin;
    print('🚨 카카오 등록용 키 해시: $hash');
  } catch (e) {
    print('키 해시 생성 실패: $e');
  }

  // 3. 파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '소확행',
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        scaffoldBackgroundColor: Colors.white,
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. 에러 발생 시
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("로그인 시스템 에러 발생")),
            );
          }

          // 3. 로그인 성공 상태 -> 메인 앱(AppShell) 실행
          if (snapshot.hasData) {
            return const AppShell();
          }

          // 4. 로그아웃 상태 -> 로그인 화면(LoginScreen) 실행
          return LoginScreen(
            onGuestLogin: () {
              print("게스트 로그인 클릭");
            },
            onSocialLogin: (provider) async {
              print("🖱️ $provider 로그인 시도");

              if (provider == 'google') {
                await AuthService().signInWithGoogle();
              }
              else if (provider == 'naver') {
                await AuthService().signInWithNaver();
              }
              else if (provider == 'kakao') {
                await AuthService().signInWithKakao();
              }
            },
          );
        },
      ),
    );
  }
}