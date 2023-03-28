import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_result/flutter_result.dart';

class StorageServices {
  final Reference storageRef = FirebaseStorage.instance.ref();

  Future<Result<String, Exception>> saveProfileImage(
      File file, String userId) async {
    try {
      final imageRef = storageRef.child('profile_images/$userId');

      final UploadTask uploadTask = imageRef.putFile(file);
      final TaskSnapshot snaps = (await uploadTask);
      if (snaps.state == TaskState.success) {
        final String url = (await snaps.ref.getDownloadURL());
        return Result.success(url);
      } else {
        return Result.error(Exception('Upload Failed'));
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
