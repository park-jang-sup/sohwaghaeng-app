import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/custom_tag.dart';
import 'package:b612_1/services/database_service.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:b612_1/services/auth_service.dart';

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
  bool _isFirstTime = false;
  OnboardingStep _onboardingStep = OnboardingStep.completed;

  PersonalityType? _personalityType;

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

  // ✅ Firebase에 업데이트
  void _handleToggleMission(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('missions')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data();
        // ✅ String/bool 둘 다 처리
        final currentCompleted = data?['completed'] == true || data?['completed'] == 'true';
        await FirebaseFirestore.instance
            .collection('missions')
            .doc(id)
            .update({
          'completed': !currentCompleted,
          'completedAt': !currentCompleted ? DateTime.now().toIso8601String() : null,
        });
      }
    } catch (e) {
      print('미션 토글 에러: $e');
    }
  }

  void _handleAddPhoto(String missionId, String? photoPath) async {
    try {
      await FirebaseFirestore.instance
          .collection('missions')
          .doc(missionId)
          .update({'photo': photoPath});
    } catch (e) {
      print('사진 추가 에러: $e');
    }
  }

  void _handleDeleteMission(String id) async {
    try {
      await DatabaseService().deleteMission(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션이 삭제되었습니다')),
      );
    } catch (e) {
      print('미션 삭제 에러: $e');
    }
  }

  void _handleCreateMission(String title, String icon, String color, bool isPublic, String? time) async {
    try {
      await DatabaseService().addMission(
        title: title,
        description: '',
        tag: 'custom',
        iconCode: Icons.star.codePoint,
        author: _userProfile.nickname,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션이 추가되었습니다!')),
      );
    } catch (e) {
      print('미션 생성 에러: $e');
    }
  }

  void _handleAddMissionFromBrowser(Mission mission, String? originalId) async {
    try {
      await DatabaseService().addMission(
        title: mission.title,
        description: mission.description,
        tag: mission.tag,
        iconCode: Icons.star.codePoint,
        author: _userProfile.nickname,
      );

      setState(() {
        if (originalId != null) {
          _addedMissionIds.add(originalId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션이 추가되었습니다!')),
      );
    } catch (e) {
      print('미션 추가 에러: $e');
    }
  }

  void _handleFinishDay() {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split("T")[0];

    setState(() {
      _attendanceData[todayStr] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오늘 하루 기록이 저장되었습니다! 🎉'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleSortMissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('미션이 정렬되었습니다.')),
    );
  }

  void _handleResetMissions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('missions')
          .where('completed', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'completed': false, 'completedAt': null});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 미션이 초기화되었습니다.')),
      );
    } catch (e) {
      print('미션 초기화 에러: $e');
    }
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
              _buildNavItem(
                icon: Icons.home_rounded,
                label: "홈",
                isSelected: _currentTab == TabItem.home,
                onTap: () => setState(() => _currentTab = TabItem.home),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentTab = TabItem.browse),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _currentTab == TabItem.browse ? Colors.orange : Colors.orange.shade300,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: "기록",
                isSelected: _currentTab == TabItem.records || _currentTab == TabItem.profile,
                onTap: () => setState(() => _currentTab = TabItem.records),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: isSelected ? Colors.orange : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.orange : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime && _onboardingStep != OnboardingStep.completed) {
      switch (_onboardingStep) {
        case OnboardingStep.login:
          return LoginScreen(
            onGuestLogin: () => setState(() => _onboardingStep = OnboardingStep.intro),
            onSocialLogin: (_) {},
          );
        case OnboardingStep.intro:
          return OnboardingIntroScreen(
            onComplete: () => setState(() => _onboardingStep = OnboardingStep.personalityTest),
            onBack: () {},
          );
        case OnboardingStep.personalityTest:
          return PersonalityTestScreen(
            onComplete: (type) {
              setState(() {
                _personalityType = type;
                _onboardingStep = OnboardingStep.personalityResult;
              });
            },
            onBack: () {},
          );
        case OnboardingStep.personalityResult:
          return PersonalityResultScreen(
            personalityType: _personalityType!,
            onComplete: _handlePersonalityResultComplete,
            onBack: () {},
          );
        case OnboardingStep.nicknameSetup:
          return NicknameSetupScreen(
            onComplete: _handleNicknameSetupComplete,
            onBack: () => setState(() => _onboardingStep = OnboardingStep.personalityResult),
          );
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
            Container(
              color: Colors.black54,
              child: MoodSelector(onSelectMood: _handleSelectMood),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case TabItem.home:
      // ✅ StreamBuilder로 실시간 구독!
        return StreamBuilder<QuerySnapshot>(
          stream: DatabaseService().getMissionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            // ✅ Firestore 문서를 Mission 객체로 변환 (String/bool 둘 다 처리)
            final missions = snapshot.data?.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Mission(
                id: doc.id,
                title: data['title'] ?? '제목 없음',
                description: data['description'] ?? '',
                // ✅ 핵심 수정: String이든 bool이든 처리
                completed: data['completed'] == true || data['completed'] == 'true',
                tag: data['tag'] ?? 'custom',
                icon: 'star',
                color: '#FFD6A5',
                source: 'mine',
                completedAt: data['completedAt'],
                photo: data['photo'],
              );
            }).toList() ?? [];

            return HomeTabScreen(
              missions: missions,
              onToggleMission: _handleToggleMission,
              onAddMission: _handleCreateMission,
              onDeleteMission: _handleDeleteMission,
              onAddPhoto: _handleAddPhoto,
              onFinishDay: _handleFinishDay,
              onSortMissions: _handleSortMissions,
              onResetMissions: _handleResetMissions,
              currentMood: _currentMood,
              streakDays: _streakDays,
            );
          },
        );

      case TabItem.browse:
        return MissionBrowserScreen(
          addedMissionIds: _addedMissionIds,
          onAddMission: _handleAddMissionFromBrowser,
        );

      case TabItem.records:
        return HistoryTabScreen(
          attendanceData: _attendanceData,
          missionHistory: _missionHistory,
          onOpenProfile: () => setState(() => _currentTab = TabItem.profile),
          userProfile: _userProfile,
        );

      case TabItem.profile:
        return ProfileScreen(
          userProfile: _userProfile,
          onBack: () => setState(() => _currentTab = TabItem.records),
          onLogout: () async {
            await AuthService().signOut();
          },
        );
    }
  }
}