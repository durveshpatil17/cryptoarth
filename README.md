# CryptoArth Mobile App

AI-Powered Crypto Trading Platform built with Flutter.

---

## Features

• JWT Authentication
• Trading Dashboard
• Portfolio Tracking
• Marketplace
• Strategy Backtesting
• Orders Management
• Calculator Tools
• Broker Integration
• Modern Glassmorphism UI

---

## Tech Stack

Frontend:
Flutter
Dart

State Management:
Riverpod

Backend:
Node.js / FastAPI (JWT Authentication)

---

## Project Structure

```
lib/
│
├── core/
│   ├── network/
│   └── storage/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── portfolio/
│   ├── marketplace/
│   ├── orders/
│   ├── strategies/
│   ├── tools/
│   └── settings/
│
├── shared/
│   ├── widgets/
│   ├── theme/
│   ├── models/
│   └── utils/
│
├── app.dart
└── main.dart
```

---

## Setup Instructions

### 1. Install Flutter

[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

Verify:

```
flutter doctor
```

---

### 2. Clone Project

```
git clone https://github.com/durveshpatil17/cryptoarth.git
cd cryptoarth
```

---

### 3. Install dependencies

```
flutter pub get
```

---

### 4. Run App

Start Emulator then run:

```
flutter run
```

---

## Git Workflow

Pull latest changes:

```
git pull origin main
```

Commit changes:

```
git add .
git commit -m "your message"
git push origin main
```

---

## Branch Workflow

main → stable production code
dev → development integration
feature/* → individual features

Example:

```
git checkout -b feature/login
```

---

## Build APK

```
flutter build apk
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Team Rules

• Always pull before work
• Always push after work
• Do not commit build folder
• Do not change core structure

---

## Maintained by

CryptoArth Team
