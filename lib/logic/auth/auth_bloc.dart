import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_result/flutter_result.dart';

import '../../services/auth_services.dart';
import '../../shared/enums.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthServices _authServices;
  AuthBloc(this._authServices)
      : super(_authServices.currentUser != null
            ? Authenticated(
                verifiedUser: _authServices.currentUser?.emailVerified ?? false)
            : NotAuthenticated()) {
    on<SignIn>(_onSignIn);
    on<VerifyEmail>(_onVerifyEmail);
    on<UserAuthenticated>(_onUserAuthenticated);
    on<SignOut>(_onSignOut);
    on<ReloadAuth>(_onReloadAuth);
    on<GoogleSignIn>(_googleSignIn);
    on<ResetAuth>(_onResetAuth);
    on<AuthActiveStatusChanged>(_onActiveStatusChanged);

    /// listening for user stream for changes
    _initializeAuthentication();
  }

  late StreamSubscription _userSubscription;

  FutureOr<void> _initializeAuthentication() async {
    _userSubscription = _authServices.authStateStream().listen((user) {
      if (user != null) {
        /// else, it's mean user authenticated
        add(UserAuthenticated());
      }
    });
  }

  /// this method is used to create user account using `email` and `password`
  FutureOr<void> _onSignIn(SignIn event, Emitter<AuthState> emit,
      {bool isGoogleSignIn = false}) async {
    /// emitting lauding state
    emit(Authenticating());

    /// [AuthServices] class handle all authentication tasks and communicate
    /// with `firebase` plugin
    late Result result;
    if (isGoogleSignIn) {
      result = await _authServices.googleSignIn();
    } else if (!event.authType.isLogin) {
      result = await _authServices.signUpWithEmailAndPassword(
          event.email, event.password);
    } else {
      result = await _authServices.loginWithEmailAndPassword(
          event.email, event.password);
    }
    result.open(
      (credential) {
        /// nothing to handle here since the user stream listener handling all
        /// user state changes
      },

      /// exception must be handled here
      (onError) => emit(
        AuthenticationFailed(
          onError ??
              Exception(
                'Something Went Wrong',
              ),
        ),
      ),
    );
  }

  /// used to send email verification when user create the account using [SignIn]
  /// event and [_onSignIn] method
  FutureOr<void> _onVerifyEmail(
      VerifyEmail event, Emitter<AuthState> emit) async {
    final result = await _authServices.sendEmailVerification();
    if (state is Authenticated) {
      result.open(
        (onSuccess) => null,
        (onError) => emit(
          (state as Authenticated).copyWith(
            verificationException: onError,
          ),
        ),
      );
    }
  }

  /// when user signout, trigger `signOut` in
  /// firebase auth plugin and [_initializeAuthentication] will handle the
  /// emitting fo the correct state
  FutureOr<void> _onSignOut(SignOut event, Emitter<AuthState> emit) {
    _authServices.signOut();
    emit(NotAuthenticated());
  }

  /// [UserAuthenticated] event will be passed from [_initializeAuthentication] method
  /// when user stream receives the valid [User] object.
  /// Here, we pass `verifiedUser` flag to check if user email is verified or not.
  /// In UI, this flag will be checked and show [VerifyEmailScreen] if user
  /// not validated the email

  FutureOr<void> _onUserAuthenticated(
      UserAuthenticated event, Emitter<AuthState> emit) {
    emit(
      Authenticated(
        verifiedUser: _authServices.isEmailVerified,
        user: _authServices.currentUser,
      ),
    );
  }

  /// this method will trigger when app state resumed.
  /// used to check if user email is verified
  FutureOr<void> _onReloadAuth(
      ReloadAuth event, Emitter<AuthState> emit) async {
    if (state is Authenticated) {
      final currentState = state as Authenticated;

      /// we are reloading the auth state first. It will get the email
      /// verification details
      final result = await _authServices.reloadAuth();

      ///then, we can emit the state if there is any changes
      result.open(
        (user) => emit(currentState.copyWith(
          user: user,
          verifiedUser: user?.emailVerified,
        )),
        (onError) => emit(
          currentState.copyWith(verificationException: onError),
        ),
      );
    }
  }

  FutureOr<void> _googleSignIn(GoogleSignIn event, Emitter<AuthState> emit) {
    _authServices.googleSignIn();
  }

  FutureOr<void> _onResetAuth(ResetAuth event, Emitter<AuthState> emit) {
    _authServices.sendPasswordResetEmail(event.email);
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _onActiveStatusChanged(
      AuthActiveStatusChanged event, Emitter<AuthState> emit) {
    _authServices.changeActiveStatus(event.appStatus.isActive);
  }
}
