// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Unreader {
  final String id;
  final int messageCount;

  Unreader({
    required this.id,
    required this.messageCount,
  });

  Unreader copyWith({
    String? id,
    int? messageCount,
  }) {
    return Unreader(
      id: id ?? this.id,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'messageCount': messageCount,
    };
  }

  factory Unreader.fromMap(Map<String, dynamic> map) {
    return Unreader(
      id: map['id'] as String,
      messageCount: map['messageCount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Unreader.fromJson(String source) =>
      Unreader.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Unreader(id: $id, messageCount: $messageCount)';

  @override
  bool operator ==(covariant Unreader other) {
    if (identical(this, other)) return true;

    return other.id == id && other.messageCount == messageCount;
  }

  @override
  int get hashCode => id.hashCode ^ messageCount.hashCode;
}
