import 'package:flutter/material.dart';
// 1. [수정] AppShell을 import 합니다.
import 'package:b612_1/app_shell.dart';
// 2. [추가] intl 패키지의 날짜 초기화 라이브러리를 import 합니다.
import 'package:intl/date_symbol_data_local.dart';

// 3. [수정] main 함수를 async로 변경합니다.
void main() async {
  // 4. [추가] Flutter 바인딩을 초기화합니다. (async-await을 main에서 사용하기 위함)
  WidgetsFlutterBinding.ensureInitialized();

  // 5. [추가] 앱을 실행하기 전에 한국어 날짜 데이터를 미리 불러옵니다.
  await initializeDateFormatting('ko_KR', null);

  // 6. 앱을 실행합니다.
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
      // AppShell이 앱의 홈이 됩니다.
      home: const AppShell(),
    );
  }
}