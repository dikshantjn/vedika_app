
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';

class HealthRecordRepository {
  // Mocked List of Google Drive Files
  List<HealthRecord> _records = [
    HealthRecord(
      id: "1",
      name: "Blood Test Report",
      type: "Test Reports",
      fileUrl: "https://docs.google.com/document/d/1xRYWj_NAWyhBWvf4zrWjKV8MESMaF_Fs8K_PJ9WWRKw/edit?usp=drive_link",
      uploadedAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    HealthRecord(
      id: "2",
      name: "Prescription - Dr. John",
      type: "Prescription",
      fileUrl: "https://docs.google.com/document/d/1xRYWj_NAWyhBWvf4zrWjKV8MESMaF_Fs8K_PJ9WWRKw/edit?usp=drive_link",
      uploadedAt: DateTime.now().subtract(Duration(days: 10)),
    ),
  ];

  Future<List<HealthRecord>> fetchRecords() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulating network delay
    return _records;
  }

  void addRecord(HealthRecord record) {
    _records.add(record);
  }
}
