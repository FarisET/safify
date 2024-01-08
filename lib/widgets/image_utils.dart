import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageUtils {
  Future<File?> pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      return File(returnedImage.path);
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage != null) {
      return File(returnedImage.path);
    }
    return null;
  }
}
