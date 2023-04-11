import 'dart:math';

import 'package:chatty_chat/screens/chat/widgets/user_image.dart';
import 'package:flutter/material.dart';

import '../../../logic/chat/chat_cubit.dart';
import '../../../models/chat.dart';
import '../../../models/user_model.dart';
import '../../../shared/routes.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.chatCubit,
    required this.user,
    required this.userID,
    required this.mounted,
    required this.backUpHeroId,
    required this.lastMessage,
    required this.chat,
  });

  final ChatCubit chatCubit;
  final UserModel user;
  final String userID;
  final bool mounted;
  final Random backUpHeroId;
  final String lastMessage;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final res = await chatCubit.startChat(user, userID);
        if (res != null) {
          if (mounted) {
            Navigator.pushNamed(context, Routes.privateChat);
          }
        }
      },
      leading: Stack(
        children: [
          Hero(
            tag: user.id ?? backUpHeroId,
            child: UserImage(
              user: user,
            ),
          ),
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      title: Text(user.name ?? user.email),
      subtitle: Text(lastMessage),
      trailing: Icon(
        chat.lastMessage.readers.contains(user.id)
            ? Icons.checklist_rtl_sharp
            : Icons.check,
      ),
    );
  }
}
