import 'package:flutter/material.dart';

class Mission {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String tag;
  final String icon; // React의 아이콘 ID (예: 'sun', 'book')
  final String color; // Hex String (예: '#FFD6A5')
  final String? photo; // 사진 경로
  final String? completedAt; // ISO8601 String
  final String? time; // "HH:mm"
  final bool isPublic;
  final String source; // 'mine', 'imported', 'friend'

  Mission({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.tag = 'daily',
    this.icon = 'sun',
    this.color = '#FFFFFF',
    this.photo,
    this.completedAt,
    this.time,
    this.isPublic = false,
    this.source = 'mine',
  });

  // 복사본 생성을 위한 copyWith 메서드
  Mission copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? tag,
    String? icon,
    String? color,
    String? photo,
    String? completedAt,
    String? time,
    bool? isPublic,
    String? source,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      tag: tag ?? this.tag,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      photo: photo ?? this.photo,
      completedAt: completedAt ?? this.completedAt,
      time: time ?? this.time,
      isPublic: isPublic ?? this.isPublic,
      source: source ?? this.source,
    );
  }

  // 아이콘 ID를 Flutter IconData로 변환하는 헬퍼 메서드
  IconData get iconData {
    switch (icon) {
      case 'sun': return Icons.wb_sunny_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'leaf': return Icons.eco_rounded;
      case 'heart': return Icons.favorite_rounded;
      case 'coffee': return Icons.coffee_rounded;
      case 'star': return Icons.star_rounded;
      case 'tree': return Icons.park_rounded;
      case 'zap': return Icons.bolt_rounded;
      case 'flame': return Icons.local_fire_department_rounded;
      case 'water_drop': return Icons.water_drop_rounded; // 추가됨
      default: return Icons.wb_sunny_rounded;
    }
  }

  // 샘플 데이터 생성
  static List<Mission> getSampleMissions() {
    return [
      Mission(
        id: '1',
        title: '아침 물 한 잔 마시기',
        description: '일어나자마자 미지근한 물 한 잔',
        completed: false,
        tag: 'wellness',
        icon: 'water_drop',
        color: '#A0C4FF', // Blue
        source: 'mine',
      ),
      Mission(
        id: '2',
        title: '책 10페이지 읽기',
        description: '자기 전 독서 습관',
        completed: true,
        tag: 'growth',
        icon: 'book',
        color: '#FFD6A5', // Orange
        source: 'imported',
      ),
      Mission(
        id: '3',
        title: '하늘 사진 찍기',
        description: '점심 시간에 하늘 보기',
        completed: false,
        tag: 'daily',
        icon: 'sun',
        color: '#CAFFBF', // Green
        source: 'mine',
      ),
    ];
  }
}