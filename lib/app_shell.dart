import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 처리를 위해 필요
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/custom_tag.dart';
import 'package:b612_1/screens/login/login_screen.dart';
import 'package:b612_1/screens/onboarding_intro/onboarding_intro_screen.dart';
import 'package:b612_1/screens/personality_test/personality_test_screen.dart';
import 'package:b612_1/screens/personality_result/personality_result_screen.dart';
import 'package:b612_1/screens/nickname_setup/nickname_setup_screen.dart';
import 'package:b612_1/models/personality_type.dart';
import 'package:b612_1/screens/home_tab/home_tab_screen.dart';
import 'package:b612_1/screens/mission_browser/mission_browser_screen.dart';
import 'package:b612_1/screens/history_tab/history_tab_screen.dart';
import 'package:b612_1/screens/profile_screen/profile_screen.dart';
import 'package:b612_1/widgets/modals/mood_selector.dart';

enum OnboardingStep { login, intro, personalityTest, personalityResult, nicknameSetup, completed }
enum TabItem { home, browse, records, profile }

class UserProfile {
  String nickname;
  String personalityType;
  String email;
  String profileEmoji;
  String bio;
  bool isGuest;

  UserProfile({
    required this.nickname,
    required this.personalityType,
    required this.email,
    required this.profileEmoji,
    required this.bio,
    this.isGuest = true,
  });
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isFirstTime = true;
  OnboardingStep _onboardingStep = OnboardingStep.login;
  PersonalityType? _personalityType;

  List<Mission> _missions = [];

  // [신규] 완료된 미션들의 히스토리를 저장하는 리스트
  List<Mission> _missionHistory = [];

  TabItem _currentTab = TabItem.home;
  bool _showMoodSelector = false;
  String? _currentMood;
  int _streakDays = 5;

  Map<String, bool> _attendanceData = {};
  Set<String> _addedMissionIds = <String>{};

  UserProfile _userProfile = UserProfile(
    nickname: "소확행러",
    personalityType: "꾸준한 실천가",
    email: "user@example.com",
    profileEmoji: "🌟",
    bio: "소확행 실천러",
  );

  @override
  void initState() {
    super.initState();
    _missions = Mission.getSampleMissions();
    _generateDummyAttendance();
  }

  void _generateDummyAttendance() {
    final today = DateTime.now();
    for (int i = 1; i <= 6; i++) {
      final pastDate = today.subtract(Duration(days: i));
      final dateKey = pastDate.toIso8601String().split('T')[0];
      if (DateTime.now().millisecond % 10 > 4) {
        _attendanceData[dateKey] = true;
      }
    }
  }

  // --- Handlers ---

  void _handleSelectMood(String mood) {
    setState(() {
      _currentMood = mood;
      _showMoodSelector = false;
      _currentTab = TabItem.home;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오늘의 기분: $mood')));
  }

  void _handleToggleMission(String id) {
    setState(() {
      _missions = _missions.map((mission) {
        if (mission.id == id) {
          final newCompleted = !mission.completed;
          return mission.copyWith(
            completed: newCompleted,
            completedAt: newCompleted ? DateTime.now().toIso8601String() : null,
          );
        }
        return mission;
      }).toList();
    });
    _updateTodayAttendance();
  }

  void _updateTodayAttendance() {
    final completedCount = _missions.where((m) => m.completed).length;
    final totalMissions = _missions.length;
    final today = DateTime.now().toIso8601String().split("T")[0];

    setState(() {
      if (completedCount == totalMissions && totalMissions > 0) {
        _attendanceData[today] = true;
      } else {
        _attendanceData.remove(today);
      }
    });
  }

  void _handleAddPhoto(String missionId, String? photoPath) {
    setState(() {
      _missions = _missions.map((m) {
        return m.id == missionId ? m.copyWith(photo: photoPath) : m;
      }).toList();
    });
  }

  void _handleDeleteMission(String id) {
    setState(() {
      _missions.removeWhere((m) => m.id == id);
    });
    _updateTodayAttendance();
  }

  void _handleCreateMission(String title, String icon, String color, bool isPublic, String? time) {
    final newMission = Mission(
      id: "mission-${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      description: "",
      completed: false,
      tag: "custom",
      icon: icon,
      color: color,
      isPublic: isPublic,
      time: time,
      source: 'mine',
    );
    setState(() {
      _missions.add(newMission);
    });
  }

  void _handleAddMissionFromBrowser(Mission mission, String? originalId) {
    setState(() {
      _missions.add(mission);
      if (originalId != null) {
        _addedMissionIds.add(originalId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미션이 추가되었습니다!')));
  }

  // [중요] 하루 마무리 핸들러: 완료된 미션을 _missionHistory에 저장
  void _handleFinishDay() {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split("T")[0];

    setState(() {
      // 1. 현재 화면에서 '완료됨'으로 체크된 미션들을 찾음
      final completedToday = _missions.where((m) => m.completed).map((m) {
        // completedAt이 비어있다면 현재 시간으로 채워줌
        return m.copyWith(
          completedAt: m.completedAt ?? now.toIso8601String(),
        );
      }).toList();

      // 2. 히스토리 리스트에 추가 (누적 저장)
      _missionHistory.addAll(completedToday);

      // 3. 출석 데이터에 오늘 날짜 체크
      _attendanceData[todayStr] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오늘 하루 기록이 저장되었습니다! 🎉'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 미션 정렬
  void _handleSortMissions() {
    setState(() {
      _missions.sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        if (a.time != null && b.time == null) return -1;
        if (a.time == null && b.time != null) return 1;
        return a.title.compareTo(b.title);
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미션이 정렬되었습니다.')));
  }

  // 미션 리셋
  void _handleResetMissions() {
    setState(() {
      _missions = _missions.map((m) => m.copyWith(completed: false)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 미션이 초기화되었습니다.')));
  }

  // --- Onboarding Handlers ---
  void _handleNicknameSetupComplete(String nickname) {
    setState(() {
      _userProfile.nickname = nickname;
      _onboardingStep = OnboardingStep.completed;
      _isFirstTime = false;
      _showMoodSelector = true;
    });
  }

  void _handlePersonalityResultComplete(String nickname, String personalityDesc) {
    setState(() {
      _onboardingStep = OnboardingStep.nicknameSetup;
    });
  }

  // --- UI Building ---
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: "홈", isSelected: _currentTab == TabItem.home, onTap: () => setState(() => _currentTab = TabItem.home)),
              GestureDetector(
                onTap: () => setState(() => _currentTab = TabItem.browse),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: _currentTab == TabItem.browse ? Colors.orange : Colors.orange.shade300,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              _buildNavItem(icon: Icons.menu_book_rounded, label: "기록", isSelected: _currentTab == TabItem.records || _currentTab == TabItem.profile, onTap: () => setState(() => _currentTab = TabItem.records)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: isSelected ? Colors.orange : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.orange : Colors.grey.shade400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime && _onboardingStep != OnboardingStep.completed) {
      switch (_onboardingStep) {
        case OnboardingStep.login:
          return LoginScreen(onGuestLogin: () => setState(() => _onboardingStep = OnboardingStep.intro), onSocialLogin: (_) {});
        case OnboardingStep.intro:
          return OnboardingIntroScreen(onComplete: () => setState(() => _onboardingStep = OnboardingStep.personalityTest), onBack: () {});
        case OnboardingStep.personalityTest:
          return PersonalityTestScreen(onComplete: (type) { setState(() { _personalityType = type; _onboardingStep = OnboardingStep.personalityResult; });}, onBack: () {});
        case OnboardingStep.personalityResult:
          return PersonalityResultScreen(personalityType: _personalityType!, onComplete: _handlePersonalityResultComplete, onBack: () {});
        case OnboardingStep.nicknameSetup:
          return NicknameSetupScreen(onComplete: _handleNicknameSetupComplete, onBack: () => setState(() => _onboardingStep = OnboardingStep.personalityResult));
        default:
          return Container();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: _buildBody(),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavigationBar()),
          if (_showMoodSelector)
            Container(color: Colors.black54, child: MoodSelector(onSelectMood: _handleSelectMood)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case TabItem.home:
        return HomeTabScreen(
          missions: _missions,
          onToggleMission: _handleToggleMission,
          onAddMission: _handleCreateMission,
          onDeleteMission: _handleDeleteMission,
          onAddPhoto: _handleAddPhoto,

          onFinishDay: _handleFinishDay, // [연결됨]
          onSortMissions: _handleSortMissions,
          onResetMissions: _handleResetMissions,

          currentMood: _currentMood,
          streakDays: _streakDays,
        );
      case TabItem.browse:
        return MissionBrowserScreen(addedMissionIds: _addedMissionIds, onAddMission: _handleAddMissionFromBrowser);
      case TabItem.records:
      // [수정] missionHistory 전달
        return HistoryTabScreen(
          attendanceData: _attendanceData,
          missionHistory: _missionHistory,
          onOpenProfile: () => setState(() => _currentTab = TabItem.profile),
          userProfile: _userProfile,
        );
      case TabItem.profile:
        return ProfileScreen(userProfile: _userProfile, onBack: () => setState(() => _currentTab = TabItem.records), onLogout: () {});
    }
  }
}