// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:chatty_chat/models/reaction.dart';

class Message {
  final String text;
  final List<String> media;
  final String sender;
  final DateTime sentAt;
  final List<Reaction> reactions;
  final List<String> readers;

  Message({
    required this.text,
    required this.media,
    required this.sender,
    required this.sentAt,
    required this.reactions,
    required this.readers,
  });

  Message copyWith({
    String? text,
    List<String>? media,
    String? sender,
    DateTime? sentAt,
    List<Reaction>? reactions,
    List<String>? readers,
  }) {
    return Message(
      text: text ?? this.text,
      media: media ?? this.media,
      sender: sender ?? this.sender,
      sentAt: sentAt ?? this.sentAt,
      reactions: reactions ?? this.reactions,
      readers: readers ?? this.readers,
    );
  }

  Map<String, dynamic> toMap(String id) {
    return <String, dynamic>{
      'chatId': id,
      'text': text,
      'media': media,
      'sender': sender,
      'sentAt': Timestamp.fromDate(sentAt),
      'reactions': reactions.map((x) => x.toMap()).toList(),
      'readers': readers,
    };
  }

  factory Message.sentForm({required String text, required String sender}) {
    return Message(
      text: text,
      media: [],
      sender: sender,
      sentAt: DateTime.now(),
      reactions: [],
      readers: [],
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'] as String,
      media: List<String>.from((map['media'] as List)),
      sender: map['sender'] as String,
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      reactions: List<Reaction>.from(
        (map['reactions'] as List).map<Reaction>(
          (x) => Reaction.fromMap(x),
        ),
      ),
      readers: List<String>.from(
        (map['readers'] as List),
      ),
    );
  }

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(text: $text, media: $media, sender: $sender, sentAt: $sentAt, reactions: $reactions, readers: $readers)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.text == text &&
        listEquals(other.media, media) &&
        other.sender == sender &&
        other.sentAt == sentAt &&
        listEquals(other.reactions, reactions) &&
        listEquals(other.readers, readers);
  }

  @override
  int get hashCode {
    return text.hashCode ^
        media.hashCode ^
        sender.hashCode ^
        sentAt.hashCode ^
        reactions.hashCode ^
        readers.hashCode;
  }
}
