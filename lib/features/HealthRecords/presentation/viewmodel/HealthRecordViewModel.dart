import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/repositories/HealthRecordRepository.dart';

class HealthRecordViewModel extends ChangeNotifier {
  final HealthRecordRepository _repository = HealthRecordRepository();
  List<HealthRecord> _records = [];

  List<HealthRecord> get records => _records;

  Future<void> loadRecords() async {
    _records = await _repository.fetchRecords();
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord record) async {
    _repository.addRecord(record);
    await loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    _records.removeWhere((record) => record.id == id);
    notifyListeners();
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        fileUrl: file.path!,  // Ensure path exists
        type: category,        // Assign the selected category
        uploadedAt: DateTime.now(), // Add uploaded timestamp
      );

      _records.add(newRecord);
      notifyListeners();

      debugPrint("File uploaded: ${file.name} under $category");
    } catch (e) {
      debugPrint("Error uploading file: $e");
    }
  }


}
