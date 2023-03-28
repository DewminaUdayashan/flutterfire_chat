part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class NotAuthenticated extends AuthState {}

class Authenticating extends AuthState {}

class Authenticated extends AuthState {
  final bool verifiedUser;
  final Exception? verificationException;
  final UserModel? user;

  const Authenticated({
    this.user,
    required this.verifiedUser,
    this.verificationException,
  });

  @override
  List<Object?> get props => [
        user,
        verifiedUser,
        verificationException,
      ];

  Authenticated copyWith({
    bool? verifiedUser,
    Exception? verificationException,
    UserModel? user,
  }) {
    return Authenticated(
      user: user ?? this.user,
      verifiedUser: verifiedUser ?? false,
      verificationException: this.verificationException,
    );
  }
}

class AuthenticationFailed extends AuthState {
  final Exception exception;

  const AuthenticationFailed(this.exception);

  @override
  List<Object> get props => [exception];
}
