import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String? email;
  final String? phone;

  const AuthLoginRequested({this.email, this.phone});

  @override
  List<Object?> get props => [email, phone];
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthGuestModeRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateUserRequested extends AuthEvent {
  final Map<String, dynamic> userData;

  const AuthUpdateUserRequested({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class AuthIncrementGuestSession extends AuthEvent {}
