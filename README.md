# Todo

단축어·등 두드리기로 할 일을 추가하고, 잠금화면 Live Activity·위젯에서 큼직하게 보고 바로 체크(삭제)하는 iOS 투두 앱.

## 기능

- **할 일 추가**: App Intent / 단축어 / Siri (입력창 → 저장)
- **잠금화면 Live Activity**: 큰 글씨로 할 일 표시, 동그라미 탭 시 삭제
- **잠금화면·홈 위젯**: 중형/대형 위젯에서 바로 체크
- **등 두드리기**: 손쉬운 사용 → 뒤로 탭에 단축어 연결

## 요구사항

- iOS 17.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (프로젝트 재생성 시)

## 빌드

```bash
xcodegen generate
open BigTodo.xcodeproj
```

Xcode에서 **BigTodo** / **TodoWidgetExtension** 두 타깃 모두 본인 **Team**으로 서명 후 실기기에서 실행.

## 설정 (최초 1회)

1. 단축어 앱 → **할 일 추가** 액션으로 단축어 만들기
2. 설정 → 손쉬운 사용 → 터치 → **뒤로 탭(이중)** 에 단축어 연결
3. 잠금화면 → 위젯 추가 → **Todo** (중형/대형)
4. Todo 앱을 한 번 실행 (Live Activity 시작)

## 구조

```
BigTodo/          메인 앱 (SwiftUI)
TodoWidget/       위젯 + Live Activity 익스텐션
Shared/           공유 모델, 저장소, App Intents
project.yml       XcodeGen 설정
```

## 라이선스

MIT
