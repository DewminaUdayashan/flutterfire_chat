import 'package:chatty_chat/screens/chat/widgets/user_image.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/chat/chat_cubit.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_services.dart';
import '../../../shared/routes.dart';

class UserItem extends StatefulWidget {
  const UserItem({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: ListTile(
            onTap: () async {
              final res = await context.read<ChatCubit>().startChat(widget.user,
                  context.read<AuthServices>().currentUser?.uid ?? '');
              if (res != null) {
                if (mounted) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.pushNamed(context, Routes.privateChat);
                }
              }
            },
            leading: UserImage(user: widget.user),
            title: Text(widget.user.name ?? widget.user.email),
            subtitle: Text(widget.user.lastSeen?.lastSeen ?? ''),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
