import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String? email;
  final String? phone;
  final String? password;

  const AuthLoginRequested({this.email, this.phone, this.password});

  @override
  List<Object?> get props => [email, phone, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthAppleLoginRequested extends AuthEvent {}

class AuthGuestModeRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateUserRequested extends AuthEvent {
  final UserModel user;

  const AuthUpdateUserRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthIncrementGuestSession extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
