import 'package:flutter/material.dart';
// [필수 1] 파이어베이스 코어
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// [필수 3] DB 서비스
import 'package:b612_1/services/database_service.dart';

// 기존 패키지들
import 'package:b612_1/app_shell.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 파이어베이스 초기화
  // 위에서 import 'firebase_options.dart'를 했기 때문에
  // 이제 DefaultFirebaseOptions를 알아들을 수 있습니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. 한국어 날짜 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // [관리자용] 초기 데이터 DB 업로드 (필요할 때만 주석 풀기)
  // await DatabaseService().uploadSampleMissions();

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