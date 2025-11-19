import 'package:flutter/material.dart';
// import 'package:lucide_flutter/lucide_flutter.dart'; // [수정] 삭제해주세요.

class Mission {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String tag;
  final IconData icon;
  final String? photo;
  final String? completedAt;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    required this.tag,
    required this.icon,
    this.photo,
    this.completedAt,
  });

  static List<Mission> getSampleMissions() {
    return [
      Mission(
        id: '1',
        title: '아침 산책하기',
        description: '공원에서 30분간 신선한 공기를 마시며 걷습니다.',
        tag: '건강',
        // [수정 1] LucideIcons.sun -> Icons.wb_sunny
        icon: Icons.wb_sunny,
      ),
      Mission(
        id: '2',
        title: '좋아하는 책 1챕터 읽기',
        description: '커피 한 잔과 함께 조용한 시간을 즐깁니다.',
        tag: '휴식',
        // [수정 2] LucideIcons.bookOpen -> Icons.menu_book
        icon: Icons.menu_book,
      ),
      Mission(
        id: '3',
        title: '친구에게 감사 메시지 보내기',
        description: '작은 일이라도 고마웠던 점을 문자로 전합니다.',
        tag: '관계',
        // [수정 3] LucideIcons.messageSquare -> Icons.chat_bubble_outline
        icon: Icons.chat_bubble_outline,
        completed: true,
      ),
    ];
  }
}