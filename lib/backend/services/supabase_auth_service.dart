import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';
import '../exceptions/backend_exception.dart';

/// Supabase Authentication Service
/// 
/// Provides authentication functionality including:
/// - Email/password sign in and sign up
/// - OAuth providers (Google, Apple, etc.)
/// - Password reset
/// - Session management
/// 
/// Example:
/// ```dart
/// final authService = SupabaseAuthService();
/// 
/// // Sign in
/// final user = await authService.signInWithEmail(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// 
/// // Listen to auth changes
/// authService.authStateChanges.listen((state) {
///   print('Auth state changed: $state');
/// });
/// ```
class SupabaseAuthService {
  SupabaseAuthService({SupabaseClient? client})
      : _client = client ?? BackendConfig.client;

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Current session
  Session? get currentSession => _auth.currentSession;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppAuthException.invalidCredentials();
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(
        message: 'Sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Sign up failed. Please try again.',
        );
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(
        message: 'Sign up failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.gymexplore://login-callback/',
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Google sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign in with Apple OAuth
  Future<void> signInWithApple() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.gymexplore://login-callback/',
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Apple sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign in anonymously (guest mode)
  Future<User> signInAnonymously() async {
    try {
      final response = await _auth.signInAnonymously();

      if (response.user == null) {
        throw const AppAuthException(
          message: 'Anonymous sign in failed',
        );
      }

      return response.user!;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(
        message: 'Anonymous sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.gymexplore://reset-password/',
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to send reset email: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to update password: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to update email: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update user metadata
  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await _auth.updateUser(UserAttributes(data: metadata));
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to update user data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Refresh current session
  Future<Session?> refreshSession() async {
    try {
      final response = await _auth.refreshSession();
      return response.session;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Failed to refresh session: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppAuthException(
        message: 'Sign out failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete current user account
  /// Note: This requires the user to be recently authenticated
  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw AppAuthException.notAuthenticated();
    }
    
    // Account deletion typically requires a server-side function
    // This is a placeholder - implement via Edge Functions
    throw const AppAuthException(
      message: 'Account deletion requires server-side implementation',
      code: 'not_implemented',
    );
  }

  /// Map Supabase auth exceptions to our custom exceptions
  AppAuthException _mapAuthException(AuthException e) {
    final message = e.message;
    if (message.contains('Invalid login credentials')) {
      return AppAuthException.invalidCredentials();
    }
    if (message.contains('already registered')) {
      return AppAuthException.emailAlreadyInUse();
    }
    if (message.contains('expired')) {
      return AppAuthException.sessionExpired();
    }
    if (message.contains('not found')) {
      return AppAuthException.userNotFound();
    }
    if (message.contains('password')) {
      return AppAuthException.weakPassword();
    }
    return AppAuthException(
      message: message,
      originalError: e,
    );
  }
}
