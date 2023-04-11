import 'package:chatty_chat/screens/auth/profile_screen.dart';
import 'package:chatty_chat/screens/chat/chat_screen.dart';
import 'package:chatty_chat/screens/chat/private_chat/private_chat.dart';
import 'package:flutter/material.dart';

import '../screens/splash.dart';

class Routes {
  static const splash = '/splash';
  static const profile = '/profile';
  static const privateChat = '/private_chat';
  static const chat = '/chat';

  static Map<String, Widget Function(BuildContext)> getRoutes = {
    splash: (_) {
      return const Splash();
    },
    profile: (_) {
      return const Profile();
    },
    privateChat: (_) {
      return const PrivateChat();
    },
    chat: (_) {
      return const ChatScreen();
    }
  };
}
