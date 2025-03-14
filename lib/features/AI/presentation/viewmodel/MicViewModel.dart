import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/AI/data/models/MicModel.dart';

class MicViewModel extends ChangeNotifier {
  final MicModel _micModel = MicModel();
  String _audioStatus = '';

  String get audioStatus => _audioStatus;

  // Add a getter to check if the mic is recording
  bool get isRecording => _micModel.isRecording; // Ensure `isRecording` is implemented in MicModel.

  Stream<String> get audioStream => _micModel.audioStream;

  MicViewModel() {
    _micModel.audioStream.listen((status) {
      _audioStatus = status;
      notifyListeners();
    });
  }

  void startRecording() {
    _micModel.startRecording();
    notifyListeners(); // Optionally notify when starting
  }

  void stopRecording() {
    _micModel.stopRecording();
    notifyListeners(); // Optionally notify when stopping
  }

  @override
  void dispose() {
    _micModel.dispose();
    super.dispose();
  }
}
