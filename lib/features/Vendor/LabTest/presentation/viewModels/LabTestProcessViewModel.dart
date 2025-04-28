import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';

class LabTestProcessViewModel extends ChangeNotifier {
  final LabTestBooking booking;
  final LabTestService _labTestService = LabTestService();
  final LabTestStorageService _storageService = LabTestStorageService();
  List<ReportUpload> _reportUploads = [];
  bool _isProcessing = false;
  bool _isUpdatingStatus = false;
  bool _isUploadingFile = false;
  double _progressValue = 0.0;
  String _currentStage = "Sample Collection";
  int _currentStep = 0;

  LabTestProcessViewModel({required this.booking}) {
    _initializeReportUploads();
    _initializeCurrentStep();
  }

  void _initializeCurrentStep() {
    switch (booking.bookingStatus) {
      case 'SampleCollected':
        _currentStep = 1;
        _progressValue = 0.25;
        _currentStage = "Sample Processing";
        break;
      case 'SampleProcessing':
        _currentStep = 2;
        _progressValue = 0.5;
        _currentStage = "Report Generation";
        break;
      case 'ReportGenerating':
        _currentStep = 3;
        _progressValue = 0.75;
        _currentStage = "Report Generation";
        break;
      default:
        _currentStep = 0;
        _progressValue = 0.0;
        _currentStage = "Sample Collection";
    }
    notifyListeners();
  }

  // Getters
  List<ReportUpload> get reportUploads => _reportUploads;
  bool get isProcessing => _isProcessing;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isUploadingFile => _isUploadingFile;
  double get progressValue => _progressValue;
  String get currentStage => _currentStage;
  int get currentStep => _currentStep;

  void _initializeReportUploads() {
    _reportUploads = (booking.selectedTests ?? []).map((test) {
      final isUploaded = booking.reportUrls?.containsKey(test) ?? false;
      final fileName = isUploaded ? test : null;
      final fileUrl = isUploaded ? booking.reportUrls![test] : null;
      
      return ReportUpload(
        testName: test,
        isUploaded: isUploaded,
        fileName: fileName,
        fileUrl: fileUrl,
        fileSize: null,
        uploadDate: null,
      );
    }).toList();
    notifyListeners();
  }

  double getUploadPercentage() {
    if (_reportUploads.isEmpty) return 0.0;
    final uploadedCount = _reportUploads.where((report) => report.isUploaded).length;
    return uploadedCount / _reportUploads.length;
  }

  bool allReportsUploaded() {
    return _reportUploads.every((report) => report.isUploaded);
  }

  Future<void> uploadReport(ReportUpload report) async {
    try {
      _isUploadingFile = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Create a temporary file
        final tempFile = File(file.path!);
        
        // Upload file to storage
        final fileUrl = await _storageService.uploadFile(
          tempFile,
          fileType: 'reports'
        );

        // Update the report uploads list
        final index = _reportUploads.indexOf(report);
        _reportUploads[index] = ReportUpload(
          testName: report.testName,
          isUploaded: true,
          fileName: file.name,
          fileUrl: fileUrl,
          fileSize: _formatFileSize(file.size),
          uploadDate: DateTime.now(),
        );

        notifyListeners();
      }
    } catch (e) {
      print('Error uploading report: $e');
      // Revert the upload state if there's an error
      final index = _reportUploads.indexOf(report);
      if (index != -1) {
        _reportUploads[index] = report;
      }
    } finally {
      _isUploadingFile = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress() async {
    if (_currentStep < 3) {
      _isUpdatingStatus = true;
      notifyListeners();

      String newStatus = _getStatusForStep(_currentStep + 1);
      if (booking.bookingId == null) {
        print('Error: Booking ID is null');
        _isUpdatingStatus = false;
        notifyListeners();
        return;
      }

      final result = await _labTestService.updateBookingStatus(booking.bookingId!, newStatus);

      if (result['success']) {
        _currentStep++;
        _updateProgressForStep(_currentStep);
      } else {
        // Handle error - you might want to show a snackbar or dialog
        print('Failed to update status: ${result['message']}');
      }

      _isUpdatingStatus = false;
      notifyListeners();
    }
  }

  Future<void> goToPreviousStep() async {
    if (_currentStep > 0) {
      _isUpdatingStatus = true;
      notifyListeners();

      String newStatus = _getStatusForStep(_currentStep - 1);
      if (booking.bookingId == null) {
        print('Error: Booking ID is null');
        _isUpdatingStatus = false;
        notifyListeners();
        return;
      }

      final result = await _labTestService.updateBookingStatus(booking.bookingId!, newStatus);

      if (result['success']) {
        _currentStep--;
        _updateProgressForStep(_currentStep);
      } else {
        // Handle error - you might want to show a snackbar or dialog
        print('Failed to update status: ${result['message']}');
      }

      _isUpdatingStatus = false;
      notifyListeners();
    }
  }

  String _getStatusForStep(int step) {
    switch (step) {
      case 0:
        return "Pending";
      case 1:
        return "SampleCollected";
      case 2:
        return "SampleProcessing";
      case 3:
        return "ReportGenerating";
      case 4:
        return "Completed";
      default:
        return "Pending";
    }
  }

  void _updateProgressForStep(int step) {
    switch (step) {
      case 0:
        _progressValue = 0.0;
        _currentStage = "Sample Collection";
        break;
      case 1:
        _progressValue = 0.25;
        _currentStage = "Sample Processing";
        break;
      case 2:
        _progressValue = 0.5;
        _currentStage = "Report Generation";
        break;
      case 3:
        _progressValue = allReportsUploaded() ? 1.0 : 0.75;
        _currentStage = "Report Generation";
        break;
    }
  }

  Future<bool> markAsCompleted() async {
    if (!allReportsUploaded()) {
      print('Error: Not all reports are uploaded');
      return false;
    }

    _isProcessing = true;
    notifyListeners();
    
    if (booking.bookingId == null) {
      print('Error: Booking ID is null');
      _isProcessing = false;
      notifyListeners();
      return false;
    }

    try {
      // Create a map of test names to their URLs
      final Map<String, String> reportsUrls = {};
      for (var report in _reportUploads) {
        if (report.fileUrl != null) {
          reportsUrls[report.testName] = report.fileUrl!;
        }
      }

      // Update the booking's reportsUrls in the database
      final result = await _labTestService.updateReportUrls(
        booking.bookingId!,
        reportsUrls
      );

      if (!result['success']) {
        print('Failed to update report URLs: ${result['message']}');
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      // Update the booking status to completed
      final statusResult = await _labTestService.updateBookingStatus(
        booking.bookingId!,
        "Completed"
      );
      
      if (statusResult['success']) {
        _currentStep = 3;
        _progressValue = 1.0;
        _currentStage = "Completed";
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error marking as completed: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ReportUpload {
  final String testName;
  final bool isUploaded;
  final String? fileName;
  final String? fileUrl;
  final String? fileSize;
  final DateTime? uploadDate;

  ReportUpload({
    required this.testName,
    required this.isUploaded,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.uploadDate,
  });
} 