import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // 파이어스토어 인스턴스를 하나만 생성해서 계속 씀 (Singleton 패턴 응용)
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. 데이터 저장하기 (Create)
  // 예: 사용자 정보 저장, 미션 성공 기록 등
  Future<void> saveMissionData(String missionTitle, String content) async {
    try {
      await _db.collection('missions').add({
        'title': missionTitle,
        'content': content,
        'timestamp': DateTime.now(), // 언제 저장했는지
      });
      print("미션 저장 완료!");
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  // 2. 데이터 불러오기 (Read)
  // 저장된 미션 목록을 가져오는 스트림(실시간 업데이트)
  Stream<QuerySnapshot> getMissions() {
    return _db.collection('missions').orderBy('timestamp', descending: true).snapshots();
  }
}