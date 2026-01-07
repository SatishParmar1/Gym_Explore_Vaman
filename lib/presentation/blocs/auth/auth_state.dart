import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthGuestMode extends AuthState {
  final int sessionCount;

  const AuthGuestMode({required this.sessionCount});

  @override
  List<Object?> get props => [sessionCount];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool isUpdating;

  const AuthAuthenticated({
    required this.user,
    this.isUpdating = false,
  });

  @override
  List<Object?> get props => [user, isUpdating];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}