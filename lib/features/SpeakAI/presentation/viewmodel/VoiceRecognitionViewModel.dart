import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vedika_healthcare/features/SpeakAI/data/service/native_speech.dart';
import 'package:vedika_healthcare/features/SpeakAI/data/service/VoiceCommandService.dart';

class VoiceRecognitionViewModel extends ChangeNotifier {
  bool isListening = false;
  bool isStarting = false;
  bool isProcessing = false;
  bool hasResult = false;
  String text = '';
  String? error;
  Map<String, dynamic>? intentData; // { intent, entities, results }

  final List<String> _suggestions = const [
    '"Emergency help"',
    '"Call doctor emergency"',
    '"Call ambulance emergency"',
    '"Call blood bank emergency"',
    '"Book an ambulance for emergency"',
    '"Find the nearest hospital"',
    '"Check blood bank availability"',
    '"Schedule a doctor appointment"',
    '"order medicine"',
  ];
  int _suggestionIndex = 0;
  Timer? _suggestionTimer;
  Timer? _clearTextTimer;
  Timer? _maxSessionTimer;
  StreamSubscription? _nativeSub;

  void initialize() {
    _startSuggestionTimer();
    _nativeSub = NativeSpeech.events().listen((event) async {
      final type = event['type'] as String?;
      if (type == 'status') {
        final status = (event['status'] ?? '').toString();
        if (status == 'listening' || status == 'ready') {
          isStarting = false;
          isListening = true;
          error = null;
          notifyListeners();
        } else if (status == 'processing') {
          isListening = false;
          notifyListeners();
        }
      } else if (type == 'result') {
        final String incomingText = (event['text'] ?? '').toString();
        final bool isFinal = (event['final'] ?? false) as bool;
        _stopSuggestionTimer();
        text = incomingText;
        notifyListeners();
        if (isFinal && incomingText.isNotEmpty) {
          isProcessing = true;
          notifyListeners();
          try {
            final data = await VoiceCommandService.resolveIntent(incomingText.trim());
            intentData = data;
            hasResult = true;
            isProcessing = false;
            text = '';
            _clearTextTimer?.cancel();
            notifyListeners();
          } catch (_) {
            // Keep showing Processing… until API eventually returns.
          }
        } else {
          _clearTextTimer?.cancel();
          final shownText = incomingText;
          _clearTextTimer = Timer(const Duration(seconds: 5), () {
            if (text == shownText && !isListening && !isProcessing && !hasResult) {
              text = '';
              notifyListeners();
              _startSuggestionTimer();
            }
          });
        }
      } else if (type == 'error') {
        final err = (event['error'] ?? '').toString();
        error = _friendlyError(err);
        isListening = false;
        isStarting = false;
        notifyListeners();
      }
    });
  }

  Future<bool> ensurePermissionsAndStart() async {
    final mic = await Permission.microphone.request();
    if (mic.isGranted) {
      final notif = await Permission.notification.status;
      if (notif.isDenied) {
        await Permission.notification.request();
      }
      isStarting = true;
      error = null;
      notifyListeners();
      await NativeSpeech.start();
      return true;
    }
    return false;
  }

  Future<bool> startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      return false;
    }
    isStarting = true;
    error = null;
    hasResult = false;
    intentData = null;
    isProcessing = false;
    notifyListeners();
    await NativeSpeech.start();
    return true;
  }

  Future<void> stopListening({bool sendFinalIfAny = false}) async {
    _maxSessionTimer?.cancel();
    isListening = false;
    notifyListeners();
    if (sendFinalIfAny && text.trim().isNotEmpty) {
      isProcessing = true;
      notifyListeners();
      try {
        final data = await VoiceCommandService.resolveIntent(text.trim());
        intentData = data;
        hasResult = true;
        isProcessing = false;
        text = '';
        notifyListeners();
      } catch (_) {
        // Keep processing true; rely on longer timeouts.
      }
    } else {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> stopService() async {
    await NativeSpeech.stop();
  }

  Future<void> submitQuery(String query) async {
    isProcessing = true;
    error = null;
    hasResult = false;
    intentData = null;
    text = '';
    notifyListeners();
    try {
      final data = await VoiceCommandService.resolveIntent(query.trim());
      intentData = data;
      hasResult = true;
      isProcessing = false;
      notifyListeners();
    } catch (_) {
      // Keep processing; user can close or retry.
    }
  }

  String get currentSuggestion => 'say: ${_suggestions[_suggestionIndex]}';

  void _startSuggestionTimer() {
    _suggestionTimer?.cancel();
    _suggestionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _suggestionIndex = (_suggestionIndex + 1) % _suggestions.length;
      notifyListeners();
    });
  }

  void _stopSuggestionTimer() {
    _suggestionTimer?.cancel();
    _suggestionTimer = null;
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('network')) return 'Network issue. Please check your internet connection.';
    if (lower.contains('no match')) return "Didn't catch that. Please try speaking again.";
    if (lower.contains('no speech') || lower.contains('timeout')) return "I didn't hear anything. Try again.";
    if (lower.contains('audio')) return 'Audio issue detected. Please try again.';
    if (lower.contains('client')) return 'Something went wrong. Please try again.';
    if (lower.contains('insufficient') || lower.contains('permission')) return 'Microphone permission needed. Enable it in Settings.';
    if (RegExp(r'code\s*:\s*\d+').hasMatch(raw)) return 'Sorry, something went wrong.';
    return raw;
  }

  @override
  void dispose() {
    _stopSuggestionTimer();
    _clearTextTimer?.cancel();
    _maxSessionTimer?.cancel();
    _nativeSub?.cancel();
    NativeSpeech.stop();
    super.dispose();
  }
}


