import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatty_chat/models/chat.dart';
import 'package:chatty_chat/models/unreader.dart';
import 'package:chatty_chat/models/user_model.dart';
import 'package:chatty_chat/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../models/message.dart';
import '../users/users_cubit.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirestoreServices _firestoreServices;
  ChatCubit(this._firestoreServices) : super(ChatInitial());

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _chatsStream;

  Future<Chat?> startChat(UserModel user, String sender) async {
    final result =
        await _firestoreServices.startOneToOneChat(sender, user.id ?? '');
    return result.open(
      (onSuccess) {
        emit((state as ChatLoaded).copyWith(
          currentChat: onSuccess,
          currentChatUser: user,
        ));
        return onSuccess;
      },
      (err) {
        print(err);
        return null;
      },
    );
  }

  Future<void> getAllChats(String userId) async {
    // emit(ChatLoading());
    try {
      _firestoreServices.getAllChats(userId).then(
            (stream) => _chatsStream = stream.listen(
              (snaps) {
                final List<Chat> chats = List<Chat>.empty(growable: true);
                for (final doc in snaps.docs) {
                  chats.add(
                    Chat.fromMap(doc.data(), doc.id),
                  );
                }
                if (state is ChatLoaded) {
                  emit((state as ChatLoaded).copyWith(chats: chats));
                } else {
                  emit(ChatLoaded(chats));
                }
              },
            ),
          );
    } on Exception catch (e) {
      emit(ChatLoadingFalied(e));
    }
  }

  UserModel getUserForChat(Chat chat, UsersLoaded userState, String myId) {
    final receiverId = chat.participants.where((id) => id != myId).first;
    final filtered =
        userState.users.where((user) => user.id == receiverId).toList();
    if (filtered.isNotEmpty) {
      return filtered.first;
    } else {
      return UserModel(email: '', isActive: false);
    }
  }

  String getLastMessageIndicatingText(Message message) {
    if (message.media.isNotEmpty) {
      return '${message.media.length} media(s)';
    }
    return message.text;
  }

  @override
  Future<void> close() {
    _chatsStream.cancel();
    return super.close();
  }

  List<Unreader> formUnreadMessageCount({
    required String receiverId,
    required List<Unreader> prevUnreaders,
    required int newMessages,
  }) {
    final existingReceiver =
        prevUnreaders.where((element) => element.id == receiverId).toList();
    if (existingReceiver.isEmpty) {
      return [
        ...prevUnreaders,
        Unreader(id: receiverId, messageCount: newMessages),
      ];
    } else {
      final existingReceiverIndex =
          prevUnreaders.indexWhere((element) => element.id == receiverId);
      prevUnreaders.removeAt(existingReceiverIndex);
      return [
        ...prevUnreaders,
        Unreader(
            id: receiverId,
            messageCount: existingReceiver.first.messageCount + newMessages),
      ];
    }
  }
}
