import 'package:chatty_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../enums.dart';

extension EmailValidationExt on String {
  bool get isValidEmail {
    // Define a regular expression pattern for a valid email address
    // This pattern checks for a string that starts with one or more letters or numbers,
    // followed by an optional period, followed by one or more letters, numbers, hyphens, or underscores,
    // followed by an "@" symbol, followed by one or more letters or numbers,
    // followed by an optional period, followed by two or more letters.
    final emailRegex = RegExp(r'^[\w-\.]+@[a-zA-Z]+\.[a-zA-Z]{2,}$');

    // Use the RegExp's "hasMatch" method to check whether the input string matches the pattern
    return emailRegex.hasMatch(this);
  }
}

extension AuthTypeExt on AuthType {
  String get name {
    switch (this) {
      case AuthType.login:
        return 'Login';
      default:
        return 'Sign In';
    }
  }

  bool get isLogin {
    switch (this) {
      case AuthType.login:
        return true;
      default:
        return false;
    }
  }
}

extension FirebaseUserExtentions on User {
  UserModel toFirestoreUser({required bool isActive}) => UserModel(
        email: email ?? '',
        name: displayName,
        photoUrl: photoURL,
        isActive: isActive,
      );
}

extension AppStatusExt on AppStatus {
  bool get isActive => this == AppStatus.online;
}

extension AppStatusExt2 on AppLifecycleState {
  AppStatus get toAppStatus =>
      this == AppLifecycleState.resumed ? AppStatus.online : AppStatus.offline;
}
