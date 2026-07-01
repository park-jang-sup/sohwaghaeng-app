# 🍀 소확행 (Sohwaghaeng App)

"작은 행동 하나가 하루를 바꾼다." 일상 속 작은 미션을 수행하고 기록하며, 나만의 행복 루틴을 만들어가는 **Flutter 기반의 데일리 퀘스트 앱**입니다.

* **팀 프로젝트 원본 저장소:** https://github.com/shine0987/sohwaghaeng_app

## 🛠 기술 스택
* **Framework/Language:** Flutter, Dart
* **Backend/DB:** Firebase (Auth, Firestore, Storage)
* **AI/ML:** KoBERT (TFLite)
* **Architecture:** Singleton Pattern, Service Layer

## 🚀 주요 기능
* **일일 퀘스트 시스템:** 매일 사용자에게 작은 행복을 실천할 수 있는 미션을 제공하고 완료 여부를 기록합니다.
* **퍼스널리티 테스트:** 사용자 성향을 분석하여 맞춤형 퀘스트를 추천합니다.
* **감정 분석 서비스:** KoBERT AI 모델을 TFLite로 경량화하여 온디바이스에서 사용자의 감정을 분석합니다.
* **통합 소셜 로그인:** Google, Kakao, Naver, Guest 로그인을 지원하여 사용자 편의성을 높였습니다.

## 💡 기술적 주안점 및 문제 해결 (Troubleshooting & Optimization)
* **아키텍처 설계 및 계층 분리:** Service Layer 패턴과 Singleton 패턴을 적용하여 비즈니스 로직과 UI 계층을 명확히 분리하고, 코드의 재사용성과 유지보수성을 극대화했습니다.
* **복합 인증 시스템 구현:** 다양한 소셜 로그인 프로세스를 통합하여 확장성 있는 인증 구조를 설계했습니다.
* **일일 미션 초기화 로직 최적화:** 사용자의 마지막 접속 시간과 서버 타임스탬프를 비교하는 로직을 설계하여, 오프라인 환경에서도 미션 초기화가 정확하고 안정적으로 이루어지도록 구현했습니다.
* **AI 경량화 최적화:** KoBERT 모델을 TFLite로 경량화하여 모바일 환경에서 별도의 서버 통신 없이 즉각적인 감정 분석이 가능하도록 성능을 최적화했습니다.
