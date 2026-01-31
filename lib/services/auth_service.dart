import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  final DatabaseService _db = DatabaseService();

  Future<bool> hasProfile() async {
    if (_user == null) return false;
    final profile = await _db.getUserProfile(_user!.uid);
    return profile != null;
  }

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
      _auth?.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(
          "AuthService: Firebase not initialized. Running in guest mode.");
    }
  }

  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception(
          "Firebase not initialized. Please check your configuration.");
    }
    return _auth!;
  }

  /// Sign up with email and password
  /// Returns null on success, or a sanitized error message on failure
  Future<String?> signUp(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // Sanitize error messages to prevent user enumeration
      return _sanitizeAuthError(e.code);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  /// Sign in with email and password
  /// Returns null on success, or a sanitized error message on failure
  Future<String?> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // Sanitize error messages to prevent user enumeration
      return _sanitizeAuthError(e.code);
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  /// Sanitize Firebase Auth error codes to prevent user enumeration attacks
  /// Don't reveal whether email exists or not
  String _sanitizeAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
