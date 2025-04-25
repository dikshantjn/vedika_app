import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class DiagnosticCenterStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file (image or document) and returns the download URL.
  Future<String> uploadFile(File file, {required String fileType}) async {
    try {
      final String fileExtension = file.path.split('.').last;
      final String uniqueId = _uuid.v4();
      final String fileName = '$fileType\_$uniqueId.$fileExtension';

      final Reference ref = _storage.ref().child('diagnostic_center/$fileType/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('File upload failed: $e');
      rethrow;
    }
  }

  /// Deletes a file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('File delete failed: $e');
      rethrow;
    }
  }
} 