import 'package:chatty_chat/services/firestore_services.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_result/flutter_result.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirestoreServices _firestoreServices;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthServices(this._firestoreServices);

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
    late final AuthCredential credential;
    try {
      ///sign in using google account
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;

      ///create credential object from google auth
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      ///sign in using created credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      ///new user
      final user = userCredential.user;

      ///if user is new and [user] is not null, we have to create record in
      ///firestore to store user's data
      if ((userCredential.additionalUserInfo?.isNewUser ?? false) &&
          user != null) {
        _firestoreServices.saveUserToFirestore(
            userId: user.uid, user: user.toFirestoreUser(isActive: true));
      }
      return Result.success(user);
    } on Exception catch (e) {
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

      ///new user
      final user = userCredential.user;

      ///if user is new and [user] is not null, we have to create record in
      ///firestore to store user's data
      if ((userCredential.additionalUserInfo?.isNewUser ?? false) &&
          user != null) {
        _firestoreServices.saveUserToFirestore(
            userId: user.uid, user: user.toFirestoreUser(isActive: true));
      }
      return Result.success(userCredential.user);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  Future<Result<bool, Exception>> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
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
    changeActiveStatus(false);
  }

  void changeActiveStatus(bool isActive) {
    if (currentUser != null) {
      _firestoreServices.changeActiveStatus(isActive, currentUser!.uid);
    }
  }
}
