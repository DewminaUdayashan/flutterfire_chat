import 'package:chatty_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_result/flutter_result.dart';

const _userCollection = 'USERS';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(
      {required String userId, required UserModel user}) async {
    await _firestore.collection(_userCollection).doc(userId).set(user.toMap());
  }

  void changeActiveStatus(bool isActive, String userId) {
    _firestore
        .collection(_userCollection)
        .doc(userId)
        .update({'isOnline': isActive});
  }

  void updateUserProfileImageUrl(String userId, String url) {
    _firestore.collection(_userCollection).doc(userId).update({
      'photoUrl': url,
    });
  }

  Future<Result<UserModel, Exception>> getFirestoreUser(String userId) async {
    final userCollection = _firestore.collection(_userCollection);
    try {
      final userRef = await userCollection.doc(userId).get();
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
}
