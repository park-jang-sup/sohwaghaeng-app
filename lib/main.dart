import 'package:flutter/material.dart';
// [필수] 파이어베이스 관련 패키지
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// [참고] 방금 만든 DB 서비스
// (지금 main.dart에서는 안 쓰니까 다시 회색으로 변할 수 있습니다.
//  하지만 나중에 다른 파일에서 쓰면 되니 걱정 마세요!)
import 'package:b612_1/services/database_service.dart';

// 기존 패키지들
import 'package:b612_1/app_shell.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 파이어베이스 초기화 (서버 연결 유지)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. 한국어 날짜 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // 4. 앱 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: const AppShell(),
    );
  }
}