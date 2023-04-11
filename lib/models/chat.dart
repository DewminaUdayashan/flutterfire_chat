// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:chatty_chat/models/message.dart';
import 'package:chatty_chat/models/unreader.dart';
import 'package:chatty_chat/shared/enums.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';

class Chat {
  String? id;
  final ChatType chatType;
  final List<String> participants;
  final DateTime createdAt;
  final String createdBy;
  final Message lastMessage;
  final List<Unreader> unreaders;

  Chat({
    this.id,
    required this.chatType,
    required this.participants,
    required this.createdAt,
    required this.createdBy,
    required this.lastMessage,
    required this.unreaders,
  });

  Chat copyWith({
    String? id,
    ChatType? chatType,
    List<String>? participants,
    DateTime? createdAt,
    String? createdBy,
    Message? lastMessage,
    List<Unreader>? unreaders,
  }) {
    return Chat(
      id: id ?? this.id,
      chatType: chatType ?? this.chatType,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      lastMessage: lastMessage ?? this.lastMessage,
      unreaders: unreaders ?? this.unreaders,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatType': chatType.type,
      'participants': participants,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'lastMessage': lastMessage.toMap(''),
      'unreaders': unreaders.map((x) => x.toMap()).toList(),
    };
  }

  List<Map<String, dynamic>> unreadersToMap() =>
      unreaders.map((x) => x.toMap()).toList();

  factory Chat.fromMap(Map<String, dynamic> map, [String? id]) {
    return Chat(
      id: id,
      chatType: (map['chatType'] as int).fromMap,
      participants: List<String>.from((map['participants'] as List)),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int)),
      createdBy: map['createdBy'] as String,
      lastMessage: Message.fromMap(map['lastMessage'] as Map<String, dynamic>),
      unreaders: List<Unreader>.from(
        (map['unreaders'] as List).map<Unreader>(
          (x) => Unreader.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id:$id, chatType: $chatType, participants: $participants, createdAt: $createdAt, createdBy: $createdBy, lastMessage: $lastMessage, unreaders: $unreaders)';
  }

  @override
  bool operator ==(covariant Chat other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.chatType == chatType &&
        listEquals(other.participants, participants) &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.lastMessage == lastMessage &&
        listEquals(other.unreaders, unreaders);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chatType.hashCode ^
        participants.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        lastMessage.hashCode ^
        unreaders.hashCode;
  }
}
