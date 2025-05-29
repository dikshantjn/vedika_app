import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GoogleSpeechToTextService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true
    ),
  );

  late final speech.SpeechApi _speechApi;
  late final AutoRefreshingAuthClient _client;
  AudioRecorder? _audioRecorder;
  bool _isInitialized = false;
  bool _isListening = false;
  Timer? _recognitionTimer;
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  late String _tempPath;
  bool _isRecording = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  String _currentTranscript = '';
  Timer? _transcriptUpdateTimer;
  String _lastProcessedTranscript = '';
  DateTime? _lastCommandTime;
  static const Duration commandCooldown = Duration(seconds: 2);
  bool _isFileReady = false;
  Timer? _audioStreamTimer;
  static const Duration audioStreamInterval = Duration(milliseconds: 100);
  bool _isProcessing = false;

  Stream<String> get transcriptionStream => _transcriptionController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('Starting Google Speech-to-Text service initialization...');
      
      // Initialize audio recorder
      try {
        _audioRecorder = AudioRecorder();
        if (!await _audioRecorder!.hasPermission()) {
          _logger.e('No microphone permission');
          throw Exception('Microphone permission is required');
        }
      } catch (e) {
        _logger.e('Failed to initialize audio recorder', error: e);
        throw Exception('Failed to initialize audio recorder. Please ensure the app has microphone permissions.');
      }

      // Get temporary directory for audio files
      final tempDir = await getTemporaryDirectory();
      _tempPath = '${tempDir.path}/temp_audio.wav';
      
      // Ensure the temp directory exists
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      
      // Create an empty audio file
      final file = File(_tempPath);
      if (!await file.exists()) {
        await file.create();
      }
      
      _logger.i('Successfully initialized audio file at $_tempPath');
      
      // Load credentials from JSON file
      String credentialsJson;
      try {
        credentialsJson = await rootBundle.loadString('assets/propane-analogy-453105-b8-dd3d3ffc61b0.json');
        _logger.i('Successfully loaded credentials file');
      } catch (e) {
        _logger.e('Failed to load credentials file', error: e);
        throw Exception('Failed to load Google Cloud credentials file. Please ensure the file exists in the assets folder.');
      }

      // Parse credentials
      Map<String, dynamic> credentialsMap;
      try {
        credentialsMap = json.decode(credentialsJson);
        _logger.i('Successfully parsed credentials JSON');
      } catch (e) {
        _logger.e('Failed to parse credentials JSON', error: e);
        throw Exception('Invalid Google Cloud credentials file format.');
      }

      // Create service account credentials
      ServiceAccountCredentials serviceAccountCredentials;
      try {
        serviceAccountCredentials = ServiceAccountCredentials.fromJson(credentialsMap);
        _logger.i('Successfully created service account credentials');
      } catch (e) {
        _logger.e('Failed to create service account credentials', error: e);
        throw Exception('Invalid service account credentials format.');
      }

      // Create authenticated client
      try {
        _client = await clientViaServiceAccount(
          serviceAccountCredentials,
          [speech.SpeechApi.cloudPlatformScope],
        );
        _logger.i('Successfully created authenticated client');
      } catch (e) {
        _logger.e('Failed to create authenticated client', error: e);
        throw Exception('Failed to authenticate with Google Cloud. Please check your credentials.');
      }

      // Initialize Speech API
      try {
        _speechApi = speech.SpeechApi(_client);
        _isInitialized = true;
        _logger.i('Google Speech-to-Text service initialized successfully');
      } catch (e) {
        _logger.e('Failed to initialize Speech API', error: e);
        throw Exception('Failed to initialize Google Speech-to-Text API.');
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing Google Speech-to-Text service', error: e, stackTrace: stackTrace);
      _isInitialized = false;
      throw Exception('Failed to initialize Google Speech-to-Text service: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_audioRecorder == null) return;

    try {
      // Ensure the file exists and is empty
      final file = File(_tempPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          _logger.w('Could not delete existing file, will try to overwrite');
        }
      }
      
      try {
        await file.create();
      } catch (e) {
        _logger.w('Could not create file, will try to use existing one');
      }
      
      _logger.i('Starting audio recording...');
      await _audioRecorder!.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        ),
        path: _tempPath,
      );
      
      // Wait for the file to be created and ready
      int attempts = 0;
      while (!await file.exists() && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      if (!await file.exists()) {
        throw Exception('Failed to create audio file');
      }
      
      _isRecording = true;
      _isFileReady = true;
      _logger.i('Audio recording started successfully');
    } catch (e) {
      _logger.e('Failed to start recording', error: e);
      _isRecording = false;
      _isFileReady = false;
      throw e;
    }
  }

  void _updateTranscript(String newTranscript) {
    if (newTranscript.isNotEmpty) {
      // Only update if the transcript has changed significantly
      if (_lastProcessedTranscript != newTranscript) {
        _currentTranscript = newTranscript;
        
        // Check if enough time has passed since the last command
        final now = DateTime.now();
        if (_lastCommandTime == null || 
            now.difference(_lastCommandTime!) > commandCooldown) {
          _transcriptionController.add(_currentTranscript);
          _lastProcessedTranscript = newTranscript;
          _lastCommandTime = now;
        }
      }
    }
  }

  Future<void> _processAudioChunk() async {
    if (!_isRecording || !_isFileReady || _isProcessing) return;

    _isProcessing = true;
    try {
      final audioFile = File(_tempPath);
      if (!await audioFile.exists()) {
        _logger.w('Audio file does not exist, restarting recording...');
        await _startRecording();
        _isProcessing = false;
        return;
      }

      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        _isProcessing = false;
        return;
      }

      final audioBytes = await audioFile.readAsBytes();
      
      final config = speech.RecognitionConfig(
        encoding: 'LINEAR16',
        sampleRateHertz: 16000,
        languageCode: 'en-US',
        enableAutomaticPunctuation: true,
        model: 'default',
      );

      final audio = speech.RecognitionAudio(
        content: base64Encode(audioBytes),
      );

      try {
        final response = await _speechApi.speech.recognize(
          speech.RecognizeRequest(
            config: config,
            audio: audio,
          ),
        );

        if (response.results != null && response.results!.isNotEmpty) {
          final transcript = response.results!.first.alternatives?.first.transcript ?? '';
          if (transcript.isNotEmpty) {
            _updateTranscript(transcript);
            _retryCount = 0;
          }
        }
      } catch (e) {
        _logger.e('Error during speech recognition', error: e);
        _retryCount++;
        
        if (_retryCount >= maxRetries) {
          _logger.e('Max retries reached, stopping recognition');
          await stopListening();
          _isProcessing = false;
          return;
        }
      }

      // Clear the audio file for next chunk
      try {
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
        await audioFile.create();
      } catch (e) {
        _logger.w('Error managing audio file, will continue with next chunk');
      }
    } catch (e) {
      _logger.e('Error processing audio chunk', error: e);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) return;

    try {
      _isListening = true;
      _retryCount = 0;
      _currentTranscript = '';
      _lastProcessedTranscript = '';
      _lastCommandTime = null;
      _isFileReady = false;
      _isProcessing = false;
      _logger.i('Starting speech recognition...');

      await _startRecording();
      
      // Wait for recording to initialize
      int attempts = 0;
      while (!_isFileReady && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      if (!_isFileReady) {
        throw Exception('Failed to initialize recording');
      }

      // Start continuous audio processing
      _audioStreamTimer = Timer.periodic(audioStreamInterval, (timer) async {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        await _processAudioChunk();
      });

      // Start transcript update timer for smoother UI updates
      _transcriptUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        if (_currentTranscript.isNotEmpty && _currentTranscript != _lastProcessedTranscript) {
          _transcriptionController.add(_currentTranscript);
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Error starting speech recognition', error: e, stackTrace: stackTrace);
      _isListening = false;
      _isRecording = false;
      _isFileReady = false;
      _isProcessing = false;
      throw Exception('Failed to start speech recognition: $e');
    }
  }

  Future<void> stop() async {
    await stopListening();
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      _isListening = false;
      _isRecording = false;
      _isFileReady = false;
      _isProcessing = false;
      _retryCount = 0;
      _audioStreamTimer?.cancel();
      _transcriptUpdateTimer?.cancel();
      if (_audioRecorder != null) {
        await _audioRecorder!.stop();
      }
      _logger.i('Stopped speech recognition');
    } catch (e, stackTrace) {
      _logger.e('Error stopping speech recognition', error: e, stackTrace: stackTrace);
      throw Exception('Failed to stop speech recognition: $e');
    }
  }

  void dispose() {
    _isListening = false;
    _isRecording = false;
    _isFileReady = false;
    _isProcessing = false;
    _retryCount = 0;
    _audioStreamTimer?.cancel();
    _transcriptUpdateTimer?.cancel();
    _transcriptionController.close();
    _client.close();
    _audioRecorder?.dispose();
  }
} 