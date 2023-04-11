// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class StartChat extends ChatState {
  final UserModel receiver;
  final DateTime startingTime;

  const StartChat({required this.receiver, required this.startingTime});

  @override
  List<Object> get props => [receiver, startingTime];
}

class ChatLoaded extends ChatState {
  final List<Chat> chats;
  final Chat? currentChat;
  final UserModel? currentChatUser;

  const ChatLoaded(this.chats, {this.currentChat, this.currentChatUser});

  @override
  List<Object?> get props => [chats, currentChat, currentChatUser];

  ChatLoaded copyWith({
    List<Chat>? chats,
    Chat? currentChat,
    UserModel? currentChatUser,
  }) {
    return ChatLoaded(
      chats ?? this.chats,
      currentChat: currentChat ?? this.currentChat,
      currentChatUser: currentChatUser ?? this.currentChatUser,
    );
  }
}

class ChatLoading extends ChatState {}

class ChatLoadingFalied extends ChatState {
  final Exception exception;

  const ChatLoadingFalied(this.exception);

  @override
  List<Object> get props => [exception];
}
