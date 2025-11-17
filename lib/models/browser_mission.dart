import 'package:flutter/material.dart';
import 'package:b612_1/utils/icon_mapper.dart'; // iconMap을 사용하기 위해

/// .tsx의 MissionBrowserProps에 정의된 Mission 인터페이스
class BrowserMission {
  final String id;
  final String title;
  final String description;
  final String tag;
  final IconData icon;
  final String? author;
  final int likes;

  BrowserMission({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
    this.author,
    this.likes = 0,
  });
}

// .tsx의 `allSampleMissions` 데이터를 Dart로 변환
// (실제 앱에서는 이 부분이 API 호출로 대체되어야 합니다)
final List<BrowserMission> allSampleMissions = [
  BrowserMission(
      id: '1', title: '아침에 따뜻한 차 한 잔 마시기', description: '하루를 여유롭게 시작하는 작은 의식',
      tag: 'wellness', icon: getIconForTag('wellness'), author: '차러버', likes: 127
  ),
  BrowserMission(
      id: '2', title: '창문을 열고 신선한 공기 마시기', description: '5분만 창문을 열어두고 깊게 호흡하기',
      tag: 'wellness', icon: getIconForTag('wellness'), author: '건강한하루', likes: 89
  ),
  BrowserMission(
      id: '3', title: '좋아하는 노래 한 곡 들으며 춤추기', description: '아무도 안 볼 때 자유롭게 몸을 움직이기',
      tag: 'happiness', icon: getIconForTag('happiness'), author: '댄싱퀸', likes: 203
  ),
  BrowserMission(
      id: '4', title: '점심시간에 밖에 나가 햇볕 쬐기', description: '실내에만 있지 말고 잠깐이라도 외출하기',
      tag: 'nature', icon: getIconForTag('nature'), author: '햇살좋아', likes: 156
  ),
  BrowserMission(
      id: '5', title: '가족이나 친구에게 안부 메시지 보내기', description: '소중한 사람에게 간단한 인사말 전하기',
      tag: 'love', icon: getIconForTag('love'), author: '소통왕', likes: 78
  ),
  BrowserMission(
      id: '6', title: '책 한 페이지 읽기', description: '짧은 시간이라도 독서하는 습관 만들기',
      tag: 'growth', icon: getIconForTag('growth'), author: '북러버', likes: 134
  ),
  BrowserMission(
      id: '7', title: '오늘 감사한 일 하나 떠올리기', description: '하루 중 작은 감사함을 찾아보기',
      tag: 'mindful', icon: getIconForTag('mindful'), author: '감사일기', likes: 245
  ),
  BrowserMission(
      id: '8', title: '스마트폰 없이 10분 보내기', description: '디지털 디톡스하며 현재에 집중하기',
      tag: 'mindful', icon: getIconForTag('mindful'), author: '미니멀라이프', likes: 192
  ),
  BrowserMission(
      id: '9', title: '간단한 스트레칭 하기', description: '목과 어깨 긴장을 풀어주는 시간',
      tag: 'wellness', icon: getIconForTag('wellness'), author: '스트레칭마스터', likes: 167
  ),
  BrowserMission(
      id: '10', title: '예쁜 사진 한 장 찍기', description: '일상 속 아름다운 순간 포착하기',
      tag: 'creative', icon: getIconForTag('creative'), author: '사진작가', likes: 98
  ),
  BrowserMission(
      id: '11', title: '좋아하는 향의 캔들 켜기', description: '향기로 기분 좋은 공간 만들기',
      tag: 'beauty', icon: getIconForTag('beauty'), author: '향기수집가', likes: 112
  ),
  BrowserMission(
      id: '12', title: '물 한 잔 천천히 마시기', description: '의식적으로 수분 섭취하며 몸 챙기기',
      tag: 'wellness', icon: getIconForTag('wellness'), author: '건강지킴이', likes: 73
  ),
  BrowserMission(
      id: '13', title: '깊게 숨쉬기 연습', description: '4-7-8 호흡법으로 마음을 진정시키기',
      tag: 'mindful', icon: getIconForTag('mindful'), author: '호흡마스터', likes: 188
  ),
  BrowserMission(
      id: '14', title: '좋아하는 시 한 편 읽기', description: '아름다운 언어로 마음을 채우는 시간',
      tag: 'growth', icon: getIconForTag('growth'), author: '시인의마음', likes: 142
  ),
  BrowserMission(
      id: '15', title: '발가락 스트레칭하기', description: '하루 종일 신발 속에 갇힌 발에게 자유를',
      tag: 'wellness', icon: getIconForTag('wellness'), author: '발건강지킴이', likes: 91
  ),
  BrowserMission(
      id: '16', title: '하늘 올려다보기', description: '잠깐 멈춰서 하늘의 변화를 관찰하기',
      tag: 'nature', icon: getIconForTag('nature'), author: '하늘관찰자', likes: 167
  ),
];