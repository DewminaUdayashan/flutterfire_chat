import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageUtil {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<File?> pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final path = file.path;
      return File(path);
    } else {
      return null;
    }
  }
}
