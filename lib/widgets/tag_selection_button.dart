import 'package:flutter/material.dart';

class TagSelectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const TagSelectionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // .tsx의 className에 따라 스타일을 분기합니다.
    final Color borderColor = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200;
    final Color backgroundColor = isSelected ? Colors.orange.shade50 : Colors.white;
    final Color textColor = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600;
    final double scale = isSelected ? 1.05 : 1.0;

    // `AnimatedContainer`로 부드러운 스케일 효과
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          alignment: Alignment.centerLeft,
        ),
        icon: Icon(icon, size: 20.0, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}