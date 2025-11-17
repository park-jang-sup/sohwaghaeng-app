import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:b612_1/app_shell.dart' show UserProfile;

// .tsx의 availableEmojis
final List<String> _availableEmojis = [
  '😊', '😄', '🥰', '😎', '🤗', '🙃', '😇', '🤓', '🥳', '😌',
  '🌟', '✨', '🌈', '🦄', '🐱', '🐶', '🐻', '🐼', '🦊', '🐸',
  '🌸', '🌺', '🌻', '🌷', '🌹', '🍀', '🌿', '🌱', '🌳', '🍃'
];

// .tsx의 availableBioTags
final List<String> _availableBioTags = [
  '소확행 실천러', '일상 기록자', '작은 행복 수집가', '루틴 메이커',
  '성장하는 중', '긍정 에너지', '미니멀 라이프', '자기계발러',
  '감사 실천러', '건강한 삶', '창의적 생활', '도전하는 사람',
  '꾸준한 노력', '변화 추구자', '균형 잡힌 삶', '자연 사랑',
  '책 읽는 사람', '운동하는 중', '요리 탐험가', '취미 생활자',
  '여행 꿈나무', '학습하는 중', '예술 애호가', '음악 러버'
];


class ProfileScreen extends StatefulWidget {
  // .tsx의 Props
  final UserProfile userProfile;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final Function(UserProfile) onUpdateProfile;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onBack,
    required this.onLogout,
    required this.onUpdateProfile
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // .tsx의 useState에 해당하는 상태 변수들
  bool _isEditing = false;
  late TextEditingController _nicknameController;
  late String _selectedEmoji;
  late String _selectedBio;

  bool _notifications = true;
  bool _missionReminder = true;
  bool _weeklyReport = false;

  // .tsx의 showEmojiPicker, showBioSelector는
  // showModalBottomSheet로 대체하므로 별도 상태가 필요 없습니다.

  @override
  void initState() {
    super.initState();
    // AppShell에서 받은 userProfile로 로컬 상태 초기화
    _nicknameController = TextEditingController(text: widget.userProfile.nickname);
    _selectedEmoji = widget.userProfile.profileEmoji;
    _selectedBio = widget.userProfile.bio;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // .tsx의 handleSave
  void _handleSave() {
    // 1. AppShell에 보낼 새 UserProfile 객체 생성
    final updatedProfile = UserProfile(
      nickname: _nicknameController.text.trim(),
      profileEmoji: _selectedEmoji,
      bio: _selectedBio,
      email: widget.userProfile.email, // 이메일 등 기존 정보 유지
      personalityType: widget.userProfile.personalityType,
    );
    // 2. AppShell의 핸들러 호출
    widget.onUpdateProfile(updatedProfile);

    // 3. 편집 모드 종료
    setState(() {
      _isEditing = false;
    });

    // TODO: .tsx의 toast.success("프로필이 업데이트되었습니다.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필이 업데이트되었습니다.'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // .tsx의 헤더와 배경색
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.grey.shade600),
          onPressed: widget.onBack, // AppShell의 핸들러 호출
        ),
        title: const Text('프로필 & 설정', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      // .tsx의 `p-4 space-y-4`
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileEditCard(context),
            const SizedBox(height: 16.0),
            _buildBioTagCard(context),
            const SizedBox(height: 16.0),
            _buildPersonalityTestCard(context),
            const SizedBox(height: 16.0),
            _buildNotificationCard(context),
            const SizedBox(height: 16.0),
            _buildOtherSettingsCard(context),
            const SizedBox(height: 16.0),
            _buildAccountInfoCard(context),
            const SizedBox(height: 16.0),
            _buildLogoutCard(context),
          ],
        ),
      ),
    );
  }

  /// 프로필 정보 카드
  Widget _buildProfileEditCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('프로필 정보', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: Icon(_isEditing ? LucideIcons.check : LucideIcons.pencil, size: 16.0),
                  label: Text(_isEditing ? '저장' : '편집'),
                  onPressed: () {
                    if (_isEditing) {
                      _handleSave();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7F50)),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                // .tsx의 이모지 선택기
                GestureDetector(
                  onTap: () {
                    if (_isEditing) _showEmojiPicker(context);
                  },
                  child: Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // ringColor: Colors.orange.shade200,
                      border: Border.all(color: Colors.orange.shade200, width: 3.0),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5.0)],
                    ),
                    child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28.0))),
                  ),
                ),
                const SizedBox(width: 16.0),
                // .tsx의 닉네임
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                          ? TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: '닉네임',
                          border: OutlineInputBorder(),
                        ),
                      )
                          : Text(_nicknameController.text, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.userProfile.personalityType,
                        style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 자기소개 태그 카드
  Widget _buildBioTagCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '# 자기소개 태그',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.pencil, size: 16.0),
                  color: const Color(0xFFFF7F50),
                  onPressed: () => _showBioSelector(context),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                '# $_selectedBio',
                style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성향 테스트 다시하기 카드
  Widget _buildPersonalityTestCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(LucideIcons.sparkles, color: Colors.orange.shade500),
        title: const Text('성향 테스트 다시하기'),
        trailing: Text(
          widget.userProfile.personalityType,
          style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
        ),
        onTap: () {
          // TODO: 성향 테스트 재시작 로직 (AppShell의 핸들러 호출)
          print('성향 테스트 다시하기');
        },
      ),
    );
  }

  /// 알림 설정 카드
  Widget _buildNotificationCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.bell, size: 20.0, color: Colors.orange.shade500),
                const SizedBox(width: 8.0),
                const Text('알림 설정', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8.0),
            SwitchListTile(
              title: const Text('푸시 알림', style: TextStyle(fontSize: 14.0)),
              subtitle: Text('앱 알림 받기', style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600)),
              value: _notifications,
              onChanged: (val) => setState(() => _notifications = val),
              activeColor: Theme.of(context).primaryColor,
            ),
            SwitchListTile(
              title: const Text('미션 리마인더', style: TextStyle(fontSize: 14.0)),
              subtitle: Text('완료하지 않은 미션 알림', style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600)),
              value: _missionReminder,
              onChanged: _notifications ? (val) => setState(() => _missionReminder = val) : null,
              activeColor: Theme.of(context).primaryColor,
            ),
            SwitchListTile(
              title: const Text('주간 리포트', style: TextStyle(fontSize: 14.0)),
              subtitle: Text('주간 달성 결과 받기', style: TextStyle(fontSize: 12.0, color: Colors.grey.shade600)),
              value: _weeklyReport,
              onChanged: _notifications ? (val) => setState(() => _weeklyReport = val) : null,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 기타 설정 카드 (개인정보, 고객센터)
  Widget _buildOtherSettingsCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(LucideIcons.lock, size: 20.0, color: Colors.grey.shade500),
            title: const Text('개인정보 처리방침'),
            onTap: () => print('개인정보 처리방침'),
          ),
          ListTile(
            leading: Icon(LucideIcons.info, size: 20.0, color: Colors.grey.shade500),
            title: const Text('고객센터'),
            onTap: () => print('고객센터'),
          ),
        ],
      ),
    );
  }

  /// 계정 정보 카드
  Widget _buildAccountInfoCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.user, size: 20.0, color: Colors.grey.shade500),
                const SizedBox(width: 8.0),
                const Text('계정 정보', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('이메일', style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600)),
                Text(widget.userProfile.email, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 카드
  Widget _buildLogoutCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(LucideIcons.logOut, size: 20.0, color: Colors.red.shade600),
        title: Text('로그아웃', style: TextStyle(color: Colors.red.shade600)),
        onTap: widget.onLogout, // AppShell의 핸들러 호출
      ),
    );
  }

  /// .tsx의 `showEmojiPicker` (Modal Sheet)
  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프로필 아이콘 선택',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: _availableEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _availableEmojis[index];
                      final isSelected = _selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedEmoji = emoji);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange.shade100 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                            border: isSelected ? Border.all(color: Colors.orange.shade300, width: 2.0) : null,
                          ),
                          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24.0))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// .tsx의 `showBioSelector` (Modal Sheet)
  void _showBioSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '보유한 태그 중에서 선택하세요',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 4.0, // 버튼을 더 넓게
                    ),
                    itemCount: _availableBioTags.length,
                    itemBuilder: (context, index) {
                      final tag = _availableBioTags[index];
                      final isSelected = _selectedBio == tag;
                      return OutlinedButton(
                        onPressed: () {
                          setState(() => _selectedBio = tag);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.orange.shade100 : Colors.grey.shade50,
                          foregroundColor: isSelected ? Colors.orange.shade700 : Colors.grey.shade700,
                          side: BorderSide(
                            color: isSelected ? Colors.orange.shade300 : Colors.grey.shade200,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 12.0)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}