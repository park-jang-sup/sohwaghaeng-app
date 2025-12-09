import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
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

  // 2. 네이버 로그인
  Future<bool> signInWithNaver() async {
    try {
      // 로그인 시도
      await FlutterNaverLogin.logIn();

      // 로그인 성공 확인 (괄호 추가!)
      final isLoggedIn = await FlutterNaverLogin.isLoggedIn();

      if (isLoggedIn) {
        print("✅ 네이버 로그인 성공!");

        // Firebase 익명 로그인
        await _auth.signInAnonymously();

        // 간단한 사용자 정보 저장
        final user = _auth.currentUser;
        if (user != null) {
          await DatabaseService().saveSocialUser(
            uid: "naver_${user.uid}",
            email: "naver_user@temp.com",
            nickname: "네이버 사용자",
            photoUrl: null,
            socialType: 'naver',
          );
        }

        return true;
      }
      return false;
    } catch (e) {
      print("네이버 로그인 에러: $e");
      return false;
    }
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

  // 4. 로그아웃 및 유저 정보
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FlutterNaverLogin.logOut();
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