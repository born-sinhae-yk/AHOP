# HWP Suite — Android Studio 빌드 가이드

> Flutter 프로젝트를 Android Studio에서 열고 APK / App Bundle을 빌드하는 방법을 단계별로 안내합니다.

---

## 📋 목차

1. [사전 요구사항](#1-사전-요구사항)
2. [개발 환경 설치](#2-개발-환경-설치)
3. [프로젝트 열기](#3-프로젝트-열기)
4. [Flutter SDK 연동](#4-flutter-sdk-연동)
5. [의존성 설치](#5-의존성-설치)
6. [디버그 APK 빌드](#6-디버그-apk-빌드)
7. [릴리즈 APK 빌드 (서명 포함)](#7-릴리즈-apk-빌드-서명-포함)
8. [App Bundle (AAB) 빌드](#8-app-bundle-aab-빌드)
9. [에뮬레이터 실행](#9-에뮬레이터-실행)
10. [실제 기기에서 실행](#10-실제-기기에서-실행)
11. [자주 발생하는 오류 해결](#11-자주-발생하는-오류-해결)

---

## 1. 사전 요구사항

| 항목 | 버전 | 다운로드 |
|------|------|----------|
| **Android Studio** | Hedgehog (2023.1.1) 이상 | [developer.android.com](https://developer.android.com/studio) |
| **Flutter SDK** | 3.35.4 이상 | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Java (JDK)** | 17 이상 | Android Studio 내장 또는 [adoptium.net](https://adoptium.net) |
| **Android SDK** | API 35 (Android 15) | Android Studio SDK Manager |
| **Git** | 최신 버전 | [git-scm.com](https://git-scm.com) |
| **RAM** | 8GB 이상 권장 | — |
| **저장 공간** | 10GB 이상 여유 공간 | — |

---

## 2. 개발 환경 설치

### 2-1. Flutter SDK 설치

```bash
# macOS (Homebrew)
brew install --cask flutter

# Windows (winget)
winget install Flutter.Flutter

# Linux
sudo snap install flutter --classic
```

또는 공식 사이트에서 직접 다운로드 후 PATH에 추가:

```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
export PATH="$PATH:/path/to/flutter/bin"
```

### 2-2. Flutter 설치 확인

```bash
flutter doctor -v
```

다음과 같이 모두 ✅ 이면 준비 완료:

```
[✓] Flutter (Channel stable, 3.35.4)
[✓] Android toolchain
[✓] Android Studio (version 2023.1)
[✓] Connected device
```

### 2-3. Android Studio Flutter 플러그인 설치

1. Android Studio 실행
2. **File → Settings** (macOS: **Android Studio → Preferences**)
3. **Plugins** 탭 클릭
4. **Marketplace** 검색창에 `Flutter` 입력
5. **Flutter** 플러그인 설치 (Dart 플러그인도 자동 설치됨)
6. Android Studio **재시작**

---

## 3. 프로젝트 열기

### 방법 A: GitHub에서 클론 후 열기 (권장)

```bash
# 1. 저장소 클론
git clone https://github.com/born-sinhae-yk/AHOP.git
cd AHOP
```

Android Studio에서:
1. **File → Open** 클릭
2. 클론한 `AHOP` 폴더 선택
3. **OK** 클릭
4. **"Trust Project"** 팝업에서 **Trust Project** 클릭

### 방법 B: Android Studio에서 직접 클론

1. Android Studio 시작 화면에서 **Get from VCS** 클릭
2. **URL** 입력:
   ```
   https://github.com/born-sinhae-yk/AHOP.git
   ```
3. **Directory**: 원하는 로컬 경로 지정
4. **Clone** 클릭

---

## 4. Flutter SDK 연동

Android Studio가 Flutter SDK를 인식하지 못할 경우:

1. **File → Settings → Languages & Frameworks → Flutter**
2. **Flutter SDK path** 설정:
   - macOS/Linux: `/Users/yourname/flutter` 또는 `/home/yourname/flutter`
   - Windows: `C:\src\flutter`
3. **Apply → OK**

> 💡 Flutter 설치 경로 확인: 터미널에서 `which flutter` 실행

---

## 5. 의존성 설치

Android Studio 하단 터미널 탭 또는 외부 터미널에서:

```bash
# 프로젝트 루트에서 실행
cd AHOP
flutter pub get
```

또는 Android Studio에서:
- 상단 메뉴 **Tools → Flutter → Pub get** 클릭

---

## 6. 디버그 APK 빌드

### 터미널에서 빌드

```bash
# 디버그 APK 빌드
flutter build apk --debug

# 결과물 위치
# build/app/outputs/flutter-apk/app-debug.apk
```

### Android Studio GUI에서 빌드

1. 상단 메뉴 **Build → Flutter → Build APK**
2. 빌드 완료 후 하단 이벤트 로그에서 파일 경로 확인
3. **"locate"** 링크 클릭하면 파인더/탐색기에서 파일 열림

---

## 7. 릴리즈 APK 빌드 (서명 포함)

### 7-1. 키스토어 생성 (최초 1회)

이미 `android/release-key.jks`가 포함되어 있으면 이 단계를 건너뛰세요.

```bash
# 새 키스토어 생성
keytool -genkey -v \
  -keystore android/release-key.jks \
  -alias release \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# 입력 항목:
# - 키스토어 비밀번호 (기억해두세요!)
# - 이름, 조직, 지역 정보
# - 키 비밀번호 (키스토어와 동일하게 설정 권장)
```

### 7-2. key.properties 설정

`android/key.properties` 파일 생성 또는 확인:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=release
storeFile=../release-key.jks
```

> ⚠️ **보안 주의**: `key.properties`와 `.jks` 파일을 절대 Git에 커밋하지 마세요!
> `.gitignore`에 이미 제외 처리되어 있습니다.

### 7-3. 릴리즈 APK 빌드

```bash
# 릴리즈 APK (단일 APK, 범용)
flutter build apk --release

# 아키텍처별 분리 APK (용량 최적화)
flutter build apk --release --split-per-abi

# 결과물 위치
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (64비트)
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (32비트)
# build/app/outputs/flutter-apk/app-x86_64-release.apk     (x86_64)
```

### 7-4. Android Studio GUI로 릴리즈 빌드

1. **Build → Generate Signed Bundle / APK** 클릭
2. **APK** 선택 → **Next**
3. 키스토어 파일 경로 입력 또는 기존 것 선택
4. 비밀번호 및 키 alias 입력
5. **release** 빌드 타입 선택
6. **Finish** 클릭

---

## 8. App Bundle (AAB) 빌드

> Google Play Store 제출 시 APK 대신 AAB 형식이 권장됩니다.

```bash
# App Bundle 빌드
flutter build aab --release

# 결과물 위치
# build/app/outputs/bundle/release/app-release.aab
```

Android Studio GUI:
1. **Build → Generate Signed Bundle / APK**
2. **Android App Bundle** 선택 → **Next**
3. 서명 정보 입력 → **Finish**

---

## 9. 에뮬레이터 실행

### 에뮬레이터 생성

1. Android Studio → **Tools → Device Manager**
2. **Create Device** 클릭
3. Phone → **Pixel 7** (또는 원하는 기기) 선택 → **Next**
4. **API 35** (Android 15) 시스템 이미지 선택 → **Download** → **Next**
5. **Finish**

### 앱 실행

```bash
# 에뮬레이터 시작 후
flutter run
```

또는 Android Studio에서:
- 상단 툴바의 기기 선택 드롭다운에서 에뮬레이터 선택
- **▶ Run** 버튼 클릭

---

## 10. 실제 기기에서 실행

### Android 기기 개발자 옵션 활성화

1. **설정 → 휴대전화 정보 → 소프트웨어 정보**
2. **빌드 번호**를 7번 탭
3. **"개발자가 되었습니다"** 메시지 확인

### USB 디버깅 활성화

1. **설정 → 개발자 옵션**
2. **USB 디버깅** 켜기
3. PC에 USB 연결 후 **"이 컴퓨터를 항상 허용"** 선택

### 앱 실행

```bash
# 연결된 기기 확인
flutter devices

# 특정 기기에 실행
flutter run -d <device_id>
```

### APK 직접 설치

```bash
# USB 연결된 기기에 APK 설치
adb install release/HWP-Suite-v1.0.0-release.apk

# 또는 기기에 APK 파일을 전송 후 직접 설치
# (기기에서 "알 수 없는 출처 앱 설치" 허용 필요)
```

---

## 11. 자주 발생하는 오류 해결

### 오류 1: `Gradle build failed`

```bash
# Android 빌드 캐시 초기화
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### 오류 2: `SDK location not found`

`android/local.properties` 파일이 없거나 경로가 잘못된 경우:

```properties
# android/local.properties 생성
sdk.dir=/Users/yourname/Library/Android/sdk      # macOS
sdk.dir=C:\\Users\\yourname\\AppData\\Local\\Android\\sdk  # Windows
sdk.dir=/home/yourname/Android/Sdk               # Linux
```

### 오류 3: `minSdkVersion` 관련 오류

`android/app/build.gradle.kts`에서 minSdk 버전 확인:

```kotlin
defaultConfig {
    minSdk = 21  // Android 5.0 이상
    targetSdk = 35
}
```

### 오류 4: Flutter SDK를 찾을 수 없음

```bash
# Flutter 경로 재등록
flutter config --android-studio-dir="/path/to/android-studio"
flutter doctor --android-licenses
```

### 오류 5: `Keystore was tampered with, or password was incorrect`

`android/key.properties`의 비밀번호를 확인하고, 키스토어 파일 경로가 올바른지 점검:

```bash
# 키스토어 정보 확인
keytool -list -v -keystore android/release-key.jks
```

### 오류 6: WebView 관련 빌드 오류

```bash
# 의존성 재설치
flutter pub cache clean
flutter pub get
flutter build apk --release
```

---

## 📁 빌드 결과물 위치 요약

| 빌드 유형 | 결과물 경로 |
|-----------|------------|
| 디버그 APK | `build/app/outputs/flutter-apk/app-debug.apk` |
| 릴리즈 APK | `build/app/outputs/flutter-apk/app-release.apk` |
| 릴리즈 AAB | `build/app/outputs/bundle/release/app-release.aab` |
| 분리 APK (arm64) | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` |

---

## 🔗 참고 자료

- [Flutter 공식 문서 — Android 빌드](https://docs.flutter.dev/deployment/android)
- [Flutter 공식 문서 — 서명 설정](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Android Studio 공식 문서](https://developer.android.com/studio)
- [rhwp 프로젝트](https://github.com/edwardkim/rhwp)

---

*문의 사항은 [GitHub Issues](https://github.com/born-sinhae-yk/AHOP/issues)에 남겨주세요.*
