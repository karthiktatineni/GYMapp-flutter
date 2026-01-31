# 🏋️ GYMapp-flutter

A premium AI-powered workout planner and fitness tracker built with Flutter.

## ✨ Features

- 🤖 **AI Workout Generation** - Powered by Google Gemini AI
- 🔐 **Secure Authentication** - Firebase Auth integration
- 📊 **Progress Tracking** - Track your fitness journey
- 🎯 **Personalized Plans** - Workouts tailored to your goals
- 📱 **Cross-platform** - Android, iOS, Web, and Desktop

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project (for authentication)
- Gemini API key (for AI features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/karthiktatineni/GYMapp-flutter.git
cd GYMapp-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Create a Firebase project
   - Run `flutterfire configure`
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. Run the app with your Gemini API key:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

## 🔒 Security

This app follows security best practices:
- API keys are passed at build time (not hardcoded)
- ProGuard obfuscation for release builds
- Network security configuration
- Input validation and sanitized error messages

See [SECURITY.md](SECURITY.md) for detailed security documentation.

## 📁 Project Structure

```
lib/
├── config/          # Configuration files
├── core/            # Core utilities and themes
├── features/        # Feature modules
│   ├── auth/        # Authentication
│   ├── dashboard/   # Main dashboard
│   ├── onboarding/  # User onboarding
│   ├── progress/    # Progress tracking
│   └── workout/     # Workout features
├── models/          # Data models
└── services/        # Business logic services
```

## 🏗️ Building for Production

### Android APK
```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_key
```

### Android App Bundle
```bash
flutter build appbundle --dart-define=GEMINI_API_KEY=your_key
```

### iOS
```bash
flutter build ios --dart-define=GEMINI_API_KEY=your_key
```

## 🛠️ Technologies

- **Flutter** - UI Framework
- **Firebase** - Backend services
- **Google Gemini AI** - AI workout generation
- **Provider** - State management

## 📄 License

This project is private and proprietary.

## 👤 Author

**Karthik Tatineni**

---

*Built with ❤️ using Flutter*
