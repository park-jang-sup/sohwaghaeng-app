import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// .tsx의 iconMap을 Dart의 Map으로 변환합니다.
/// 태그(String)를 IconData로 매핑합니다.
final Map<String, IconData> iconMap = {
  'wellness': LucideIcons.sun,
  'daily': LucideIcons.coffee,
  'growth': LucideIcons.book,
  'happiness': LucideIcons.smile,
  'love': LucideIcons.heart,
  'goal': LucideIcons.target,
  'energy': LucideIcons.zap,
  'achievement': LucideIcons.star,
  'nature': LucideIcons.treePine,
};

/// 태그 ID에 맞는 아이콘을 반환합니다.
/// 커스텀 태그 아이콘도 여기서 관리할 수 있습니다.
IconData getIconForTag(String tagId) {
  // TODO: customTags 목록에서 tagId를 찾는 로직 추가
  // (예: if (tagId.startsWith('custom-')) ... )

  // 기본 맵에서 아이콘을 찾고, 없으면 기본 아이콘 반환
  return iconMap[tagId] ?? LucideIcons.smile;
}