/// Environment configuration for secure API key management
///
/// Use --dart-define to pass API keys at build time:
/// flutter run --dart-define=GEMINI_API_KEY=your_actual_key
///
/// For production builds:
/// flutter build apk --dart-define=GEMINI_API_KEY=your_actual_key

class EnvConfig {
  /// Gemini API Key - passed via --dart-define at build time
  /// Never hardcode real API keys!
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Firebase Web API Key
  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  );

  /// Firebase Android API Key
  static const String firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: '',
  );

  /// Firebase iOS API Key
  static const String firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: '',
  );

  /// Check if Gemini API is configured
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;

  /// Check if Firebase is configured
  static bool get isFirebaseConfigured =>
      firebaseWebApiKey.isNotEmpty ||
      firebaseAndroidApiKey.isNotEmpty ||
      firebaseIosApiKey.isNotEmpty;
}
