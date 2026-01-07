import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../backend/backend.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc with Supabase integration.
/// 
/// This is an alternative implementation that uses Supabase for authentication.
/// Replace the existing AuthBloc with this one to use Supabase.
class SupabaseAuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseAuthService _authService;
  final UserRepository _userRepository;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  SupabaseAuthBloc({
    SupabaseAuthService? authService,
    UserRepository? userRepository,
  })  : _authService = authService ?? getIt<SupabaseAuthService>(),
        _userRepository = userRepository ?? getIt<UserRepository>(),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthAppleLoginRequested>(_onAuthAppleLoginRequested);
    on<AuthGuestModeRequested>(_onAuthGuestModeRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateUserRequested>(_onAuthUpdateUserRequested);
    on<AuthIncrementGuestSession>(_onAuthIncrementGuestSession);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((authState) {
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        add(AuthCheckRequested());
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        add(AuthLogoutRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      if (!_authService.isAuthenticated) {
        emit(const AuthGuestMode(sessionCount: 1));
        return;
      }

      // Get or create user profile
      var user = await _userRepository.getCurrentUser();
      
      if (user == null) {
        // Create user profile if it doesn't exist
        final authUser = _authService.currentUser!;
        user = await _userRepository.createUser(
          id: authUser.id,
          name: authUser.userMetadata?['name'] as String? ??
              authUser.userMetadata?['full_name'] as String?,
          email: authUser.email,
          isGuest: authUser.isAnonymous,
        );
      } else {
        // Update last login
        await _userRepository.updateLastLogin();
      }

      if (user.isGuest) {
        emit(AuthGuestMode(sessionCount: user.currentStreak + 1));
      } else {
        emit(AuthAuthenticated(user: user));
      }
    } on BackendException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Failed to check authentication: ${e.toString()}'));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Sign in with email
      final email = event.email ?? '${event.phone}@gymexplore.app';
      await _authService.signInWithEmail(
        email: email,
        password: event.password ?? '',
      );

      // Get user profile
      final user = await _userRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'User profile not found'));
      }
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Sign up with email
      final authUser = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        metadata: {
          'name': event.name,
        },
      );

      // Create user profile
      final user = await _userRepository.createUser(
        id: authUser.id,
        name: event.name,
        email: event.email,
        isGuest: false,
      );

      emit(AuthAuthenticated(user: user));
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Sign up failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.signInWithGoogle();
      // Auth state change listener will handle the rest
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Google sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthAppleLoginRequested(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.signInWithApple();
      // Auth state change listener will handle the rest
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Apple sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthGuestModeRequested(
    AuthGuestModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Sign in anonymously
      final authUser = await _authService.signInAnonymously();

      // Create guest user profile
      await _userRepository.createUser(
        id: authUser.id,
        isGuest: true,
      );

      emit(const AuthGuestMode(sessionCount: 1));
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      // Fallback to local guest mode if anonymous auth fails
      emit(const AuthGuestMode(sessionCount: 1));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onAuthUpdateUserRequested(
    AuthUpdateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      try {
        emit(AuthAuthenticated(user: event.user, isUpdating: true));
        
        final updatedUser = await _userRepository.upsertUser(event.user);
        
        emit(AuthAuthenticated(user: updatedUser));
      } on BackendException catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: 'Failed to update user: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAuthIncrementGuestSession(
    AuthIncrementGuestSession event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthGuestMode) {
      final currentState = state as AuthGuestMode;
      emit(AuthGuestMode(sessionCount: currentState.sessionCount + 1));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } on AppAuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Failed to send reset email: ${e.toString()}'));
    }
  }
}
