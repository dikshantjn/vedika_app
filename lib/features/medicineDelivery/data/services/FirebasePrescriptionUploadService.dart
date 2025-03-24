import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebasePrescriptionUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads the prescription file to Firebase Storage and returns the download URL.
  Future<String?> uploadPrescription(File file) async {
    try {
      // Get the filename
      String fileName = path.basename(file.path);
      print("Uploading prescription: $fileName");

      // Create a reference to Firebase Storage
      Reference storageRef = _storage.ref().child('prescriptions/$fileName');

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(file);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;
      print("Prescription uploaded: $fileName");

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Download URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("Error uploading prescription: $e");
      return null;
    }
  }
}
