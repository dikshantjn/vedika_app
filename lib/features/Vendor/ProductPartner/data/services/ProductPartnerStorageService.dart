import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class ProductPartnerStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();
  final Uuid _uuid = Uuid();

  /// Returns the download URL as a string
  Future<String> uploadFile(File file) async {
    try {
      // Generate a unique file name
      final String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      
      // Create the storage reference path
      final Reference storageRef = _storage.ref()
          .child('product_partner')
          .child('products')
          .child(fileName);
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(file);
      
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      _logger.i('Product image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading product image: $e');
      throw Exception('Failed to upload product image: $e');
    }
  }

  /// Returns a list of download URLs
  Future<List<String>> uploadMultipleFiles(List<File> files) async {
    try {
      List<String> downloadUrls = [];
      
      for (var file in files) {
        final String url = await uploadFile(file);
        downloadUrls.add(url);
      }
      
      _logger.i('Multiple product images uploaded successfully: $downloadUrls');
      return downloadUrls;
    } catch (e) {
      _logger.e('Error uploading multiple product images: $e');
      throw Exception('Failed to upload multiple product images: $e');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Get the reference from the URL
      final Reference storageRef = _storage.refFromURL(fileUrl);
      
      // Delete the file
      await storageRef.delete();
      
      _logger.i('Product image deleted successfully: $fileUrl');
    } catch (e) {
      _logger.e('Error deleting product image: $e');
      throw Exception('Failed to delete product image: $e');
    }
  }

  /// Upload a base64 image to Firebase Storage
  /// Returns the download URL as a string
  Future<String> uploadBase64Image(String base64Image) async {
    try {
      // Create a temporary file from the base64 string
      final Directory tempDir = Directory.systemTemp;
      final String tempPath = path.join(tempDir.path, '${_uuid.v4()}.jpg');
      final File tempFile = File(tempPath);
      
      // Write the base64 data to the file
      await tempFile.writeAsBytes(base64Decode(base64Image));
      
      // Upload the file
      final String downloadUrl = await uploadFile(tempFile);
      
      // Delete the temporary file
      await tempFile.delete();
      
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading base64 product image: $e');
      throw Exception('Failed to upload base64 product image: $e');
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