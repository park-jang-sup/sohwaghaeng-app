import 'package:flutter/material.dart';

/// .tsx의 HistoryTabProps에 정의된 CompletedMission 인터페이스
class CompletedMission {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime completedAt;
  bool hasPhoto;
  List<String>? photos; // .tsx의 photos: string[]
  String? representativePhoto;
  final bool isPublic;
  final bool isImported;

  CompletedMission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.completedAt,
    this.hasPhoto = false,
    this.photos,
    this.representativePhoto,
    required this.isPublic,
    required this.isImported,
  });
}

// .tsx의 `completedMissions` 샘플 데이터를 Dart로 변환
// (실제 앱에서는 AppShell이나 DB에서 이 데이터를 받아와야 합니다)
final List<CompletedMission> sampleCompletedMissions = [
  CompletedMission(
    id: '1',
    title: '아침 햇살과 함께 스트레칭',
    description: '10분간 간단한 요가 동작으로 하루를 시작해보기',
    category: '건강',
    completedAt: DateTime.now(),
    hasPhoto: true,
    photos: [
      'https://images.unsplash.com/photo-1602520628350-fbf9db1f02ae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3JuaW5nJTIweW9nYSUyMHN0cmV0Y2h8ZW58MXx8fHwxNzU5MTAyMDM0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'https://images.unsplash.com/photo-1524863479829-916d8e77f114?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwbmF0dXJlfGVufDF8fHx8MTc1OTEwMjA0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    ],
    representativePhoto: 'https://images.unsplash.com/photo-1602520628350-fbf9db1f02ae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3JuaW5nJTIweW9nYSUyMHN0cmV0Y2h8ZW58MXx8fHwxNzU5MTAyMDM0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isPublic: true,
    isImported: false,
  ),
  CompletedMission(
    id: '2',
    title: '좋아하는 음악 한 곡 완전히 듣기',
    description: '오늘 기분에 맞는 노래를 찾아 온전히 집중해서 듣기',
    category: '힐링',
    completedAt: DateTime.now(),
    hasPhoto: true,
    photos: ['https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGhlYWRwaG9uZXN8ZW58MXx8fHwxNzU5MTAyMDQwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    representativePhoto: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGhlYWRwaG9uZXN8ZW58MXx8fHwxNzU5MTAyMDQwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isPublic: false,
    isImported: true,
  ),
  CompletedMission(
    id: '3',
    title: '길에서 예쁜 꽃 사진 찍기',
    description: '산책하면서 마음에 드는 꽃이나 식물 사진 남기기',
    category: '활동',
    completedAt: DateTime.now().subtract(const Duration(days: 1)),
    hasPhoto: true,
    photos: [
      'https://images.unsplash.com/photo-1658277706068-4b8292918395?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmbG93ZXIlMjBwaG90b2dyYXBoeXxlbnwxfHx8fDE3NTkxMDIwMzd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'https://images.unsplash.com/photo-1625720375970-137907e1de41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxnYXJkZW4lMjBmbG93ZXJzfGVufDF8fHx8MTc1OTEwMjA0Nnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    ],
    representativePhoto: 'https://images.unsplash.com/photo-1658277706068-4b8292918395?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmbG93ZXIlMjBwaG90b2dyYXBoeXxlbnwxfHx8fDE3NTkxMDIwMzd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isPublic: true,
    isImported: false,
  ),
  CompletedMission(
    id: '4',
    title: '소중한 사람에게 고마움 표현하기',
    description: '평소 고마웠던 마음을 진심을 담아 전달해보기',
    category: '마음',
    completedAt: DateTime.now().subtract(const Duration(days: 1)),
    hasPhoto: true,
    photos: ['https://images.unsplash.com/photo-1618241412779-8b7b5e0b1e2f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kcyUyMGhlYXJ0fGVufDF8fHx8MTc1OTEwMjA0NHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'],
    representativePhoto: 'https://images.unsplash.com/photo-1618241412779-8b7b5e0b1e2f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYW5kcyUyMGhlYXJ0fGVufDF8fHx8MTc1OTEwMjA0NHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isPublic: false,
    isImported: false,
  ),
  CompletedMission(
    id: '5',
    title: '새로운 카페에서 커피 한 잔',
    description: '평소 가지 않던 새로운 장소에서 여유로운 시간 보내기',
    category: '탐험',
    completedAt: DateTime.now().subtract(const Duration(days: 2)),
    hasPhoto: true,
    photos: [
      'https://images.unsplash.com/photo-1705818674246-40d7ecaacfea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjYWZlJTIwY29mZmVlJTIwY3VwfGVufDF8fHx8MTc1OTEwMjA0MHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'https://images.unsplash.com/photo-1521017432531-fbd92d768814?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBzaG9wJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4OTkwMzQxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    ],
    representativePhoto: 'https://images.unsplash.com/photo-1705818674246-40d7ecaacfea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjYWZlJTIwY29mZmVlJTIwY3VwfGVufDF8fHx8MTc1OTEwMjA0MHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isPublic: true,
    isImported: false,
  ),
];