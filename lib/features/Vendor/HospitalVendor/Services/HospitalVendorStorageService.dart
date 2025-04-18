import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class HospitalVendorStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file (image or document) and returns a map containing the filename and download URL.
  Future<Map<String, String>> uploadFile(File file, {required String vendorId, required String fileType}) async {
    try {
      final String fileExtension = file.path.split('.').last;
      final String uniqueId = _uuid.v4();
      final String fileName = '$fileType\_$uniqueId.$fileExtension';

      final Reference ref = _storage.ref().child('hospital_vendor/$vendorId/$fileType/$fileName');
      final UploadTask uploadTask = ref.putFile(File(file.path));
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return {
        'name': fileName,
        'url': downloadUrl,
      };
    } catch (e) {
      print('File upload failed: $e');
      rethrow;
    }
  }

  /// Uploads multiple files and returns a list of maps containing filenames and download URLs.
  Future<List<Map<String, String>>> uploadMultipleFiles(
    List<File> files, {
    required String vendorId,
    required String fileType,
  }) async {
    try {
      List<Map<String, String>> results = [];
      for (var file in files) {
        final result = await uploadFile(file, vendorId: vendorId, fileType: fileType);
        results.add(result);
      }
      return results;
    } catch (e) {
      print('Multiple files upload failed: $e');
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