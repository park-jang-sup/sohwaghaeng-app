import 'package:flutter/material.dart';
// import 'package:lucide_flutter/lucide_flutter.dart'; // [수정] 삭제
import 'package:b612_1/widgets/custom_back_button.dart';
import 'package:b612_1/widgets/gradient_button.dart';
import 'package:b612_1/widgets/personality_badge.dart';
import 'package:b612_1/models/personality_type.dart';

class PersonalityData {
  final String title;
  final String emoji;
  final String description;
  final List<String> traits;
  final List<String> recommendedMissions;
  final List<Color> gradientColors;
  final Widget icon;

  PersonalityData({
    required this.title,
    required this.emoji,
    required this.description,
    required this.traits,
    required this.recommendedMissions,
    required this.gradientColors,
    required this.icon,
  });
}

// [수정] LucideIcons -> Material Icons로 변경
final Map<PersonalityType, PersonalityData> personalityDataMap = {
  PersonalityType.introvert: PersonalityData(
    title: "조용한 성찰가",
    emoji: "🌙",
    description: "혼자만의 시간을 소중히 여기며, 깊이 있는 경험을 추구하는 당신",
    traits: ["깊이 있는 사고", "집중력 강함", "신중한 결정", "질 높은 인간관계"],
    recommendedMissions: [
      "혼자만의 산책하기",
      "좋아하는 책 한 챕터 읽기",
      "일기 쓰며 하루 되돌아보기",
      "명상이나 요가하기"
    ],
    gradientColors: [const Color(0xFFEDE9FE), const Color(0xFFDBEAFE)],
    // LucideIcons.sparkles -> Icons.auto_awesome (반짝임 효과)
    icon: const Icon(Icons.auto_awesome, size: 24, color: Color(0xFFA855F7)),
  ),
  PersonalityType.extrovert: PersonalityData(
    title: "에너지 넘치는 소통가",
    emoji: "☀️",
    description: "사람들과의 만남에서 에너지를 얻고, 활동적인 경험을 좋아하는 당신",
    traits: ["활발한 소통", "에너지 넘침", "적극적 참여", "새로운 도전"],
    recommendedMissions: [
      "친구와 함께 새로운 카페 가기",
      "모르는 사람에게 친절 베풀기",
      "야외 활동 참여하기",
      "새로운 사람들과 대화하기"
    ],
    gradientColors: [const Color(0xFFFFEDD5), const Color(0xFFFEF9C3)],
    // LucideIcons.users -> Icons.groups (사람들)
    icon: const Icon(Icons.groups, size: 24, color: Color(0xFFF97316)),
  ),
  PersonalityType.ambivert: PersonalityData(
    title: "균형잡힌 실천가",
    emoji: "⚖️",
    description: "상황에 따라 유연하게 적응하며, 다양한 경험을 즐기는 당신",
    traits: ["균형잡힌 성향", "상황 적응력", "다양한 관심사", "유연한 사고"],
    recommendedMissions: [
      "기분에 따라 혼자 또는 함께 시간보내기",
      "새로운 취미 도전해보기",
      "자연 속에서 힐링하기",
      "창의적인 활동하기"
    ],
    gradientColors: [const Color(0xFFDCFCE7), const Color(0xFFCCFBF1)],
    // LucideIcons.heart -> Icons.balance (균형/저울 아이콘 사용)
    icon: const Icon(Icons.balance, size: 24, color: Color(0xFF22C55E)),
  ),
};

class PersonalityResultScreen extends StatefulWidget {
  final PersonalityType personalityType;
  final Function(String nickname, String personalityDescription) onComplete;
  final VoidCallback onBack;

  const PersonalityResultScreen({
    super.key,
    required this.personalityType,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<PersonalityResultScreen> createState() =>
      _PersonalityResultScreenState();
}

class _PersonalityResultScreenState extends State<PersonalityResultScreen> {
  bool _isNicknameStep = false;
  final TextEditingController _nicknameController = TextEditingController();
  late PersonalityData _personality;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _personality = personalityDataMap[widget.personalityType]!;

    _nicknameController.addListener(() {
      final isNotEmpty = _nicknameController.text.trim().isNotEmpty;
      if (_isButtonEnabled != isNotEmpty) {
        setState(() {
          _isButtonEnabled = isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_isNicknameStep) {
      setState(() {
        _isNicknameStep = true;
      });
    } else {
      final nickname = _nicknameController.text.trim();
      if (nickname.isNotEmpty) {
        widget.onComplete(nickname, _personality.title);
      }
    }
  }

  void _handleBackFromNickname() {
    setState(() {
      _isNicknameStep = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5D6), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isNicknameStep
                  ? _buildNicknameStep(context, _personality)
                  : _buildResultStep(context, _personality),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStep(BuildContext context, PersonalityData personality) {
    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: CustomBackButton(
            onPressed: widget.onBack,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmojiHeader(
                  "테스트 완료!",
                  "당신의 성향을 분석했어요",
                  personality.emoji,
                  size: 96.0,
                  emojiSize: 40.0
              ),
              const SizedBox(height: 32.0),
              Card(
                elevation: 8.0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: PersonalityBadge(
                          icon: personality.icon,
                          title: personality.title,
                          gradientColors: personality.gradientColors,
                          paddingHorizontal: 16.0,
                          paddingVertical: 10.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        personality.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
                      ),
                      const SizedBox(height: 24.0),

                      _buildSectionTitle("주요 특징"),
                      const SizedBox(height: 12.0),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 5,
                        children: personality.traits.map(_buildTraitItem).toList(),
                      ),

                      const SizedBox(height: 24.0),

                      _buildSectionTitle("추천 소확행"),
                      const SizedBox(height: 12.0),
                      Column(
                        children: personality.recommendedMissions
                            .take(3)
                            .map(_buildMissionItem)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
        GradientButton(
          text: "닉네임 설정하기",
          onPressed: _handleContinue,
        ),
      ],
    );
  }

  Widget _buildNicknameStep(BuildContext context, PersonalityData personality) {
    return Column(
      key: const ValueKey('nickname'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: CustomBackButton(
            onPressed: _handleBackFromNickname,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmojiHeader(
                  "마지막 단계예요!",
                  "어떻게 불러드릴까요?",
                  personality.emoji,
                  size: 80.0,
                  emojiSize: 32.0
              ),
              const SizedBox(height: 32.0),

              Card(
                elevation: 8.0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '닉네임',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _nicknameController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: "닉네임을 입력해주세요",
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '최대 20자까지 입력 가능해요',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey.shade500),
                      ),

                      const SizedBox(height: 24.0),

                      PersonalityBadge(
                        icon: personality.icon,
                        title: personality.title,
                        gradientColors: personality.gradientColors,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        GradientButton(
          text: "소확행 시작하기! 🌟",
          onPressed: _handleContinue,
          disabled: !_isButtonEnabled,
        ),
      ],
    );
  }

  Widget _buildEmojiHeader(String title, String subtitle, String emoji, {double size = 96.0, double emojiSize = 40.0}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
          fontSize: 14.0
      ),
    );
  }

  Widget _buildTraitItem(String trait) {
    return Row(
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Color(0xFFF9A825),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          trait,
          style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildMissionItem(String mission) {
    return Row(
      children: [
        const Text("✨", style: TextStyle(fontSize: 12.0)),
        const SizedBox(width: 8.0),
        Text(
          mission,
          style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}