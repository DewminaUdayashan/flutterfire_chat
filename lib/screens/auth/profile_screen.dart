import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          context.read<AuthBloc>().add(SignOut());
        },
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated && state.user != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Material(
                      child: InkWell(
                        onTap: () async {
                          // final pFile = await ImageUtil.pickImage();
                          // file = pFile;
                          // setState(() {});
                          context
                              .read<AuthBloc>()
                              .add(AuthChangeProfileImage());
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Ink(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            border: Border.all(
                              color: Colors.blue,
                              width: 5,
                            ),
                            image: state.user?.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      state.user!.photoUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: state.user?.photoUrl == null
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EditableText(
                    controller: nameController..text = state.user?.name ?? '',
                    focusNode: nameFocusNode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                    ),
                    cursorColor: Colors.blue,
                    backgroundCursorColor: Colors.transparent,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (file != null)
                    Image.file(
                      file!,
                      height: 200,
                    ),
                ],
              );
            }
            return const Center(
              child: Text('Not authenticated!'),
            );
          },
        ),
      ),
    );
  }
}
