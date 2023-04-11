import 'package:chatty_chat/models/chat.dart';
import 'package:chatty_chat/models/message.dart';
import 'package:chatty_chat/models/unreader.dart';
import 'package:chatty_chat/models/user_model.dart';
import 'package:chatty_chat/shared/enums.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_result/flutter_result.dart';

const _usersCollectionName = 'USERS';
const _chatsCollectionName = 'CHATS';
const _messagesCollectionName = 'MESSAGES';

class FirestoreServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userCollection = _firestore.collection(_usersCollectionName);
  final _chatCollection = _firestore.collection(_chatsCollectionName);
  final _messageCollection = _firestore.collection(_messagesCollectionName);

  Future<void> saveUserToFirestore(
      {required String userId, required UserModel user}) async {
    await _userCollection.doc(userId).set(user.toMap());
  }

  Future<void> changeActiveStatus(bool isActive, String userId) async {
    await _userCollection.doc(userId).update(
      {
        'isActive': isActive,
        'lastSeen': FieldValue.serverTimestamp(),
      },
    );
  }

  void updateUserProfileImageUrl(String userId, String url) {
    _userCollection.doc(userId).update({
      'photoUrl': url,
    });
  }

  Future<Result<UserModel, Exception>> getFirestoreUser(String userId) async {
    try {
      final userRef = await _userCollection.doc(userId).get();
      if (userRef.exists) {
        final map = userRef.data();
        if (map != null) {
          return Result.success(UserModel.fromMap(map));
        }
        return Result.error(Exception('404!'));
      }
      return Result.error(Exception('404!'));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Stream<QuerySnapshot<Map<String, dynamic>>>, Exception>>
      getAllUsers(String myId) async {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshot =
          _userCollection
              .where(FieldPath.documentId, isNotEqualTo: myId)
              .snapshots();

      return Result.success(snapshot);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Chat, Exception>> startOneToOneChat(
      String sender, String receiver) async {
    /// default data for the specific chat
    final welcomeMessage = Message(
      text: 'Welcome to the chat!',
      media: [],
      sender: sender,
      sentAt: DateTime.now(),
      reactions: [],
      readers: [],
    );

    final chatData = Chat(
      chatType: ChatType.private,
      participants: [sender, receiver],
      createdAt: DateTime.now(),
      createdBy: sender,
      lastMessage: welcomeMessage,
      unreaders: [
        Unreader(id: receiver, messageCount: 1),
      ],
    );

    try {
      // First, check if the chat already exists between the two users
      final existingChatQuery = await _chatCollection
          .where('chatType', isEqualTo: ChatType.private.type)
          .where('participants', isEqualTo: [sender, receiver]).get();
      final existingChatQuery2 = await _chatCollection
          .where('chatType', isEqualTo: ChatType.private.type)
          .where('participants', isEqualTo: [receiver, sender]).get();
      if (existingChatQuery.docs.isNotEmpty) {
        return Result.success(chatData..id = existingChatQuery.docs.first.id);
      } else if (existingChatQuery2.docs.isNotEmpty) {
        return Result.success(chatData..id = existingChatQuery2.docs.first.id);
      } else {
        final chatRef = _chatCollection.doc();

        // Create the chat document
        await chatRef.set(chatData.toMap());
        chatData.id = chatRef.id;
        sendOneToOneMessage(chat: chatData, message: welcomeMessage);
        return Result.success(chatData);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<bool, Exception>> sendOneToOneMessage({
    required Chat chat,
    required Message message,
  }) async {
    try {
      await _messageCollection.doc().set(message.toMap(chat.id!));
      await _chatCollection.doc(chat.id).update({
        'unreaders': chat.unreadersToMap(),
        'lastMessage':
            chat.copyWith(lastMessage: message).lastMessage.toMap(''),
      }).then((value) => null, onError: print);
      return Result.success(true);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getAllChats(
      String userId) async {
    return _chatCollection
        .where('participants', arrayContainsAny: [userId]).snapshots();
  }

  // Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getMessages(String chatId)async{
  //   return _messageCollection.
  // }

  Stream<QuerySnapshot<Map<String, dynamic>>> loadMessages(String chatId) {
    return _messageCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('sentAt')
        .snapshots();
  }
}
