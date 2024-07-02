import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveImageTempLocally(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagesDir = Directory('${directory.path}/temp_images');

  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  String fileName = imageFile.path.split('/').last;
  String savedImagePath = '${imagesDir.path}/$fileName';

  int counter = 1;
  while (await File(savedImagePath).exists()) {
    final nameWithoutExtension = fileName.replaceAll(RegExp(r'\.[^\.]+$'), '');
    final extension = fileName.split('.').last;
    fileName = '$nameWithoutExtension($counter).$extension';
    savedImagePath = '${imagesDir.path}/$fileName';
    counter++;
  }

  try {
    await imageFile.copy(savedImagePath);
    print('Image saved to $savedImagePath');
    return savedImagePath;
  } catch (e) {
    print('Error saving image: $e');
    rethrow;
  }
}

// Future<void> deleteTempImages() async {
//   final directory = await getApplicationDocumentsDirectory();
//   final imagesDir = Directory('${directory.path}/temp_images');

//   if (await imagesDir.exists()) {
//     await imagesDir.delete(recursive: true);
//   }
// }

Future<void> deleteTempImage(String imagePath) async {
  try {
    await File(imagePath).delete();
    ('Image deleted from $imagePath');
  } catch (e) {
    print('Error deleting image: $e');
  }
}
