import 'dart:math';

import 'package:chatty_chat/models/message.dart';
import 'package:chatty_chat/models/user_model.dart';
import 'package:chatty_chat/screens/chat/private_chat/widgets/message_item.dart';
import 'package:chatty_chat/screens/chat/widgets/user_image.dart';
import 'package:chatty_chat/services/auth_services.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/chat/chat_cubit.dart';
import '../../../logic/message/message_cubit.dart';
import '../../../logic/users/users_cubit.dart';

class PrivateChat extends StatefulWidget {
  const PrivateChat({super.key});

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  final controller = TextEditingController();
  final listViewController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, userState) {
        if (userState is UsersLoaded) {
          return BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                final tmp1 = (state.currentChatUser);
                final tmp =
                    userState.users.where((element) => element.id == tmp1!.id);
                late UserModel receiver;
                if (tmp.isNotEmpty) {
                  receiver = tmp.first;
                } else {
                  receiver = tmp1!;
                }
                final currentChat = state.chats
                    .where((element) => element.id == state.currentChat?.id)
                    .first;
                context.read<MessageCubit>().loadMessages(currentChat.id ?? '');

                return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        Hero(
                          tag: receiver.id ?? Random.secure(),
                          child: UserImage(user: receiver),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(receiver.name ?? receiver.email),
                              Text(
                                receiver.isActive
                                    ? 'Online'
                                    : receiver.lastSeen?.lastSeen ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: BlocBuilder<MessageCubit, MessageState>(
                          builder: (context, messageState) {
                            if (messageState is MessageLoadingFailed) {
                              return const Center(
                                child: Text('Error'),
                              );
                            }
                            if (messageState is MessageLoaded) {
                              return ListView.builder(
                                controller: listViewController,
                                itemCount: messageState.messages.length,
                                padding: const EdgeInsets.only(bottom: 30),
                                itemBuilder: (context, index) {
                                  final sender =
                                      context.read<AuthServices>().currentUser;
                                  final msg = messageState.messages[index];
                                  final outgoingMessage =
                                      msg.sender == sender?.uid;
                                  return MessageItem(
                                      outgoingMessage: outgoingMessage,
                                      msg: msg);
                                },
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Type...',
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 10,
                                minLines: 1,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  //  currentChat.unreaders.where((element) => element.id==receiver.id).first.messageCount++
                                  context
                                      .read<MessageCubit>()
                                      .sendOneToOneMessage(
                                        chat: currentChat.copyWith(
                                          unreaders: context
                                              .read<ChatCubit>()
                                              .formUnreadMessageCount(
                                                receiverId: receiver.id ?? '',
                                                prevUnreaders:
                                                    currentChat.unreaders,
                                                newMessages: 1,
                                              ),
                                        ),
                                        message: Message.sentForm(
                                            text: controller.text,
                                            sender: context
                                                    .read<AuthServices>()
                                                    .currentUser
                                                    ?.uid ??
                                                ''),
                                      );
                                  controller.clear();
                                  _scrollToBottom();
                                }
                              },
                              icon: const Icon(Icons.send_rounded),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('error'),
                );
              }
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _scrollToBottom() {
    try {
      listViewController.animateTo(
        listViewController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print(e);
    }
  }
}
