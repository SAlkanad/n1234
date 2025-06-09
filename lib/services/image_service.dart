import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/firebase_constants.dart';

class ImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      final ref = _storage
          .ref()
          .child(FirebaseConstants.imagesStorage)
          .child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('خطأ في رفع الصورة: ${e.toString()}');
    }
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore delete errors
    }
  }
}
