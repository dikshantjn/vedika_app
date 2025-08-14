import 'dart:async';

class MicModel {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  // Stream to handle audio status updates
  Stream<String> get audioStream => _audioStatusController.stream;
  final StreamController<String> _audioStatusController = StreamController<String>();

  void startRecording() {
    _isRecording = true;
    _audioStatusController.add('Recording Started'); // Update status
  }

  void stopRecording() {
    _isRecording = false;
    _audioStatusController.add('Recording Stopped'); // Update status
  }

  void dispose() {
    _audioStatusController.close();
  }
}
