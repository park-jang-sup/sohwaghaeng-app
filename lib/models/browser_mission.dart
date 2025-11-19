import 'package:flutter/material.dart';

class BrowserMission {
  final String id;
  final String title;
  final String description;
  final String tag;
  final IconData icon;
  final int likes;
  final String? author; // [수정 1] author 필드 추가 (nullable)

  BrowserMission({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
    required this.likes,
    this.author, // [수정 2] 생성자에 author 추가
  });
}

// 샘플 데이터에도 author 정보를 추가하거나 비워둘 수 있습니다.
final List<BrowserMission> allSampleMissions = [
  BrowserMission(
    id: 'b1',
    title: '하루 2L 물 마시기',
    description: '건강을 위해 수분을 충분히 섭취하세요.',
    tag: '건강',
    icon: Icons.water_drop,
    likes: 120,
    author: 'B612 관리자', // 예시 데이터 추가
  ),
  BrowserMission(
    id: 'b2',
    title: '아침 스트레칭',
    description: '상쾌한 아침을 여는 5분 스트레칭.',
    tag: '운동',
    icon: Icons.accessibility_new,
    likes: 85,
    author: '요가마스터',
  ),
  BrowserMission(
    id: 'b3',
    title: '식물에 물 주기',
    description: '반려 식물과 교감하는 시간.',
    tag: '일상',
    icon: Icons.local_florist,
    likes: 45,
    // author는 nullable(?String)이므로 생략 가능합니다.
  ),
  BrowserMission(
    id: 'b4',
    title: '하늘 사진 찍기',
    description: '가끔은 고개를 들어 하늘을 보세요.',
    tag: '감성',
    icon: Icons.camera_alt,
    likes: 210,
    author: 'SkyLover',
  ),
  BrowserMission(
    id: 'b5',
    title: '감사일기 쓰기',
    description: '오늘 하루 감사했던 일 3가지 적기.',
    tag: '마음',
    icon: Icons.edit_note,
    likes: 300,
  ),
  BrowserMission(
    id: 'b6',
    title: '명상 10분',
    description: '복잡한 생각을 비우는 시간.',
    tag: '휴식',
    icon: Icons.self_improvement,
    likes: 150,
  ),
];