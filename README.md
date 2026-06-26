# HWP Suite

> **rhwp 기반 HWP/HWPX 뷰어 및 에디터 안드로이드 앱**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)]()

---

## 📖 소개

**HWP Suite**는 [rhwp](https://github.com/edwardkim/rhwp) 오픈소스 엔진을 기반으로 만들어진 안드로이드용 HWP/HWPX 문서 뷰어 및 에디터 앱입니다.

한컴오피스 없이도 스마트폰에서 바로 `.hwp` / `.hwpx` 파일을 열고, 편집하고, PDF로 내보낼 수 있습니다.

---

## ✨ 주요 기능

### 📂 파일 관리
- **최근 문서** — 최근에 열었던 HWP/HWPX 파일 목록 관리
- **즐겨찾기** — 자주 사용하는 문서를 즐겨찾기로 등록
- **파일 탐색기** — Android 저장소를 직접 탐색하여 HWP 파일 검색
- **파일 검색** — 파일명으로 빠르게 검색

### ✏️ 뷰어 / 에디터 (rhwp 통합)
- **HWP 5.0 / HWPX** 파싱 및 완전 렌더링
- **텍스트 편집** — 입력, 삭제, 서식 적용
- **표 편집** — 행/열 추가·삭제, 셀 수식 계산
- **PDF 내보내기** — rhwp 내장 PDF export 기능
- **파일 공유** — Android 공유 Intent로 다른 앱에 전달
- **인쇄** — 시스템 인쇄 기능 연동

### 🔗 Android 통합
- `.hwp` / `.hwpx` 파일을 **기본 앱으로 열기** 등록
- 파일 앱, 이메일 첨부 등에서 바로 HWP Suite로 열기 가능
- Android 저장소 권한 자동 처리

---

## 📥 다운로드

| 파일 | 버전 | 크기 | 비고 |
|------|------|------|------|
| [HWP-Suite-v1.0.0-release.apk](./release/HWP-Suite-v1.0.0-release.apk) | v1.0.0 | 52.3 MB | Android 5.0 이상 |

> **설치 방법**: APK 파일을 안드로이드 기기에 전송 후, **설정 → 보안 → 알 수 없는 출처** 허용 후 설치

---

## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| **Framework** | Flutter 3.35.4 |
| **Language** | Dart 3.9.2 |
| **HWP Engine** | [rhwp](https://github.com/edwardkim/rhwp) (Rust + WebAssembly) |
| **에디터 방식** | WebView + rhwp 공식 웹 에디터 임베드 |
| **로컬 저장소** | SharedPreferences (최근 문서/즐겨찾기) |
| **상태 관리** | Provider |
| **파일 선택** | file_picker |
| **파일 공유** | share_plus |
| **UI 테마** | Material Design 3 (딥 블루) |

---

## 📦 주요 패키지

```yaml
dependencies:
  webview_flutter: 4.13.0     # rhwp 에디터 WebView
  file_picker: 8.1.7          # HWP 파일 선택
  share_plus: 10.1.4          # 파일 공유
  provider: 6.1.5+1           # 상태 관리
  shared_preferences: 2.5.3   # 최근 문서/즐겨찾기 저장
  hive: 2.2.3                 # 로컬 데이터베이스
  hive_flutter: 1.1.0
  path_provider: 2.1.5        # 파일 경로
  intl: 0.20.2                # 날짜 포맷
  url_launcher: 6.3.1         # 외부 링크
  permission_handler: 11.4.0  # 저장소 권한
```

---

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점 + 스플래시 화면
├── models/
│   └── document_model.dart      # 문서 데이터 모델
├── providers/
│   └── document_provider.dart   # 문서 상태 관리 (Provider)
├── screens/
│   ├── home_screen.dart         # 하단 네비게이션 홈
│   ├── recent_screen.dart       # 최근 문서 화면
│   ├── favorites_screen.dart    # 즐겨찾기 화면
│   ├── files_screen.dart        # 파일 탐색기 화면
│   ├── editor_screen.dart       # rhwp 에디터 화면
│   └── settings_screen.dart     # 설정 화면
├── services/
│   ├── document_service.dart    # 문서 저장/불러오기 서비스
│   └── rhwp_service.dart        # rhwp WebView HTML 생성
├── widgets/
│   └── document_card.dart       # 문서 카드 위젯
└── utils/
    └── app_theme.dart           # 앱 테마 정의
```

---

## 📖 빌드 가이드

Android Studio에서 빌드하는 전체 방법은 **[docs/ANDROID_STUDIO_BUILD_GUIDE.md](./docs/ANDROID_STUDIO_BUILD_GUIDE.md)** 를 참고하세요.

주요 내용:
- Flutter SDK 설치 및 플러그인 설정
- 프로젝트 열기 (GitHub 클론)
- 디버그 / 릴리즈 APK 빌드
- App Bundle (AAB) 빌드
- 에뮬레이터 및 실제 기기 실행
- 자주 발생하는 오류 해결

---

## 🚀 빌드 및 실행

### 사전 요구사항
- Flutter 3.35.4
- Android SDK (API 35)
- Java 17

### 개발 환경 설정

```bash
# 저장소 클론
git clone https://github.com/born-sinhae-yk/AHOP.git
cd AHOP

# 의존성 설치
flutter pub get

# 웹 프리뷰 실행
flutter build web --release
python3 -m http.server 5060 --directory build/web

# Android 앱 빌드 (디버그)
flutter build apk --debug

# Android 앱 빌드 (릴리즈)
flutter build apk --release

# Android App Bundle 빌드
flutter build aab --release
```

### Android 권한 (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_DOCUMENTS"/>
```

---

## 📱 화면 구성

```
┌─────────────────────────────┐
│  ◀  sample.hwp         ★ ⋮ │  ← 에디터 AppBar
├─────────────────────────────┤
│  💾저장  📄PDF  📤공유  🖨️인쇄 │  ← rhwp 도구 모음
├─────────────────────────────┤
│                             │
│   rhwp 에디터 (WebView)      │
│   HWP/HWPX 문서 렌더링       │
│   텍스트/표 편집 가능         │
│                             │
└─────────────────────────────┘

┌─────────────────────────────┐
│  최근 문서          🔍  ⋮   │  ← 홈 AppBar
├─────────────────────────────┤
│  📄 보고서.hwp               │
│     24.06.26  1.2 MB    ★  │
│  📄 계획서.hwpx              │
│     24.06.25  856 KB    ★  │
└─────────────────────────────┘
│ 최근문서 │ 즐겨찾기 │ 파일 │ 설정 │  ← 하단 네비게이션
└─────────────────────────────┘
```

---

## 🔧 rhwp 엔진 연동 방식

HWP Suite는 [rhwp](https://github.com/edwardkim/rhwp)의 공식 웹 에디터를 WebView에 임베드하는 방식으로 동작합니다.

```
Android 앱 (Flutter)
    │
    ├── 파일 선택 (FilePicker)
    │       │
    │       ▼
    ├── Base64 인코딩
    │       │
    │       ▼
    └── WebView (rhwp 에디터)
            │
            ├── edwardkim.github.io/rhwp 로드
            └── JavaScript로 파일 전달 → HWP 렌더링
```

JavaScript 채널(`HwpSuiteChannel`)을 통해 Flutter ↔ WebView 간 이벤트 통신이 이루어집니다.

---

## ⚠️ 주의사항

- rhwp 에디터 로드 시 **인터넷 연결이 필요**합니다
- 대용량 HWP 파일은 로딩 시간이 길어질 수 있습니다
- 본 앱은 한글과컴퓨터와 무관한 독립 오픈소스 프로젝트입니다

---

## 📄 라이선스

이 프로젝트는 **MIT 라이선스**로 공개됩니다.

- HWP 엔진: [rhwp](https://github.com/edwardkim/rhwp) — MIT License by edwardkim
- Flutter 앱: MIT License

---

## 🙏 감사의 말

- **[edwardkim](https://github.com/edwardkim)** — rhwp 오픈소스 HWP 엔진 개발
- **rhwp 기여자 전원** — 오픈소스 생태계에 기여해 주신 모든 분들

---

*"닫힌 포맷의 벽을 깨고, 모든 사람, 모든 플랫폼에서 한글 문서를"* — rhwp 프로젝트 모토
