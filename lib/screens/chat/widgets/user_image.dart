import 'package:flutter/material.dart';

import '../../../models/user_model.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
        image: user.photoUrl == null
            ? null
            : DecorationImage(
                image: NetworkImage(user.photoUrl ?? ''),
              ),
      ),
      child: user.photoUrl == null
          ? const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
            )
          : null,
    );
  }
}
