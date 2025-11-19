import 'package:flutter/material.dart';
// import 'package:lucide_flutter/lucide_flutter.dart'; // [수정] 삭제
import 'package:b612_1/models/mission.dart';
import 'package:b612_1/app_shell.dart' show UserProfile;
import 'package:b612_1/screens/today_tab/today_tab_screen.dart';
import 'package:b612_1/screens/mission_browser/mission_browser_screen.dart';
import 'package:b612_1/screens/history_tab/history_tab_screen.dart';
import 'package:b612_1/screens/profile_screen/profile_screen.dart';

class MainAppScaffold extends StatefulWidget {
  final List<Mission> missions;
  final Map<String, bool> attendanceData;
  final Set<String> addedMissionIds;
  final UserProfile userProfile;
  final Function(String) onToggleMission;
  final VoidCallback onAddMission;
  final Function(String, String?) onAddPhoto;
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
  int _currentTabIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _handleNavigateToProfile() {
    setState(() {
      _currentTabIndex = 3;
    });
  }

  void _handleNavigateToRecords() {
    setState(() {
      _currentTabIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabPages = [
      MissionBrowserScreen(
        onAddMission: widget.onAddMissionFromBrowser,
        addedMissionIds: widget.addedMissionIds,
      ),
      TodayTabScreen(
        missions: widget.missions,
        attendanceData: widget.attendanceData,
        onToggleMission: widget.onToggleMission,
        onAddMission: widget.onAddMission,
        onAddPhoto: widget.onAddPhoto,
        onDeleteMission: widget.onDeleteMission,
      ),
      HistoryTabScreen(
        onOpenProfile: () => _handleNavigateToProfile(),
        profileEmoji: widget.userProfile.profileEmoji,
        userBio: widget.userProfile.bio,
      ),
      ProfileScreen(
        userProfile: widget.userProfile,
        onBack: () => _handleNavigateToRecords(),
        onLogout: widget.onLogout,
        onUpdateProfile: widget.onUpdateProfile,
      ),
    ];

    int bottomNavIndex = (_currentTabIndex == 3) ? 2 : _currentTabIndex;

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabPages,
      ),
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: bottomNavIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.0)),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // [수정] LucideIcons.search -> Icons.search
              _buildNavItem(
                icon: Icons.search,
                label: '탐색',
                index: 0,
                onTap: () => onTap(0),
              ),
              const Spacer(),
              // [수정] LucideIcons.calendar -> Icons.calendar_month
              _buildNavItem(
                icon: Icons.calendar_month,
                label: '기록',
                index: 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
          Positioned(
            bottom: 8.0,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                    // [수정] LucideIcons.house -> Icons.home
                    Icon(Icons.home, size: 20.0, color: Colors.white),
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