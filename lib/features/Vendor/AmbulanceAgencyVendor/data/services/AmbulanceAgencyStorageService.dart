import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AmbulanceAgencyStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads a file (image or document) and returns a map containing the filename and download URL.
  Future<Map<String, String>> uploadFile(File file, {required String vendorId, required String fileType}) async {
    try {
      final String fileExtension = file.path.split('.').last;
      final String uniqueId = _uuid.v4();
      final String fileName = '$fileType\_$uniqueId.$fileExtension';

      final Reference ref = _storage.ref().child('ambulance_agency/$vendorId/$fileType/$fileName');
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
