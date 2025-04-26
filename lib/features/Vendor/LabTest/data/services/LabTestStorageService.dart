import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class LabTestStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();
  final Uuid _uuid = Uuid();

  /// Returns the download URL as a string
  Future<String> uploadFile(File file, {required String fileType}) async {
    try {
      // Generate a unique file name
      final String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      
      // Create the storage reference path
      final Reference storageRef = _storage.ref()
          .child('lab_test')
          .child(fileType)
          .child(fileName);
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(file);
      
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      _logger.i('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Returns a list of download URLs
  Future<List<String>> uploadMultipleFiles(List<File> files, {required String fileType}) async {
    try {
      List<String> downloadUrls = [];
      
      for (var file in files) {
        final String url = await uploadFile(file, fileType: fileType);
        downloadUrls.add(url);
      }
      
      _logger.i('Multiple files uploaded successfully: $downloadUrls');
      return downloadUrls;
    } catch (e) {
      _logger.e('Error uploading multiple files: $e');
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Get the reference from the URL
      final Reference storageRef = _storage.refFromURL(fileUrl);
      
      // Delete the file
      await storageRef.delete();
      
      _logger.i('File deleted successfully: $fileUrl');
    } catch (e) {
      _logger.e('Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Upload a base64 image to Firebase Storage
  /// Returns the download URL as a string
  Future<String> uploadBase64Image(String base64Image, {required String fileType}) async {
    try {
      // Create a temporary file from the base64 string
      final Directory tempDir = Directory.systemTemp;
      final String tempPath = path.join(tempDir.path, '${_uuid.v4()}.jpg');
      final File tempFile = File(tempPath);
      
      // Write the base64 data to the file
      await tempFile.writeAsBytes(base64Decode(base64Image));
      
      // Upload the file
      final String downloadUrl = await uploadFile(tempFile, fileType: fileType);
      
      // Delete the temporary file
      await tempFile.delete();
      
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading base64 image: $e');
      throw Exception('Failed to upload base64 image: $e');
    }
  }

  /// Convert a base64 string to bytes
  List<int> base64Decode(String base64String) {
    // Remove any Base64 URL encoding characters and padding if present
    String sanitized = base64String;
    if (base64String.contains(',')) {
      sanitized = base64String.split(',').last;
    }
    
    // Decode the base64 string to bytes
    return base64.decode(sanitized);
  }
} 