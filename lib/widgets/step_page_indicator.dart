import 'package:flutter/material.dart';

class StepPageIndicator extends StatelessWidget {
  final int currentStep; // 현재 단계 (0부터 시작)
  final int totalSteps;
  final Function(int) onDotTapped;

  const StepPageIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final bool isActive = index == currentStep;

          Color color = Colors.grey.shade300;
          if (isActive) color = const Color(0xFFF9A825);

          // `AnimatedContainer`로 부드러운 전환 효과
          return GestureDetector(
            onTap: () => onDotTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              // `w-6` (active) vs `w-2` (inactive)
              width: isActive ? 24.0 : 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}