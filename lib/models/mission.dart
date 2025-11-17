import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';


class Mission {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String tag;
  final IconData icon; // ReactNode 대신 IconData를 사용
  final String? photo; // 사진 경로 (String?)
  final String? completedAt; // String?

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

  // .tsx 파일은 props로 데이터를 받지만,
  // Flutter에서는 앱 실행 시 초기 데이터가 필요할 수 있으므로
  // 샘플 데이터를 만드는 메서드를 여기에 포함해두면 유용합니다.
  // (이 부분은 예시이며, 실제로는 외부 DB나 API에서 데이터를 불러와야 합니다)
  static List<Mission> getSampleMissions() {
    return [
      Mission(
        id: '1',
        title: '아침 산책하기',
        description: '공원에서 30분간 신선한 공기를 마시며 걷습니다.',
        tag: '건강',
        icon: LucideIcons.sun,
      ),
      Mission(
        id: '2',
        title: '좋아하는 책 1챕터 읽기',
        description: '커피 한 잔과 함께 조용한 시간을 즐깁니다.',
        tag: '휴식',
        icon: LucideIcons.bookOpen,
      ),
      Mission(
        id: '3',
        title: '친구에게 감사 메시지 보내기',
        description: '작은 일이라도 고마웠던 점을 문자로 전합니다.',
        tag: '관계',
        icon: LucideIcons.messageSquare,
        completed: true,
      ),
    ];
  }
}