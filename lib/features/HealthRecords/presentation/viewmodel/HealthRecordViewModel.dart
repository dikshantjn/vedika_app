import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/Service/HealthRecordService.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
// import service class here (to be created)

class HealthRecordViewModel extends ChangeNotifier {
  final HealthRecordService _service = HealthRecordService();
  List<HealthRecord> _records = [];
  bool _isLoading = false;

  List<HealthRecord> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _records = await _service.fetchRecords();
    } catch (e) {
      print('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _service.addRecord(record);
      await loadRecords();
    } catch (e) {
      print('Error adding record: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String healthRecordId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Find the record to get its file URL
      final record = _records.firstWhere((r) => r.healthRecordId == healthRecordId);
      
      // First delete the record from the API
      print('🗑️ Deleting record from API...');
      print('   Record ID: $healthRecordId');
      print('   API Endpoint: ${ApiEndpoints.deleteHealthRecord}/$healthRecordId');
      
      await _service.deleteRecord(healthRecordId);
      print('✅ Record deleted from API successfully');

      // Then delete the file from Firebase Storage
      if (record.fileUrl.isNotEmpty) {
        try {
          print('🗑️ Deleting file from Firebase Storage...');
          final ref = FirebaseStorage.instance.refFromURL(record.fileUrl);
          await ref.delete();
          print('✅ File deleted from Firebase Storage successfully');
        } catch (e) {
          print('⚠️ Error deleting file from Firebase Storage: $e');
          // Continue even if file deletion fails
        }
      }

      // Finally refresh the records list
      print('🔄 Refreshing records list...');
      await loadRecords();
      print('✅ Records list refreshed successfully');
    } catch (e) {
      print('❌ Error in deleteRecord: $e');
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> updateRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _service.updateRecord(record);
      await loadRecords();
    } catch (e) {
      print('Error updating record: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadRecord(HealthRecord record) async {
    if (await canLaunch(record.fileUrl)) {
      await launch(record.fileUrl);
    } else {
      throw 'Could not launch ${record.fileUrl}';
    }
  }

  void uploadRecord(PlatformFile file, String category) {
    try {
      HealthRecord newRecord = HealthRecord(
        userId: '',
        healthRecordId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        fileUrl: file.path!,  // Ensure path exists
        type: category,        // Assign the selected category
        uploadedAt: DateTime.now(), // Add uploaded timestamp
      );

      addRecord(newRecord);
      debugPrint("File uploaded: ${file.name} under $category");
    } catch (e) {
      debugPrint("Error uploading file: $e");
    }
  }

  Future<void> uploadRecordWithDialog(String name, String type, PlatformFile file, BuildContext context) async {
    try {
      print('📤 Starting file upload process:');
      print('   File Name: ${file.name}');
      print('   File Size: ${file.size} bytes');
      print('   File Type: $type');

      Uint8List? uploadData;
      if (file.bytes != null) {
        uploadData = file.bytes;
        print('📦 Using in-memory file bytes');
      } else if (file.path != null) {
        uploadData = await File(file.path!).readAsBytes();
        print('📦 Reading file from path: ${file.path}');
      }
      if (uploadData == null) throw 'Could not read file bytes';
      
      print('📤 Uploading to Firebase Storage...');
      final storageRef = FirebaseStorage.instance.ref().child('health_records/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      UploadTask uploadTask = storageRef.putData(uploadData);
      TaskSnapshot snapshot = await uploadTask;
      String fileUrl = await snapshot.ref.getDownloadURL();
      print('✅ File uploaded successfully');
      print('   File URL: $fileUrl');

      print('🔑 Getting user ID...');
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        print('❌ User ID not found');
        throw 'User ID not found. Please login again.';
      }
      print('✅ User ID retrieved: $userId');

      print('📝 Creating health record...');
      HealthRecord newRecord = HealthRecord(
        healthRecordId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        fileUrl: fileUrl,
        type: type,
        uploadedAt: DateTime.now(),
      );
      print('📤 Sending record to API...');
      print('   Record Data: ${newRecord.toJson()}');

      final addedRecord = await _service.addRecord(newRecord);
      print('✅ Record added successfully');
      print('   Added Record: ${addedRecord.toJson()}');

      await loadRecords();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record uploaded successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('❌ Error in uploadRecordWithDialog:');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading record: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
