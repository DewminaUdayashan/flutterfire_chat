part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignIn extends AuthEvent {
  final String email;
  final String password;
  final AuthType authType;

  const SignIn({
    required this.email,
    required this.password,
    required this.authType,
  });

  @override
  List<Object> get props => [
        email,
        password,
        authType,
      ];
}

class VerifyEmail extends AuthEvent {}

class UserAuthenticated extends AuthEvent {}

class GoogleSignIn extends AuthEvent {}

class SignOut extends AuthEvent {}

class ReloadAuth extends AuthEvent {}

class ResetAuth extends AuthEvent {
  final String email;

  const ResetAuth(this.email);

  @override
  List<Object> get props => [email];
}

class AuthActiveStatusChanged extends AuthEvent {
  final AppStatus appStatus;

  const AuthActiveStatusChanged(this.appStatus);

  @override
  List<Object> get props => [appStatus];
}

class AuthChangeProfileImage extends AuthEvent {}
