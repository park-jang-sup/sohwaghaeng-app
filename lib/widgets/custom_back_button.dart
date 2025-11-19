import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// React의 `variant="ghost"` 뒤로가기 버튼에 해당합니다.
class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // `h-10 w-10 rounded-full bg-white/50 ... shadow-sm`
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        // [수정] LucideIcons.chevronLeft -> Icons.arrow_back_ios_new (기본 아이콘)
        icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
        color: Colors.grey.shade800,
      ),
    );
  }
}