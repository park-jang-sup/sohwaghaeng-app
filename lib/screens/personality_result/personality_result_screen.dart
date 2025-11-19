import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
// 1단계에서 만든 공용 위젯들을 import 합니다.
import 'package:b612_1/widgets/custom_back_button.dart';
import 'package:b612_1/widgets/gradient_button.dart';
import 'package:b612_1/widgets/personality_badge.dart';
import 'package:b612_1/models/personality_type.dart';

// --- 데이터 모델 (TSX의 personalityData 객체에 해당) --

/// 성향 데이터 구조를 class로 정의
class PersonalityData {
  final String title;
  final String emoji;
  final String description;
  final List<String> traits;
  final List<String> recommendedMissions;
  final List<Color> gradientColors; // `color: "from-purple-100 to-blue-100"`
  final Widget icon; // `icon: <Sparkles ...>`

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

// .tsx의 `personalityData` 상수를 Dart의 `Map`으로 변환
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
    // from-purple-100 to-blue-100
    gradientColors: [const Color(0xFFEDE9FE), const Color(0xFFDBEAFE)],
    icon: const Icon(LucideIcons.sparkles, size: 24, color: Color(0xFFA855F7)),
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
    // from-orange-100 to-yellow-100
    gradientColors: [const Color(0xFFFFEDD5), const Color(0xFFFEF9C3)],
    icon: const Icon(LucideIcons.users, size: 24, color: Color(0xFFF97316)),
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
    // from-green-100 to-teal-100
    gradientColors: [const Color(0xFFDCFCE7), const Color(0xFFCCFBF1)],
    icon: const Icon(LucideIcons.heart, size: 24, color: Color(0xFF22C55E)),
  ),
};

// --- 메인 위젯 (StatefulWidget) ---

class PersonalityResultScreen extends StatefulWidget {
  // .tsx의 Props에 해당
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

// .tsx의 useState 로직을 담당하는 State 클래스
class _PersonalityResultScreenState extends State<PersonalityResultScreen> {
  bool _isNicknameStep = false;
  final TextEditingController _nicknameController = TextEditingController();
  late PersonalityData _personality;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 성향 데이터를 조회합니다.
    _personality = personalityDataMap[widget.personalityType]!;

    // 닉네임 입력 필드를 감지하여 버튼 활성화 여부를 결정합니다.
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

  // --- 상태 변경 함수 (React의 핸들러) ---

  // `handleContinue`
  void _handleContinue() {
    if (!_isNicknameStep) {
      // 결과 화면 -> 닉네임 화면
      setState(() {
        _isNicknameStep = true;
      });
    } else {
      // 닉네임 화면 -> 완료
      final nickname = _nicknameController.text.trim();
      if (nickname.isNotEmpty) {
        widget.onComplete(nickname, _personality.title);
      }
    }
  }

  // `handleBackFromNickname`
  void _handleBackFromNickname() {
    // 닉네임 화면 -> 결과 화면
    setState(() {
      _isNicknameStep = false;
    });
  }

  // --- UI 빌드 ---

  @override
  Widget build(BuildContext context) {
    // .tsx의 `style={{ background: ... }}`
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
            // `isNicknameStep` 상태에 따라 다른 UI를 보여줍니다.
            // (AnimatedSwitcher로 부드러운 전환 효과 추가)
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

  /// 결과 화면 UI (isNicknameStep = false)
  Widget _buildResultStep(BuildContext context, PersonalityData personality) {
    return Column(
      key: const ValueKey('result'), // AnimatedSwitcher를 위한 Key
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단 뒤로가기 버튼
        Align(
          alignment: Alignment.topLeft,
          child: CustomBackButton(
            onPressed: widget.onBack, // 테스트 이전 화면으로 돌아가기
          ),
        ),
        // `flex-1 flex flex-col justify-center`
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
              // `Card`
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
                      // 성향 타이틀 배지
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
                      // `description`
                      Text(
                        personality.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
                      ),
                      const SizedBox(height: 24.0),

                      // 특징
                      _buildSectionTitle("주요 특징"),
                      const SizedBox(height: 12.0),
                      // `grid grid-cols-2 gap-2`
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true, // Column 안에서 GridView가 크기를 잡도록
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 5, // 항목의 가로:세로 비율
                        children: personality.traits.map(_buildTraitItem).toList(),
                      ),

                      const SizedBox(height: 24.0),

                      // 추천 미션
                      _buildSectionTitle("추천 소확행"),
                      const SizedBox(height: 12.0),
                      // `space-y-2`
                      Column(
                        children: personality.recommendedMissions
                            .take(3) // 3개만 표시
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
        // 하단 버튼
        GradientButton(
          text: "닉네임 설정하기",
          onPressed: _handleContinue,
        ),
      ],
    );
  }

  /// 닉네임 입력 화면 UI (isNicknameStep = true)
  Widget _buildNicknameStep(BuildContext context, PersonalityData personality) {
    return Column(
      key: const ValueKey('nickname'), // AnimatedSwitcher를 위한 Key
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단 뒤로가기 버튼
        Align(
          alignment: Alignment.topLeft,
          child: CustomBackButton(
            onPressed: _handleBackFromNickname, // 결과 화면으로 돌아가기
          ),
        ),
        // `flex-1 flex flex-col justify-center`
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmojiHeader(
                  "마지막 단계예요!",
                  "어떻게 불러드릴까요?",
                  personality.emoji,
                  size: 80.0, // 결과창보다 약간 작게
                  emojiSize: 32.0
              ),
              const SizedBox(height: 32.0),

              // `Card`
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
                      // `label`
                      Text(
                        '닉네임',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // `Input`
                      TextField(
                        controller: _nicknameController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: "닉네임을 입력해주세요",
                          counterText: "", // "0/20" 카운터 숨기기
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
                      // `p`
                      Text(
                        '최대 20자까지 입력 가능해요',
                        style: TextStyle(fontSize: 12.0, color: Colors.grey.shade500),
                      ),

                      const SizedBox(height: 24.0),

                      // 성향 배지
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
        // 하단 버튼
        GradientButton(
          text: "소확행 시작하기! 🌟",
          onPressed: _handleContinue,
          disabled: !_isButtonEnabled, // 닉네임이 비어있으면 비활성화
        ),
      ],
    );
  }

  // --- 공통 UI 조각 (가독성을 위해 분리) ---

  /// 상단 이모지 헤더
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

  /// "주요 특징" 섹션 제목
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

  /// 특징 목록의 개별 항목
  Widget _buildTraitItem(String trait) {
    return Row(
      children: [
        // `w-2 h-2 bg-orange-400 rounded-full`
        Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Color(0xFFF9A825), // 오렌지색
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8.0),
        // `text-xs text-gray-700`
        Text(
          trait,
          style: TextStyle(fontSize: 12.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  /// 추천 미션의 개별 항목
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