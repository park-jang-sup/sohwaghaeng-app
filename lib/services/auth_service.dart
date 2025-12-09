import 'dart:async';
import 'dart:convert';  // ✅ 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:b612_1/services/database_service.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await DatabaseService().saveUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("구글 로그인 에러: $e");
      return null;
    }
  }

  // 2. 네이버 로그인 (v3.x 콜백 방식)
  Future<bool> signInWithNaver() async {
    final completer = Completer<bool>();

    NaverLoginSDK.authenticate(
      callback: OAuthLoginCallback(
        onSuccess: () {
          print("✅ 네이버 로그인 성공!");
          _fetchNaverProfile(completer);
        },
        onFailure: (errorCode, message) {
          print("❌ 네이버 로그인 실패: $errorCode - $message");
          completer.complete(false);
        },
        onError: (errorCode, message) {
          print("❌ 네이버 로그인 에러: $errorCode - $message");
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  // 네이버 프로필 가져오기 (JSON 파싱 수정)
  void _fetchNaverProfile(Completer<bool> completer) {
    NaverLoginSDK.profile(
      callback: ProfileCallback(
        onSuccess: (resultCode, message, response) async {
          print("✅ 프로필 응답: $response");

          try {
            // ✅ response가 JSON 문자열이므로 파싱
            final Map<String, dynamic> profileData = jsonDecode(response.toString());

            final String id = profileData['id'] ?? '';
            final String email = profileData['email'] ?? 'naver_user@temp.com';
            final String nickname = profileData['nickname'] ?? profileData['name'] ?? '네이버 사용자';
            final String? profileImage = profileData['profileImage'];

            print("✅ 파싱된 프로필: $nickname, $email");

            // Firebase 익명 로그인
            await _auth.signInAnonymously();

            // 사용자 정보 저장
            await DatabaseService().saveSocialUser(
              uid: "naver_$id",
              email: email,
              nickname: nickname,
              photoUrl: profileImage,
              socialType: 'naver',
            );

            completer.complete(true);
          } catch (e) {
            print("프로필 처리 에러: $e");

            // 프로필 파싱 실패해도 로그인은 시도
            try {
              await _auth.signInAnonymously();
              await DatabaseService().saveSocialUser(
                uid: "naver_${DateTime.now().millisecondsSinceEpoch}",
                email: "naver_user@temp.com",
                nickname: "네이버 사용자",
                photoUrl: null,
                socialType: 'naver',
              );
              completer.complete(true);
            } catch (e2) {
              print("Firebase 로그인 에러: $e2");
              completer.complete(false);
            }
          }
        },
        onFailure: (errorCode, message) {
          print("❌ 프로필 가져오기 실패: $errorCode - $message");
          completer.complete(false);
        },
      ),
    );
  }

  // 3. 카카오 로그인
  Future<bool> signInWithKakao() async {
    try {
      bool isInstalled = await kakao.isKakaoTalkInstalled();
      kakao.OAuthToken token;

      if (isInstalled) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          if (error is PlatformException && error.code == 'CANCELED') {
            return false;
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      kakao.User user = await kakao.UserApi.instance.me();

      await DatabaseService().saveSocialUser(
        uid: "kakao_${user.id.toString()}",
        email: user.kakaoAccount?.email ?? "이메일 없음",
        nickname: user.kakaoAccount?.profile?.nickname ?? "이름 없음",
        photoUrl: user.kakaoAccount?.profile?.thumbnailImageUrl,
        socialType: 'kakao',
      );

      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      print("카카오 로그인 에러: $e");
      return false;
    }
  }

  // 4. 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await NaverLoginSDK.logout();
      await _auth.signOut();
      print("✅ 통합 로그아웃 완료");
    } catch (e) {
      print("로그아웃 에러: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}