import 'dart:math';

import 'package:chatty_chat/screens/chat/users_sheet.dart';
import 'package:chatty_chat/screens/chat/widgets/chat_item.dart';
import 'package:chatty_chat/services/auth_services.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:chatty_chat/shared/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/chat/chat_cubit.dart';
import '../../logic/users/users_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late String userID;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userID = context.read<AuthServices>().currentUser?.uid ?? '';
    context.read<UsersCubit>().loadUsers(userID);
    context.read<ChatCubit>().getAllChats(userID);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    context.read<AuthBloc>().add(AuthActiveStatusChanged(state.toAppStatus));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return const UsersSheet();
            },
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(builder: (context, chatState) {
        return BlocBuilder<UsersCubit, UsersState>(
          builder: (context, userState) {
            return CustomScrollView(
              slivers: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SliverAppBar.large(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      title: const Text('Chatty'),
                      actions: [
                        if (state is Authenticated)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  Navigator.pushNamed(context, Routes.profile),
                              borderRadius: BorderRadius.circular(100),
                              child: Ink(
                                padding: const EdgeInsets.only(top: 2),
                                height: 100,
                                width: 100,
                                decoration: state.user?.photoUrl == null
                                    ? null
                                    : BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            state.user?.photoUrl ?? '',
                                          ),
                                        ),
                                      ),
                                child: state.user?.photoUrl == null
                                    ? const Icon(Icons.account_circle_rounded)
                                    : null,
                              ),
                            ),
                          ),
                      ],
                      floating: true,
                    );
                  },
                ),
                if (chatState is ChatLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (chatState is ChatLoadingFalied)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text((chatState).exception.toString()),
                    ),
                  ),
                if (chatState is ChatLoaded && userState is UsersLoaded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: (chatState).chats.length,
                      (context, index) {
                        final chat = (chatState).chats[index];
                        final chatCubit = context.read<ChatCubit>();
                        final user =
                            chatCubit.getUserForChat(chat, userState, userID);
                        final lastMessage = chatCubit
                            .getLastMessageIndicatingText(chat.lastMessage);
                        final backUpHeroId = Random.secure();
                        return ChatItem(
                          chatCubit: chatCubit,
                          user: user,
                          userID: userID,
                          mounted: mounted,
                          backUpHeroId: backUpHeroId,
                          lastMessage: lastMessage,
                          chat: chat,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }
}
