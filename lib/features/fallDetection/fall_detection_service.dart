import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class FallDetectionService {
  static const double FALL_THRESHOLD = 25.0; // m/s²
  static const int STILLNESS_DURATION = 5; // seconds
  static const int CANCEL_TIMER = 5; // seconds

  final StreamController<bool> _fallDetectedController = StreamController<bool>.broadcast();
  Stream<bool> get fallDetectedStream => _fallDetectedController.stream;

  Timer? _stillnessTimer;
  Timer? _cancelTimer;
  bool _isMonitoring = false;
  bool _isFallDetected = false;
  DateTime? _lastSignificantMovement;
  
  // Logger instance
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Singleton pattern
  static final FallDetectionService _instance = FallDetectionService._internal();
  factory FallDetectionService() => _instance;
  FallDetectionService._internal();

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _logger.i('Starting fall detection monitoring');
    
    // Request necessary permissions
    await _requestPermissions();

    _isMonitoring = true;
    _isFallDetected = false;

    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });
  }

  Future<void> _requestPermissions() async {
    _logger.i('Requesting necessary permissions');
    await Permission.sms.request();
    await Permission.location.request();
    await Permission.activityRecognition.request();
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate acceleration magnitude
    double magnitude = sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );

    // Log significant movements
    if (magnitude > 15) {
      _logger.d('Significant movement detected: ${magnitude.toStringAsFixed(2)} m/s²');
    }

    if (magnitude > FALL_THRESHOLD && !_isFallDetected) {
      _logger.w('⚠️ Potential fall detected! Magnitude: ${magnitude.toStringAsFixed(2)} m/s²');
      _handlePotentialFall();
    }
  }

  void _handlePotentialFall() {
    _isFallDetected = true;
    _lastSignificantMovement = DateTime.now();
    _logger.w('🔄 Starting fall detection sequence');

    // Start cancel timer
    _cancelTimer?.cancel();
    _cancelTimer = Timer(Duration(seconds: CANCEL_TIMER), () {
      if (_isFallDetected) {
        _logger.w('⏰ Cancel timer expired - proceeding with alert');
        _sendFallAlert();
      }
    });

    // Start stillness timer
    _stillnessTimer?.cancel();
    _stillnessTimer = Timer(Duration(seconds: STILLNESS_DURATION), () {
      if (_isFallDetected) {
        _logger.w('⏰ Stillness period completed - confirming fall');
        _sendFallAlert();
      }
    });
  }

  Future<void> _sendFallAlert() async {
    if (!_isFallDetected) return;

    try {
      _logger.i('Fall Detection API Called');

      _fallDetectedController.add(true);
    } catch (e) {
      _logger.e('❌ Error sending fall alert to API: $e');
    }
  }

  void cancelAlert() {
    _logger.i('🛑 Fall alert cancelled by user');
    _isFallDetected = false;
    _cancelTimer?.cancel();
    _stillnessTimer?.cancel();
    _fallDetectedController.add(false);
  }

  void stopMonitoring() {
    _logger.i('🛑 Stopping fall detection monitoring');
    _isMonitoring = false;
    _isFallDetected = false;
    _cancelTimer?.cancel();
    _stillnessTimer?.cancel();
  }

  void dispose() {
    _logger.i('🧹 Disposing fall detection service');
    stopMonitoring();
    _fallDetectedController.close();
  }
} 