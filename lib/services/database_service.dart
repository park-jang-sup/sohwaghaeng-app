import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ 현재 로그인한 사용자 UID 가져오기
  String? get currentUserId => _auth.currentUser?.uid;

  // ===============================================================
  // 1. 구글 유저 정보 저장
  // ===============================================================
  Future<void> saveUser(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'nickname': user.displayName ?? '이름 없음',
        'photo_url': user.photoURL,
        'last_login': DateTime.now(),
        'social_type': 'google',
      }, SetOptions(merge: true));

      print("✅ 구글 유저 정보 DB 저장 완료! (${user.displayName})");
    } catch (e) {
      print("❌ 구글 유저 정보 저장 실패: $e");
    }
  }

  // ===============================================================
  // 2. 네이버/카카오 유저 정보 저장
  // ===============================================================
  Future<void> saveSocialUser({
    required String uid,
    required String email,
    required String nickname,
    String? photoUrl,
    required String socialType,
  }) async {
    try {
      // ✅ Firebase Auth UID로 저장 (소셜 UID와 매핑)
      final firebaseUid = _auth.currentUser?.uid;

      await _db.collection('users').doc(firebaseUid).set({
        'social_uid': uid,
        'email': email,
        'nickname': nickname,
        'photo_url': photoUrl,
        'last_login': DateTime.now(),
        'social_type': socialType,
      }, SetOptions(merge: true));

      print("✅ $socialType 유저 정보 DB 저장 완료! ($nickname)");
    } catch (e) {
      print("❌ $socialType 유저 정보 저장 실패: $e");
    }
  }

  // [조회] 내 정보 가져오기
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // ✅ [조회] 현재 로그인한 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUserId == null) return null;

    try {
      final doc = await _db.collection('users').doc(currentUserId).get();
      return doc.data();
    } catch (e) {
      print("❌ 사용자 정보 조회 실패: $e");
      return null;
    }
  }

  // ===============================================================
  // 3. 미션 관련 (✅ 사용자별 분리!)
  // ===============================================================

  // ✅ [실시간 구독] 현재 사용자의 미션만 가져오기
  Stream<QuerySnapshot> getMissionsStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _db
        .collection('missions')
        .where('user_id', isEqualTo: currentUserId)  // ✅ 사용자 필터 추가!
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ✅ [추가] 미션 추가하기 (사용자 ID 포함)
  Future<void> addMission({
    required String title,
    required String description,
    required String tag,
    required int iconCode,
    String? author,
  }) async {
    if (currentUserId == null) {
      print("❌ 로그인이 필요합니다.");
      return;
    }

    try {
      await _db.collection('missions').add({
        'user_id': currentUserId,  // ✅ 사용자 ID 추가!
        'title': title,
        'description': description,
        'tag': tag,
        'icon_code': iconCode,
        'completed': false,
        'likes': 0,
        'author': author ?? '익명',
        'timestamp': DateTime.now(),
      });
      print("✅ 미션 추가 완료!");
    } catch (e) {
      print("❌ 미션 추가 에러: $e");
    }
  }

  // [수정] 미션 수정하기
  Future<void> updateMission(String missionId, Map<String, dynamic> data) async {
    try {
      await _db.collection('missions').doc(missionId).update(data);
      print("✅ 미션 수정 완료!");
    } catch (e) {
      print("❌ 미션 수정 에러: $e");
    }
  }

  // [삭제] 미션 삭제하기
  Future<void> deleteMission(String missionId) async {
    try {
      await _db.collection('missions').doc(missionId).delete();
      print("✅ 미션 삭제 완료!");
    } catch (e) {
      print("❌ 미션 삭제 에러: $e");
    }
  }

  // ===============================================================
  // 4. 미션 인증 & 활동 저장
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

  // ✅ [실시간 구독] 완료한 미션 목록 스트림으로 가져오기
  Stream<QuerySnapshot> getCompletedMissionsStream(String uid) {
    return _db
        .collection('completed_missions')
        .where('user_uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ===============================================================
  // [관리자용] 초기 데이터 업로드
  // ===============================================================
  Future<void> uploadSampleMissions() async {
    final List<Map<String, dynamic>> sampleMissions = [
      {
        'title': '하루 2L 물 마시기',
        'description': '건강을 위해 수분을 충분히 섭취하세요.',
        'tag': '건강',
        'icon_code': Icons.water_drop.codePoint,
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
    ];

    print("⏳ 샘플 미션 업로드 시작...");
    for (var mission in sampleMissions) {
      final QuerySnapshot existing = await _db
          .collection('missions')
          .where('title', isEqualTo: mission['title'])
          .get();

      if (existing.docs.isEmpty) {
        await _db.collection('missions').add({
          'title': mission['title'],
          'description': mission['description'],
          'tag': mission['tag'],
          'likes': mission['likes'],
          'author': mission['author'],
          'icon_code': mission['icon_code'],
          'timestamp': DateTime.now(),
        });
      }
    }
    print("✅ 샘플 데이터 확인 완료!");
  }
}