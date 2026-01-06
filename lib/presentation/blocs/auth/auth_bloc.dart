import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthGuestModeRequested>(_onAuthGuestModeRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateUserRequested>(_onAuthUpdateUserRequested);
    on<AuthIncrementGuestSession>(_onAuthIncrementGuestSession);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // TODO: Implement actual auth check with repository
    // For now, simulate guest mode
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const AuthGuestMode(sessionCount: 1));
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: Implement actual login logic with repository
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: 'user_123',
        email: event.email,
        phone: event.phone,
        isGuest: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: Implement Google Sign-In
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: 'user_google_123',
        name: 'Google User',
        email: 'user@gmail.com',
        isGuest: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthGuestModeRequested(
    AuthGuestModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuestMode(sessionCount: 1));
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // TODO: Clear user data
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthUpdateUserRequested(
    AuthUpdateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      
      // TODO: Update user in repository
      final updatedUser = currentUser.copyWith(
        name: event.userData['name'],
        age: event.userData['age'],
        gender: event.userData['gender'],
        height: event.userData['height'],
        weight: event.userData['weight'],
        goal: event.userData['goal'],
      );

      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  Future<void> _onAuthIncrementGuestSession(
    AuthIncrementGuestSession event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthGuestMode) {
      final currentState = state as AuthGuestMode;
      final newCount = currentState.sessionCount + 1;
      
      // Trigger login prompt after threshold
      if (newCount >= AppConstants.guestModeSessionTrigger) {
        // You can emit a different state or show dialog here
      }
      
      emit(AuthGuestMode(sessionCount: newCount));
    }
  }
}
