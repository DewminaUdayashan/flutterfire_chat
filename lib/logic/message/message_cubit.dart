// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:chatty_chat/models/message.dart';
import 'package:chatty_chat/services/firestore_services.dart';

import '../../models/chat.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final FirestoreServices _firestoreServices;
  MessageCubit(this._firestoreServices) : super(MessageInitial());
  late StreamSubscription _chatStreamSubscription;

  Future<void> loadMessages(String chatId) async {
    try {
      _chatStreamSubscription =
          _firestoreServices.loadMessages(chatId).listen((event) {
        List<Message> messages = List<Message>.empty(growable: true);

        for (final element in event.docs) {
          messages.add(Message.fromMap(element.data()));
        }
        emit(MessageLoaded(messages));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendOneToOneMessage(
      {required Chat chat, required Message message}) async {
    _firestoreServices
        .sendOneToOneMessage(chat: chat, message: message)
        .then((value) => value.open(print, print));
  }

  @override
  Future<void> close() {
    _chatStreamSubscription.cancel();
    return super.close();
  }
}
