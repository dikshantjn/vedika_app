import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class MedicalStoreFileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file with metadata (like description)
  Future<String?> uploadFileWithMetadata(File file, String description) async {
    try {
      // Get the filename
      String fileName = path.basename(file.path);
      print("Starting upload for file: $fileName with description: $description");

      // Create a reference to Firebase Storage
      Reference storageRef = _storage.ref().child('medical_store_files/$fileName');

      // Set the custom metadata
      SettableMetadata metadata = SettableMetadata(customMetadata: {
        'description': description,  // Store the description as metadata
      });

      // Upload the file with the metadata
      UploadTask uploadTask = storageRef.putFile(file, metadata);

      // Listen for task state changes (optional, but useful for debugging)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print("Upload Task state: ${snapshot.state}");
        print("Progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}");
      });

      // Wait for the upload to finish
      TaskSnapshot snapshot = await uploadTask;
      print("Upload completed for $fileName");

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("File uploaded successfully. Download URL: $downloadUrl");

      return downloadUrl;  // Return the download URL for the uploaded file
    } catch (e) {
      print("Error uploading file: $e");
      return null;  // Return null in case of error
    }
  }


  /// Function to upload vendor's profile data (including the files and metadata)
  Future<void> uploadVendorProfile(
      File licenseFile,
      String licenseDescription,
      File registrationFile,
      String registrationDescription,
      File storePhoto,
      String photoDescription,
      ) async {
    try {
      print("Starting vendor profile upload...");

      // Upload each file with its metadata (description)
      String? licenseUrl = await uploadFileWithMetadata(licenseFile, licenseDescription);
      String? registrationUrl = await uploadFileWithMetadata(registrationFile, registrationDescription);
      String? photoUrl = await uploadFileWithMetadata(storePhoto, photoDescription);

      // Here, you can now update the medical store profile in your MySQL database
      // with the URLs received for each uploaded file, along with other profile data.
      // For example:
      Map<String, String?> uploadedFiles = {
        'licenseFile': licenseUrl,
        'registrationFile': registrationUrl,
        'storePhoto': photoUrl,
      };

      print("Files uploaded and URLs received: $uploadedFiles");

      // Call the backend API to update the medical store profile with the file URLs
      // Example:
      // await _backendService.updateMedicalStoreProfileWithFiles(uploadedFiles);

    } catch (e) {
      print("Error uploading vendor profile: $e");
    }
  }

  /// Delete a file from Firebase Storage using its URL
  Future<bool> deleteFile(String fileUrl) async {
    try {
      // Get a reference to the file from the URL
      Reference fileRef = _storage.refFromURL(fileUrl);

      // Delete the file
      await fileRef.delete();

      print("File deleted successfully: $fileUrl");
      return true; // Return true if deletion was successful
    } catch (e) {
      print("Error deleting file: $e");
      return false; // Return false if an error occurs
    }
  }
}
