import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// 1. [추가] 공용 위젯 2개를 import 합니다. (프로젝트 이름 b612_1 적용)
import 'package:b612_1/widgets/step_page_indicator.dart';
import 'package:b612_1/widgets/step_progress_bar.dart';

// 2. [삭제] custom_back_button import는 StepProgressBar가
//    내부적으로 사용하므로 여기서는 필요 없습니다.
// import 'package:b612_1/widgets/custom_back_button.dart';

import 'package:b612_1/screens/personality_result/personality_result_screen.dart'
    show PersonalityType;
import 'package:b612_1/widgets/gradient_button.dart';
import 'package:b612_1/widgets/selection_option_button.dart';

import 'package:b612_1/models/personality_type.dart';

// --- 데이터 모델 (이 부분은 변경 없음) ---
class OptionData {
  final String text;
  final PersonalityType value; // 'string' 대신 enum을 사용

  OptionData({required this.text, required this.value});
}

class QuestionData {
  final String question;
  final List<OptionData> options;

  QuestionData({required this.question, required this.options});
}

// .tsx의 `questions` 상수
final List<QuestionData> _questions = [
  QuestionData(
    question: "새로운 사람들과 만나는 상황에서 어떤 기분이 드나요?",
    options: [
      OptionData(text: "설레고 즐거운 기분이 든다", value: PersonalityType.extrovert),
      OptionData(text: "약간 부담스럽지만 괜찮다", value: PersonalityType.ambivert),
      OptionData(text: "피하고 싶고 부담스럽다", value: PersonalityType.introvert)
    ],
  ),
  QuestionData(
    question: "스트레스가 쌓였을 때 어떻게 해소하시나요?",
    options: [
      OptionData(text: "친구들과 만나서 이야기하며 해소한다", value: PersonalityType.extrovert),
      OptionData(text: "상황에 따라 혼자 있거나 사람들과 만난다", value: PersonalityType.ambivert),
      OptionData(text: "혼자만의 시간을 가지며 조용히 해소한다", value: PersonalityType.introvert)
    ],
  ),
  QuestionData(
    question: "주말에 어떤 계획을 세우는 것을 선호하시나요?",
    options: [
      OptionData(text: "친구들과 함께하는 활동적인 계획", value: PersonalityType.extrovert),
      OptionData(text: "그때 기분에 따라 결정한다", value: PersonalityType.ambivert),
      OptionData(text: "집에서 혼자 보내는 조용한 시간", value: PersonalityType.introvert)
    ],
  ),
  QuestionData(
    question: "새로운 환경에 적응하는 방식은?",
    options: [
      OptionData(text: "적극적으로 다가가며 빠르게 적응한다", value: PersonalityType.extrovert),
      OptionData(text: "천천히 관찰하며 점진적으로 적응한다", value: PersonalityType.ambivert),
      OptionData(text: "조심스럽게 관찰 후 천천히 적응한다", value: PersonalityType.introvert)
    ],
  ),
  QuestionData(
    question: "에너지를 충전하는 방법은?",
    options: [
      OptionData(text: "사람들과 함께 시간을 보낼 때", value: PersonalityType.extrovert),
      OptionData(text: "혼자 있을 때와 사람들과 있을 때 모두", value: PersonalityType.ambivert),
      OptionData(text: "혼자만의 조용한 시간을 가질 때", value: PersonalityType.introvert)
    ],
  )
];

// --- 메인 위젯 (StatefulWidget) ---
class PersonalityTestScreen extends StatefulWidget {
  // .tsx의 `PersonalityTestProps`
  final Function(PersonalityType) onComplete;
  final VoidCallback onBack;

  const PersonalityTestScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

// .tsx의 `useState` 로직을 담당하는 State 클래스
class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  // `useState(0)`
  int _currentQuestionIndex = 0;
  // `useState<string[]>([])` -> `List<PersonalityType>`
  final List<PersonalityType> _answers = [];
  // `useState<string>('')` -> `PersonalityType?` (nullable)
  PersonalityType? _selectedAnswerValue;

  // `handleAnswerSelect`
  void _handleAnswerSelect(PersonalityType value) {
    setState(() {
      _selectedAnswerValue = value;
    });
  }

  // `handleNext`
  void _handleNext() {
    if (_selectedAnswerValue == null) return;

    // 답변 저장
    _answers.add(_selectedAnswerValue!);

    if (_currentQuestionIndex < _questions.length - 1) {
      // 다음 질문으로
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerValue = null; // 다음 질문을 위해 선택 초기화
      });
    } else {
      // 테스트 완료 - 결과 계산
      final result = _calculateResult(_answers);
      widget.onComplete(result);
    }
  }

  // `handlePrev`
  void _handlePrev() {
    if (_currentQuestionIndex > 0) {
      // 이전 질문으로
      setState(() {
        _currentQuestionIndex--;
        // 이전 답변이 있다면 복원 (선택사항)
        if (_answers.isNotEmpty) {
          _selectedAnswerValue = _answers.removeLast();
        }
      });
    } else {
      // 첫 질문에서 뒤로가기 (e.g. 온보딩 화면으로)
      widget.onBack();
    }
  }

  // `calculateResult`
  PersonalityType _calculateResult(List<PersonalityType> allAnswers) {
    // .tsx의 로직을 Dart로 변환
    int introvertCount =
        allAnswers.where((a) => a == PersonalityType.introvert).length;
    int extrovertCount =
        allAnswers.where((a) => a == PersonalityType.extrovert).length;
    int ambivertCount =
        allAnswers.where((a) => a == PersonalityType.ambivert).length;

    // `.tsx`의 로직 그대로 적용
    if (ambivertCount >= 2) return PersonalityType.ambivert;
    if (extrovertCount > introvertCount) return PersonalityType.extrovert;
    if (introvertCount > extrovertCount) return PersonalityType.introvert;
    return PersonalityType.ambivert; // 동점일 경우
  }

  @override
  Widget build(BuildContext context) {
    // 현재 질문 데이터
    final QuestionData currentQuestion = _questions[_currentQuestionIndex];
    // 3. [삭제] progress 변수는 StepProgressBar가 내부에서 계산하므로 필요 없습니다.
    // final double progress = (_currentQuestionIndex + 1) / _questions.length;
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    // `div (background)`
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 4. [교체] _buildTopBar(context, progress) 대신
                //    공용 StepProgressBar 위젯을 사용합니다.
                StepProgressBar(
                  currentStep: _currentQuestionIndex + 1, // 1-based index
                  totalSteps: _questions.length,
                  onBack: _handlePrev,
                ),

                // --- 헤더 ---
                _buildHeader(context),

                // --- 질문 카드 ---
                // `flex-1`
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      // 카드가 작을 경우 중앙 정렬
                      child: _buildQuestionCard(context, currentQuestion),
                    ),
                  ),
                ),

                // --- 다음 버튼 ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: GradientButton(
                    text: isLastQuestion ? "결과 보기" : "다음",
                    // `disabled={!selectedAnswer}`
                    onPressed: _selectedAnswerValue != null ? _handleNext : null,
                  ),
                ),

                // 5. [교체] _buildPageIndicator(context) 대신
                //    공용 StepPageIndicator 위젯을 사용합니다.
                StepPageIndicator(
                  currentStep: _currentQuestionIndex, // 0-based index
                  totalSteps: _questions.length,
                  onDotTapped: (index) {
                    // .tsx 원본에서 탭 기능이 없었으므로 비워둡니다.
                    // (OnboardingIntroScreen과 달리 테스트는 순서대로 푸는 것이 좋습니다)
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 6. [삭제] _buildTopBar 메서드 전체가 삭제되었습니다. ---
  // Widget _buildTopBar(BuildContext context, double progress) { ... }

  // --- UI 빌더 메서드 (가독성을 위해 분리) ---

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // `h1`
        Text(
          '성향 테스트',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        // `p`
        Text(
          '나에게 맞는 소확행을 찾기 위한 간단한 질문이에요',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionData question) {
    return Card(
      elevation: 8.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // `h2 (question)`
            Text(
              question.question,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24.0),
            // `space-y-3`
            Column(
              children: question.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  // 2. 1단계에서 만든 공용 위젯 사용!
                  child: SelectionOptionButton(
                    text: option.text,
                    isSelected: _selectedAnswerValue == option.value,
                    onPressed: () => _handleAnswerSelect(option.value),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

// --- 7. [삭제] _buildPageIndicator 메서드 전체가 삭제되었습니다. ---
// Widget _buildPageIndicator(BuildContext context) { ... }
}