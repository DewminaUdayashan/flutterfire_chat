import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class UserModel {
  final String email;
  final String? name;
  final String? photoUrl;
  final String? lastSeen;
  final bool isActive;

  UserModel({
    required this.email,
    this.name,
    this.photoUrl,
    this.lastSeen,
    required this.isActive,
  });

  UserModel copyWith({
    String? email,
    String? name,
    String? photoUrl,
    String? lastSeen,
    bool? isActive,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      lastSeen: map['lastSeen'] != null ? map['lastSeen'] as String : null,
      isActive: map['isActive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(email: $email, name: $name, photoUrl: $photoUrl, lastSeen: $lastSeen, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        other.lastSeen == lastSeen &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        name.hashCode ^
        photoUrl.hashCode ^
        lastSeen.hashCode ^
        isActive.hashCode;
  }
}
