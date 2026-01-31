# 🔒 Security Configuration Guide

This document outlines the security measures implemented in the Titan Fitness app and provides guidance for maintaining security best practices.

## 🚨 IMPORTANT: API Keys

### Gemini API Key
**NEVER commit API keys to version control!**

The Gemini API key is configured via build-time environment variables:

```bash
# Development
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here

# Release Build
flutter build apk --dart-define=GEMINI_API_KEY=your_api_key_here
flutter build appbundle --dart-define=GEMINI_API_KEY=your_api_key_here
```

### Firebase Configuration
The `firebase_options.dart` file contains client-side Firebase configuration. These keys are protected by:
- Firebase Security Rules (server-side)
- App Check (recommended for production)

**Recommended for Production:**
1. Enable Firebase App Check
2. Restrict API keys in Google Cloud Console
3. Set up domain restrictions

## 📱 Android Security

### Implemented Protections:
- ✅ `android:allowBackup="false"` - Prevents data extraction via ADB backup
- ✅ `android:usesCleartextTraffic="false"` - Enforces HTTPS only
- ✅ Network Security Config - Custom certificate pinning
- ✅ ProGuard/R8 obfuscation - Protects against reverse engineering
- ✅ Debug logging removed in release builds

### Before Publishing:
1. Create a production keystore
2. Update `signingConfig` in `build.gradle.kts`
3. Never share or commit your keystore file

## 🌐 Web Security

### Implemented Headers:
- ✅ Content-Security-Policy (CSP)
- ✅ X-Frame-Options: DENY
- ✅ X-Content-Type-Options: nosniff
- ✅ Referrer-Policy: strict-origin-when-cross-origin
- ✅ Permissions-Policy (camera, microphone, geolocation disabled)

## 🔐 Authentication Security

### Password Requirements:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

### Email Validation:
- Format validation before submission
- Trimmed to prevent whitespace attacks

## 📁 Files to NEVER Commit

The following are in `.gitignore`:
- `.env` and `*.env` files
- `local.properties`
- `google-services.json`
- `GoogleService-Info.plist`
- `*.keystore` and `*.jks`
- `key.properties`
- Service account JSON files

## 🛡️ Firebase Security Rules

Ensure your Firestore rules are properly configured:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Nested workouts collection
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 🔄 Regular Security Maintenance

1. **Monthly**: Update Flutter and all dependencies
2. **Quarterly**: Review Firebase Security Rules
3. **Before Release**: Run `flutter pub outdated` for security patches
4. **Annually**: Rotate API keys and review access permissions

## 🐛 Reporting Security Issues

If you discover a security vulnerability, please:
1. Do NOT create a public issue
2. Contact the security team directly
3. Provide detailed reproduction steps

---

*Last Updated: January 2026*
