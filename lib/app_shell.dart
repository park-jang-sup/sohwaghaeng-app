import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/models/personality_type.dart';
import 'package:b612_1/services/database_service.dart';
import 'package:b612_1/services/auth_service.dart';

// Screens
import 'package:b612_1/screens/onboarding_intro/onboarding_intro_screen.dart';
import 'package:b612_1/screens/personality_test/personality_test_screen.dart';
import 'package:b612_1/screens/personality_result/personality_result_screen.dart';
import 'package:b612_1/screens/nickname_setup/nickname_setup_screen.dart';
import 'package:b612_1/screens/home_tab/home_tab_screen.dart'; // ✅ 원래 홈 화면
import 'package:b612_1/screens/mission_browser/mission_browser_screen.dart';
import 'package:b612_1/screens/history_tab/history_tab_screen.dart';
import 'package:b612_1/screens/profile_screen/profile_screen.dart';
import 'package:b612_1/widgets/modals/mood_selector.dart';

enum OnboardingStep { intro, personalityTest, personalityResult, nicknameSetup, completed }

class UserProfile {
  String nickname;
  String personalityType;
  String email;
  String bio;
  bool isGuest;

  UserProfile({
    required this.nickname,
    required this.personalityType,
    required this.email,
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
  // 상태 변수
  bool _isLoadingProfile = true;
  OnboardingStep _onboardingStep = OnboardingStep.completed;
  int _currentTabIndex = 1; // 0: 탐색, 1: 오늘(홈), 2: 기록

  // 데이터
  UserProfile _userProfile = UserProfile(nickname: '', personalityType: '', email: '', bio: '');
  PersonalityType? _tempPersonalityType;
  Map<String, bool> _attendanceData = {};
  Set<String> _addedMissionIds = <String>{};

  // 기분 및 스트릭
  bool _showMoodSelector = false;
  String? _currentMood; // 현재 기분 저장
  int _streakDays = 5; // 스트릭 (더미 데이터)

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserProfile();
    if (!mounted) return;
    _loadAttendanceData();
    setState(() => _isLoadingProfile = false);
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await DatabaseService().getCurrentUserData();
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;

      if (userData == null) {
        setState(() {
          _onboardingStep = OnboardingStep.intro;
          _userProfile = UserProfile(
            nickname: '게스트',
            personalityType: '미설정',
            email: user?.email ?? '',
            bio: '나만의 소확행을 찾아보세요',
            isGuest: user?.isAnonymous ?? true,
          );
        });
      } else {
        setState(() {
          _onboardingStep = OnboardingStep.completed;
          _userProfile = UserProfile(
            nickname: userData['nickname'] ?? '사용자',
            personalityType: userData['personality_type'] ?? '꾸준한 실천가',
            email: userData['email'] ?? '',
            bio: userData['bio'] ?? '오늘도 행복한 하루 보내세요!',
            isGuest: false,
          );
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  void _loadAttendanceData() {
    final today = DateTime.now();
    _attendanceData = {
      today.subtract(const Duration(days: 1)).toIso8601String().split('T')[0]: true,
      today.subtract(const Duration(days: 3)).toIso8601String().split('T')[0]: true,
    };
  }

  // --- Handlers ---

  // 1. 미션 완료 토글
  void _handleToggleMission(String id) async {
    final docRef = FirebaseFirestore.instance.collection('user_missions').doc(id);
    final doc = await docRef.get();
    if (doc.exists) {
      final current = doc.data()?['completed'] ?? false;
      await docRef.update({
        'completed': !current,
        'completedAt': !current ? DateTime.now().toIso8601String() : null,
      });
    }
  }

  // 2. 미션 추가 (탐색 탭 -> 내 미션)
  void _handleAddMissionFromBrowser(Mission mission, String? originalId) async {
    await DatabaseService().addUserMission(
      title: mission.title,
      description: mission.description,
      tag: mission.tag,
      iconCode: mission.iconData.codePoint,
      color: mission.color,
      author: mission.source,
    );
    if (originalId != null && mounted) {
      setState(() => _addedMissionIds.add(originalId));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("내 행성에 미션이 추가되었어요!")));
    }
  }

  // 3. 직접 미션 추가 (HomeTabScreen의 모달에서 호출)
  void _handleCreateMission(String title, String icon, String color, bool isPublic, String? time) {
    DatabaseService().addUserMission(
      title: title,
      description: '',
      tag: 'custom',
      iconCode: Icons.star.codePoint, // 아이콘 문자열을 코드로 변환하는 로직 필요시 수정
      color: color,
      author: _userProfile.nickname,
    );
  }

  // 4. ✅ [수정됨] 사진 추가 (Firebase Storage 업로드 적용)
  void _handleAddPhoto(String missionId, String? path) async {
    if (path == null) {
      // 삭제하는 경우
      await DatabaseService().updateUserMission(missionId, {'photo': null});
    } else {
      // 추가하는 경우: 먼저 안내 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사진을 업로드 중입니다... 잠시만 기다려주세요!")),
        );
      }

      // 1. Storage에 업로드하고 URL 받기
      String? downloadUrl = await DatabaseService().uploadImage(path);

      if (downloadUrl != null) {
        // 2. 받은 URL을 Firestore에 저장
        await DatabaseService().updateUserMission(missionId, {'photo': downloadUrl});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사진 저장 완료! 🎉")),
          );
        }
      } else {
        // 실패 시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사진 업로드 실패 ㅠㅠ")),
          );
        }
      }
    }
  }

  // 5. 미션 삭제
  void _handleDeleteMission(String missionId) async {
    await DatabaseService().deleteUserMission(missionId);
  }

  // 6. 하루 마무리
  void _handleFinishDay() {
    final todayStr = DateTime.now().toIso8601String().split("T")[0];
    setState(() => _attendanceData[todayStr] = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('오늘 하루 기록이 저장되었습니다! 🎉')));
  }

  // 7. 정렬 및 초기화
  void _handleSortMissions() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미션이 정렬되었습니다.')));
  }

  void _handleResetMissions() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미션이 초기화되었습니다.')));
  }

  // --- ✅ 수정: 온보딩 완료 핸들러 (async로 변경) ---
  Future<void> _finishOnboarding(String nickname) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().saveSocialUser(
        uid: user.uid,
        email: user.email ?? '',
        nickname: nickname,
        socialType: 'guest',
      );
    }
    if (mounted) {
      setState(() {
        _userProfile.nickname = nickname;
        _onboardingStep = OnboardingStep.completed;
        _showMoodSelector = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_onboardingStep != OnboardingStep.completed) return _buildOnboarding();

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // 0: 탐색
              MissionBrowserScreen(
                onAddMission: _handleAddMissionFromBrowser,
                addedMissionIds: _addedMissionIds,
              ),
              // 1: 오늘
              _buildTodayTab(),
              // 2: 기록
              _buildHistoryTab(),
              // 3: 프로필
              ProfileScreen(
                userProfile: _userProfile,
                onBack: () => setState(() => _currentTabIndex = 2),
                onLogout: () async { await AuthService().signOut(); },
              ),
            ],
          ),
          if (_showMoodSelector)
            Container(
              color: Colors.black54,
              child: MoodSelector(onSelectMood: (mood) {
                setState(() {
                  _currentMood = mood;
                  _showMoodSelector = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오늘의 기분: $mood")));
              }),
            ),
        ],
      ),
      bottomNavigationBar: _currentTabIndex == 3
          ? null
          : _CustomBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
      ),
    );
  }

  // --- 탭 화면 빌더 ---

  Widget _buildTodayTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getUserMissionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = snapshot.data?.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Mission.fromMap(data, doc.id);
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
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getUserMissionsStream(),
      builder: (context, snapshot) {
        final missions = snapshot.data?.docs.map((doc) {
          return Mission.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList() ?? [];

        return HistoryTabScreen(
          attendanceData: _attendanceData,
          missionHistory: missions,
          onOpenProfile: () => setState(() => _currentTabIndex = 3),
          userProfile: _userProfile,
        );
      },
    );
  }

  Widget _buildOnboarding() {
    switch (_onboardingStep) {
      case OnboardingStep.intro:
        return OnboardingIntroScreen(
          onComplete: () => setState(() => _onboardingStep = OnboardingStep.personalityTest),
          onBack: () {},
        );
      case OnboardingStep.personalityTest:
        return PersonalityTestScreen(
          onComplete: (type) {
            setState(() {
              _tempPersonalityType = type;
              _onboardingStep = OnboardingStep.personalityResult;
            });
          },
          onBack: () => setState(() => _onboardingStep = OnboardingStep.intro),
        );
      case OnboardingStep.personalityResult:
        return PersonalityResultScreen(
          personalityType: _tempPersonalityType!,
          onComplete: (_, __) => setState(() => _onboardingStep = OnboardingStep.nicknameSetup),
          onBack: () => setState(() => _onboardingStep = OnboardingStep.personalityTest),
        );
      case OnboardingStep.nicknameSetup:
        return NicknameSetupScreen(
          onComplete: _finishOnboarding,
          onBack: () => setState(() => _onboardingStep = OnboardingStep.personalityResult),
        );
      default:
        return Container();
    }
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(icon: Icons.search_rounded, label: '탐색', index: 0, onTap: () => onTap(0)),
              const Spacer(),
              _buildNavItem(icon: Icons.calendar_today_rounded, label: '기록', index: 2, onTap: () => onTap(2)),
            ],
          ),
          Positioned(
            bottom: 20.0,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                transform: Matrix4.identity()
                  ..scale(currentIndex == 1 ? 1.1 : 1.0)
                  ..translate(0.0, currentIndex == 1 ? -5.0 : 0.0),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFF6B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B00).withOpacity(0.4), blurRadius: 15.0, offset: const Offset(0, 8))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_rounded, size: 24.0, color: Colors.white),
                    if (currentIndex == 1) ...[
                      const SizedBox(width: 8),
                      const Text('오늘', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required VoidCallback onTap}) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? const Color(0xFFFF8C42) : Colors.grey.shade400;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26.0, color: color),
              const SizedBox(height: 4.0),
              Text(label, style: TextStyle(fontSize: 11.0, color: color, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}