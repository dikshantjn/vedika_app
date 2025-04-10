import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class BloodbankAgencyStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file (image or document) and returns the download URL.
  Future<String> uploadFile(File file, {required String fileType}) async {
    try {
      final String fileExtension = file.path.split('.').last;
      final String uniqueId = _uuid.v4();
      final String fileName = '$fileType\_$uniqueId.$fileExtension';

      final Reference ref = _storage.ref().child('bloodbank_agency/$fileType/$fileName');
      final UploadTask uploadTask = ref.putFile(file);  // Using the file path directly without creating a new File instance
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;  // Only returning the URL
    } catch (e) {
      print('File upload failed: $e');
      rethrow;
    }
  }

  /// Optional: Deletes a file if needed
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('File delete failed: $e');
    }
  }
}
