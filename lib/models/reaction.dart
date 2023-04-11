// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Reaction {
  final String userID;
  final String reaction;

  Reaction({
    required this.userID,
    required this.reaction,
  });

  Reaction copyWith({
    String? userID,
    String? reaction,
  }) {
    return Reaction(
      userID: userID ?? this.userID,
      reaction: reaction ?? this.reaction,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'reaction': reaction,
    };
  }

  factory Reaction.fromMap(Map<String, dynamic> map) {
    return Reaction(
      userID: map['userID'] as String,
      reaction: map['reaction'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reaction.fromJson(String source) =>
      Reaction.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Reaction(userID: $userID, reaction: $reaction)';

  @override
  bool operator ==(covariant Reaction other) {
    if (identical(this, other)) return true;

    return other.userID == userID && other.reaction == reaction;
  }

  @override
  int get hashCode => userID.hashCode ^ reaction.hashCode;
}
