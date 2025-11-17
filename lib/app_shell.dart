import 'package:flutter/material.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/custom_tag.dart';
import 'package:b612_1/utils/icon_mapper.dart';
import 'package:b612_1/widgets/modals/add_mission_modal.dart';
// 온보딩 화면들
import 'package:b612_1/screens/login/login_screen.dart';
import 'package:b612_1/screens/onboarding_intro/onboarding_intro_screen.dart';
import 'package:b612_1/screens/personality_test/personality_test_screen.dart';
import 'package:b612_1/screens/personality_result/personality_result_screen.dart';
// 메인 앱 뼈대
import 'package:b612_1/main_app_scaffold.dart';
// 1. [추가] 공통 PersonalityType import
import 'package:b612_1/models/personality_type.dart';

// .tsx의 onboardingStep
enum OnboardingStep { login, intro, personalityTest, personalityResult, completed }

// .tsx의 userProfile
class UserProfile {
  String nickname;
  String personalityType;
  String email;
  String profileEmoji;
  String bio;

  UserProfile({
    required this.nickname,
    required this.personalityType,
    required this.email,
    required this.profileEmoji,
    required this.bio,
  });
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // --- .tsx의 useState에 해당하는 모든 상태 ---
  bool _isFirstTime = true;
  OnboardingStep _onboardingStep = OnboardingStep.login;
  PersonalityType? _personalityType;

  List<Mission> _missions = Mission.getSampleMissions();
  List<CustomTag> _customTags = [];
  Map<String, bool> _attendanceData = {
    // .tsx의 샘플 데이터
    DateTime.now()
        .subtract(const Duration(days: 2))
        .toIso8601String()
        .split('T')[0]: true,
    DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0]: true,
  };
  Set<String> _addedMissionIds = <String>{};
  UserProfile _userProfile = UserProfile(
    nickname: "소확행러",
    personalityType: "꾸준한 실천가",
    email: "user@example.com",
    profileEmoji: "🌟",
    bio: "소확행 실천러",
  );

  // --- .tsx의 핸들러 함수들 ---

  // Mission 핸들러
  void _handleToggleMission(String id) {
    setState(() {
      _missions = _missions.map((mission) {
        if (mission.id == id) {
          final newCompleted = !mission.completed;
          return Mission(
              id: mission.id,
              title: mission.title,
              description: mission.description,
              completed: newCompleted,
              tag: mission.tag,
              icon: mission.icon,
              photo: mission.photo,
              completedAt:
              newCompleted ? DateTime.now().toIso8601String() : null);
        }
        return mission;
      }).toList();
    });
    _updateTodayAttendance();
  }

  // ==================  ↓↓↓ 수정된 부분 ↓↓↓ ==================
  // 사진 '삭제' 기능을 위해 String? (nullable)로 변경
  void _handleAddPhoto(String missionId, String? photoPath) {
    // ==================  ↑↑↑ 수정된 부분 ↑↑↑ ==================
    setState(() {
      _missions = _missions.map((m) {
        return m.id == missionId
            ? Mission(
            id: m.id,
            title: m.title,
            description: m.description,
            tag: m.tag,
            icon: m.icon,
            completed: m.completed,
            completedAt: m.completedAt,
            photo: photoPath) // null이 전달되면 사진이 삭제됨
            : m;
      }).toList();
    });
  }

  void _handleDeleteMission(String id) {
    setState(() {
      _missions.removeWhere((m) => m.id == id);
    });
    _updateTodayAttendance();
  }

  void _handleOpenAddMissionModal() {
    // TodayTabScreen에서 복사해 온 모달 열기 로직
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return AddMissionModal(
          customTags: _customTags,
          onAddMission: _handleAddMission, // 실제 추가 로직
          onAddCustomTag: _handleAddCustomTag,
        );
      },
    );
  }

  void _handleAddMission(NewMissionData data) {
    final newMission = Mission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data.title,
      description: data.description,
      tag: data.tagId, // TODO: ID로 태그 라벨 찾기
      icon: getIconForTag(data.tagId),
    );
    setState(() {
      _missions.add(newMission);
    });
    _updateTodayAttendance();
  }

  void _handleAddCustomTag(CustomTag newTag) {
    setState(() {
      _customTags.add(newTag);
    });
  }

  void _handleAddMissionFromBrowser(Mission mission, String? originalId) {
    setState(() {
      _missions.add(mission);
      if (originalId != null) {
        _addedMissionIds.add(originalId);
      }
    });
    _updateTodayAttendance();
  }

  void _updateTodayAttendance() {
    // .tsx의 handleToggleMission에 있던 출석 체크 로직
    final completedCount = _missions.where((m) => m.completed).length;
    final totalMissions = _missions.length;
    final today = DateTime.now().toIso8601String().split("T")[0];

    setState(() {
      if (completedCount == totalMissions && totalMissions > 0) {
        _attendanceData[today] = true;
      } else {
        _attendanceData.remove(today); // false 대신 제거
      }
    });
  }

  // Profile 핸들러
  void _handleUpdateProfile(UserProfile newProfile) {
    setState(() {
      _userProfile = newProfile;
    });
    // TODO: toast.success("프로필이 업데이트되었습니다.");
  }

  void _handleLogout() {
    // TODO: 로그아웃 로직
    // TODO: toast.success("로그아웃되었습니다.");
    // 여기서는 간단하게 로그인 화면으로 되돌립니다.
    setState(() {
      _isFirstTime = true;
      _onboardingStep = OnboardingStep.login;
      _missions = Mission.getSampleMissions(); // 미션 초기화
    });
  }

  // Onboarding 핸들러
  void _handleGuestLogin() {
    setState(() => _onboardingStep = OnboardingStep.intro);
  }

  void _handleSocialLogin(String provider) {
    print('$provider 로그인');
    setState(() => _onboardingStep = OnboardingStep.intro);
  }

  void _handleIntroComplete() {
    setState(() => _onboardingStep = OnboardingStep.personalityTest);
  }

  void _handlePersonalityTestComplete(PersonalityType result) {
    setState(() {
      _personalityType = result;
      _onboardingStep = OnboardingStep.personalityResult;
    });
  }

  void _handlePersonalityResultComplete(
      String nickname, String personalityDesc) {
    setState(() {
      _userProfile.nickname = nickname;
      _userProfile.personalityType = personalityDesc;
      _userProfile.profileEmoji = _personalityType == PersonalityType.introvert
          ? "🌙"
          : _personalityType == PersonalityType.extrovert
          ? "☀️"
          : "⚖️";
      _onboardingStep = OnboardingStep.completed;
      _isFirstTime = false; // 온보딩 완료
    });
    // TODO: toast.success("환영합니다, ${nickname}님! 🎉");
  }

  void _handleOnboardingBack() {
    setState(() {
      switch (_onboardingStep) {
        case OnboardingStep.intro:
          _onboardingStep = OnboardingStep.login;
          break;
        case OnboardingStep.personalityTest:
          _onboardingStep = OnboardingStep.intro;
          break;
        case OnboardingStep.personalityResult:
          _onboardingStep = OnboardingStep.personalityTest;
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // .tsx의 `if (isFirstTime && onboardingStep !== "completed")`
    if (_isFirstTime && _onboardingStep != OnboardingStep.completed) {
      // 온보딩 플로우 렌더링
      switch (_onboardingStep) {
        case OnboardingStep.login:
          return LoginScreen(
            onGuestLogin: _handleGuestLogin,
            onSocialLogin: (provider) => _handleSocialLogin(provider.toString()),
          );
        case OnboardingStep.intro:
          return OnboardingIntroScreen(
            onComplete: _handleIntroComplete,
            onBack: _handleOnboardingBack,
          );
        case OnboardingStep.personalityTest:
          return PersonalityTestScreen(
            onComplete: _handlePersonalityTestComplete,
            onBack: _handleOnboardingBack,
          );
        case OnboardingStep.personalityResult:
          return PersonalityResultScreen(
            personalityType: _personalityType!,
            onComplete: _handlePersonalityResultComplete,
            onBack: _handleOnboardingBack,
          );
        default:
          return LoginScreen(
              onGuestLogin: _handleGuestLogin, onSocialLogin: (p) {});
      }
    }

    // .tsx의 메인 앱 `return (...)`
    return MainAppScaffold(
      // 모든 상태와 핸들러를 MainAppScaffold로 전달
      missions: _missions,
      attendanceData: _attendanceData,
      addedMissionIds: _addedMissionIds,
      userProfile: _userProfile,
      onToggleMission: _handleToggleMission,
      onAddMission: _handleOpenAddMissionModal,
      onAddPhoto: _handleAddPhoto, // String?을 받는 수정된 함수 전달
      onDeleteMission: _handleDeleteMission,
      onAddMissionFromBrowser: _handleAddMissionFromBrowser,
      onUpdateProfile: _handleUpdateProfile,
      onLogout: _handleLogout,
    );
  }
}