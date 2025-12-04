import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // 아이콘 데이터 처리를 위해 필요

class DatabaseService {
  // 파이어스토어 인스턴스 (관리자)
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================================================
  // 1. users (회원 정보) 관련 기능
  // ===============================================================

  // [생성/수정] 회원 정보 저장하기 (회원가입/로그인 시 사용)
  Future<void> saveUser(String uid, String nickname, String mbti, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'nickname': nickname,
        'mbti': mbti,
        'email': email,
        'level': 1, // 초기 레벨
        'created_at': DateTime.now(),
      });
      print("✅ 회원 정보 저장 완료!");
    } catch (e) {
      print("❌ 회원 저장 에러: $e");
    }
  }

  // [조회] 특정 회원 정보 가져오기
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // ===============================================================
  // 2. missions (미션 목록) 관련 기능
  // ===============================================================

  // [조회] 모든 미션 목록 실시간으로 가져오기
  Stream<QuerySnapshot> getMissions() {
    // timestamp 기준으로 정렬해서 가져오기
    return _db.collection('missions').orderBy('timestamp', descending: false).snapshots();
  }

  // ===============================================================
  // 3. completed_missions (미션 인증) 관련 기능
  // ===============================================================

  // [생성] 미션 완료 인증 저장하기
  Future<void> completeMission(String uid, String missionTitle, String review, String photoUrl) async {
    try {
      await _db.collection('completed_missions').add({
        'user_uid': uid,
        'mission_title': missionTitle,
        'review': review,
        'photo_url': photoUrl,
        'timestamp': DateTime.now(),
      });
      print("✅ 미션 인증 저장 완료!");
    } catch (e) {
      print("❌ 미션 인증 에러: $e");
    }
  }

  // ===============================================================
  // [관리자용] 초기 데이터 업로드 기능 (Main에서 한번만 실행)
  // ===============================================================
  Future<void> uploadSampleMissions() async {
    // 사용자님이 주신 BrowserMission 샘플 데이터
    final List<Map<String, dynamic>> sampleMissions = [
      {
        'title': '하루 2L 물 마시기',
        'description': '건강을 위해 수분을 충분히 섭취하세요.',
        'tag': '건강',
        'icon_code': Icons.water_drop.codePoint, // 아이콘을 숫자로 저장
        'likes': 120,
        'author': 'B612 관리자',
      },
      {
        'title': '아침 스트레칭',
        'description': '상쾌한 아침을 여는 5분 스트레칭.',
        'tag': '운동',
        'icon_code': Icons.accessibility_new.codePoint,
        'likes': 85,
        'author': '요가마스터',
      },
      {
        'title': '식물에 물 주기',
        'description': '반려 식물과 교감하는 시간.',
        'tag': '일상',
        'icon_code': Icons.local_florist.codePoint,
        'likes': 45,
        'author': null, // 작가 없음
      },
      {
        'title': '하늘 사진 찍기',
        'description': '가끔은 고개를 들어 하늘을 보세요.',
        'tag': '감성',
        'icon_code': Icons.camera_alt.codePoint,
        'likes': 210,
        'author': 'SkyLover',
      },
      {
        'title': '감사일기 쓰기',
        'description': '오늘 하루 감사했던 일 3가지 적기.',
        'tag': '마음',
        'icon_code': Icons.edit_note.codePoint,
        'likes': 300,
        'author': null,
      },
      {
        'title': '명상 10분',
        'description': '복잡한 생각을 비우는 시간.',
        'tag': '휴식',
        'icon_code': Icons.self_improvement.codePoint,
        'likes': 150,
        'author': null,
      },
    ];

    print("⏳ 샘플 미션 업로드 시작...");

    for (var mission in sampleMissions) {
      // 중복 방지를 위해 title이 같은 게 있는지 확인 후 없으면 추가
      final QuerySnapshot existing = await _db
          .collection('missions')
          .where('title', isEqualTo: mission['title'])
          .get();

      if (existing.docs.isEmpty) {
        await _db.collection('missions').add({
          'title': mission['title'],
          'description': mission['description'], // category 역할 겸함
          'tag': mission['tag'],
          'likes': mission['likes'],
          'author': mission['author'],
          'icon_code': mission['icon_code'], // 아이콘 정보 (숫자)
          'timestamp': DateTime.now(),
        });
        print(" -> 업로드 성공: ${mission['title']}");
      } else {
        print(" -> 이미 있음 (건너뜀): ${mission['title']}");
      }
    }
    print("✅ 모든 샘플 데이터 업로드 작업 완료!");
  }
}