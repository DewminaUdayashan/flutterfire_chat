import 'package:chatty_chat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}
