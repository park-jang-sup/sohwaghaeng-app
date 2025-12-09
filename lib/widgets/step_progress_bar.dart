import 'package:flutter/material.dart';
//import 'package:b612_1/widgets/custom_back_button.dart';

/// PersonalityTest, OnboardingIntro 등
/// 여러 단계의 화면에서 공통으로 사용하는 상단바입니다.
class StepProgressBar extends StatelessWidget {
  final int currentStep; // 현재 단계 (1부터 시작)
  final int totalSteps;  // 전체 단계 수
  final VoidCallback onBack;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // 0.0 ~ 1.0 사이의 진행률 값
    final double progress = currentStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. 이전에 만든 공용 뒤로가기 버튼 재사용
              CustomBackButton(onPressed: onBack),
              // `span (counter)`
              Text(
                '$currentStep / $totalSteps',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
              ),
              // `w-10` (공간 채우기)
              const SizedBox(width: 40.0),
            ],
          ),
          const SizedBox(height: 16.0),
          // `Progress`
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress,
              // `h-2`
              minHeight: 8.0,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFF9A825), // 오렌지색
            ),
          ),
        ],
      ),
    );
  }
}
