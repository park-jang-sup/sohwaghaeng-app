import 'package:flutter/material.dart';
// import 'package:lucide_flutter/lucide_flutter.dart'; // [수정] 삭제
import 'package:b612_1/widgets/gradient_button.dart';
import 'package:b612_1/widgets/step_page_indicator.dart';
import 'package:b612_1/widgets/step_progress_bar.dart';

// --- 데이터 모델 ---
class IntroStepData {
  final Widget icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;

  IntroStepData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
  });
}

// [수정] LucideIcons -> Icons (Material)로 변경
final List<IntroStepData> _introSteps = [
  IntroStepData(
    // LucideIcons.search -> Icons.search
    icon: const Icon(Icons.search, size: 64.0, color: Color(0xFFF97316)),
    title: "탐색 탭",
    subtitle: "새로운 미션 발견하기",
    description: "다른 사용자들이 공유한 다양한 소확행 미션을 탐색하고, 나만의 리스트에 추가해보세요.",
    features: ["카테고리별 미션 탐색", "인기 미션 추천", "나만의 미션 추가"],
  ),
  IntroStepData(
    // LucideIcons.calendar -> Icons.calendar_today
    icon: const Icon(Icons.calendar_today, size: 64.0, color: Color(0xFFF97316)),
    title: "오늘 탭",
    subtitle: "오늘의 소확행 실천하기",
    description: "하루 단위로 미션을 관리하고, 완료한 미션에 사진을 첨부하여 소중한 순간을 기록해보세요.",
    features: ["일일 미션 관리", "미션 완료 체크", "사진으로 기록 남기기"],
  ),
  IntroStepData(
    // LucideIcons.bookOpen -> Icons.menu_book
    icon: const Icon(Icons.menu_book, size: 64.0, color: Color(0xFFF97316)),
    title: "나의 기록 탭",
    subtitle: "소확행 여정 되돌아보기",
    description: "완료한 미션들을 달력으로 확인하고, 첨부한 사진들로 나만의 소확행 앨범을 만들어보세요.",
    features: ["달력으로 기록 확인", "사진 앨범 보기", "성취 통계 확인"],
  ),
];

// --- 메인 위젯 ---
class OnboardingIntroScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const OnboardingIntroScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  int _currentStep = 0;

  void _handleNext() {
    if (_currentStep < _introSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void _handlePrev() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      widget.onBack();
    }
  }

  void _handleDotTapped(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = _currentStep == _introSteps.length - 1;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 상단 진행률 바 ---
                StepProgressBar(
                  currentStep: _currentStep + 1,
                  totalSteps: _introSteps.length,
                  onBack: _handlePrev,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: _buildIntroCard(
                          context,
                          key: ValueKey<int>(_currentStep),
                          data: _introSteps[_currentStep],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- 하단 버튼 ---
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: GradientButton(
                    text: isLastStep ? "시작하기" : "다음",
                    onPressed: _handleNext,
                  ),
                ),

                // --- 건너뛰기 버튼 ---
                TextButton(
                  onPressed: widget.onComplete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                  ),
                  child: const Text("건너뛰기"),
                ),

                // --- 하단 점 인디케이터 ---
                StepPageIndicator(
                  currentStep: _currentStep,
                  totalSteps: _introSteps.length,
                  onDotTapped: _handleDotTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context,
      {required Key key, required IntroStepData data}) {
    return Card(
      key: key,
      elevation: 8.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            data.icon,
            const SizedBox(height: 24.0),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: data.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildFeatureItem(feature),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Color(0xFFF9A825),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          feature,
          style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}