import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/app_shell.dart' show UserProfile;
// 탭 화면 import
import 'package:b612_1/screens/today_tab/today_tab_screen.dart';
import 'package:b612_1/screens/mission_browser/mission_browser_screen.dart';
import 'package:b612_1/screens/history_tab/history_tab_screen.dart';
import 'package:b612_1/screens/profile_screen/profile_screen.dart';

class MainAppScaffold extends StatefulWidget {
  // .tsx에서 App이 TodayTab 등에게 전달하는 모든 props
  final List<Mission> missions;
  final Map<String, bool> attendanceData;
  final Set<String> addedMissionIds;
  final UserProfile userProfile;
  final Function(String) onToggleMission;
  final VoidCallback onAddMission;
  final Function(String, String?) onAddPhoto; // String? (nullable)로 변경
  final Function(String) onDeleteMission;
  final Function(Mission, String?) onAddMissionFromBrowser;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onLogout;

  const MainAppScaffold({
    super.key,
    required this.missions,
    required this.attendanceData,
    required this.addedMissionIds,
    required this.userProfile,
    required this.onToggleMission,
    required this.onAddMission,
    required this.onAddPhoto,
    required this.onDeleteMission,
    required this.onAddMissionFromBrowser,
    required this.onUpdateProfile,
    required this.onLogout,
  });

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  // .tsx의 `currentTab` 상태
  // 0: 탐색(browse), 1: 오늘(today), 2: 기록(records), 3: 프로필(profile)
  int _currentTabIndex = 1; // 'today'를 기본값으로

  // 1. [삭제] 여기서 _tabPages 리스트를 선언하지 않습니다.
  // late final List<Widget> _tabPages;

  @override
  void initState() {
    super.initState();

    // 2. [삭제] initState에서 _tabPages를 생성하던 모든 로직을 삭제합니다.
  }

  // .tsx의 `setCurrentTab`
  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  // .tsx의 `HistoryTab` -> `ProfileScreen` 탐색 로직
  void _handleNavigateToProfile() {
    setState(() {
      _currentTabIndex = 3; // 프로필 인덱스
    });
  }

  void _handleNavigateToRecords() {
    setState(() {
      _currentTabIndex = 2; // 기록 인덱스
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. [추가] _tabPages 리스트를 initState가 아닌 build 메서드 안에서 생성합니다.
    // 이렇게 하면 AppShell의 상태가 변경될 때마다 이 리스트도 새로고침됩니다.
    final List<Widget> tabPages = [
      // 0: 탐색 (MissionBrowser)
      MissionBrowserScreen(
        onAddMission: widget.onAddMissionFromBrowser,
        addedMissionIds: widget.addedMissionIds,
      ),
      // 1: 오늘 (TodayTab)
      TodayTabScreen(
        missions: widget.missions,
        attendanceData: widget.attendanceData,
        onToggleMission: widget.onToggleMission,
        onAddMission: widget.onAddMission,
        onAddPhoto: widget.onAddPhoto,
        onDeleteMission: widget.onDeleteMission,
      ),
      // 2: 기록 (HistoryTab)
      HistoryTabScreen(
        onOpenProfile: () => _handleNavigateToProfile(),
        profileEmoji: widget.userProfile.profileEmoji,
        userBio: widget.userProfile.bio,
      ),
      // 3: 프로필 (ProfileScreen) - HistoryTab에서만 접근 가능
      ProfileScreen(
        userProfile: widget.userProfile,
        onBack: () => _handleNavigateToRecords(),
        onLogout: widget.onLogout,
        onUpdateProfile: widget.onUpdateProfile,
      ),
    ];

    // .tsx의 하단 탭 로직
    // `ProfileScreen`은 하단 탭에 표시되지 않으므로, 탭 인덱스를 조정
    int bottomNavIndex = (_currentTabIndex == 3) ? 2 : _currentTabIndex;

    return Scaffold(
      // .tsx의 `{currentTab === "today" && <TodayTab ... />}` 로직
      // `IndexedStack`은 탭을 전환할 때 각 탭의 상태를 보존해줍니다.
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabPages, // 4. [수정] _tabPages -> tabPages
      ),

      // .tsx의 `Bottom Tab Navigation`
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: bottomNavIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// .tsx의 커스텀 하단 탭 바 UI
class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0, // 하단 여백 포함 높이
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.0)),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            // `flex items-end`
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 0: 탐색
              _buildNavItem(
                icon: LucideIcons.search,
                label: '탐색',
                index: 0,
                onTap: () => onTap(0),
              ),
              // 1: 오늘 (특별한 버튼 자리)
              const Spacer(),
              // 2: 기록
              _buildNavItem(
                icon: LucideIcons.calendar,
                label: '기록',
                index: 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
          // '오늘' 버튼 (중앙에 떠있는 버튼)
          Positioned(
            bottom: 8.0, // .tsx의 `marginBottom: "8px"`
            child: GestureDetector(
              onTap: () => onTap(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                // `transform -translate-y-2` + `scale-110`
                transform: Matrix4.translationValues(
                    0.0, currentIndex == 1 ? -16.0 : -8.0, 0.0)
                  ..scale(currentIndex == 1 ? 1.1 : 1.0),
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C42),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.house, size: 20.0, color: Colors.white), // 'home' 아이콘
                    SizedBox(height: 2.0),
                    Text('오늘',
                        style: TextStyle(color: Colors.white, fontSize: 12.0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color =
    isSelected ? const Color(0xFFFF8C42) : Colors.grey.shade500;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? Colors.orange.shade50 : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20.0, color: color),
              const SizedBox(height: 4.0),
              Text(label, style: TextStyle(fontSize: 12.0, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}