part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

/// Event untuk memeriksa status login
class CheckLoginStatusEvent extends AuthEvent {}

/// Event untuk proses login dengan email dan password
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

/// Event untuk proses registrasi dengan model user
class SignupEvent extends AuthEvent {
  final UserModel user;

  SignupEvent({required this.user});
}

/// Event untuk proses logout
class LogoutEvent extends AuthEvent {}
