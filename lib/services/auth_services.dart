import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_result/flutter_result.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result<User, Exception>> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(userCredential.user);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  Future<Result<User, Exception>> googleSignIn() async {
    final googleSignIn = GoogleSignIn.standard();
    try {
      late final AuthCredential credential;

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return Result.success(userCredential.user);
    } on Exception catch (e) {
      print(e);
      return Result.error(e);
    }
  }

  Future<Result<User, Exception>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(userCredential.user);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  Future<Result<bool, Exception>> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
    final linkData = await FirebaseDynamicLinks.instance.onLink.first;

    try {
      final code = linkData.link.queryParameters['oobCode']!;
      await _auth.checkActionCode(code);
      await _auth.applyActionCode(code);
      await _auth.currentUser?.reload();
      return Result.success(true);
    } on Exception catch (err) {
      return Result.error(err);
    }
  }

  Future<Result<User?, Exception>> reloadAuth() async {
    try {
      await currentUser?.reload();
      return Result.success(currentUser);
    } on Exception catch (e) {
      print(e);
      return Result.error(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Stream<User?> authStateStream() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  void signOut() {
    _auth.signOut();
  }
}
