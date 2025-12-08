import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// .tsx의 iconMap을 Dart의 Map으로 변환합니다.
/// 태그(String)를 IconData로 매핑합니다.
final Map<String, IconData> iconMap = {
  'wellness': Icons.wb_sunny_outlined, // sun -> wb_sunny_outlined
  'daily': Icons.coffee_outlined, // coffee -> coffee_outlined
  'growth': Icons.book_outlined, // book -> book_outlined
  'happiness': Icons.sentiment_satisfied_alt_outlined, // smile -> sentiment_satisfied_alt_outlined
  'love': Icons.favorite_border, // heart -> favorite_border
  'goal': Icons.ads_click, // target -> ads_click (유사한 아이콘)
  'energy': Icons.bolt, // zap -> bolt
  'achievement': Icons.star_border, // star -> star_border
  'nature': Icons.cloud_outlined, // nature -> cloud_outlined (또는 park_outlined)
  'mindful': Icons.spa_outlined, // leaf -> spa_outlined
  'creative': Icons.music_note_outlined, // music -> music_note_outlined
  'hobby': Icons.camera_alt_outlined, // camera -> camera_alt_outlined
  'beauty': Icons.local_florist_outlined, // flower -> local_florist_outlined
  'routine': Icons.access_time, // clock -> access_time
};

/// 태그 ID에 맞는 아이콘을 반환합니다.
IconData getIconForTag(String tagId) {
  return iconMap[tagId] ?? Icons.sentiment_satisfied_alt_outlined; // 기본값
}