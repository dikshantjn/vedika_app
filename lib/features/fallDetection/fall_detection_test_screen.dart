import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'fall_detection_service.dart';
import 'package:logger/logger.dart';

class FallDetectionTestScreen extends StatefulWidget {
  const FallDetectionTestScreen({Key? key}) : super(key: key);

  @override
  State<FallDetectionTestScreen> createState() => _FallDetectionTestScreenState();
}

class _FallDetectionTestScreenState extends State<FallDetectionTestScreen> {
  final FallDetectionService _fallDetectionService = FallDetectionService();
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
  
  bool _isMonitoring = false;
  bool _isFallDetected = false;
  
  // Sensor data
  double _x = 0;
  double _y = 0;
  double _z = 0;
  double _magnitude = 0;
  DateTime? _lastLogTime;

  @override
  void initState() {
    super.initState();
    _fallDetectionService.fallDetectedStream.listen((isFallDetected) {
      setState(() {
        _isFallDetected = isFallDetected;
      });
    });
  }

  void _startMonitoring() async {
    await _fallDetectionService.startMonitoring();
    setState(() {
      _isMonitoring = true;
    });

    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
        _magnitude = sqrt(_x * _x + _y * _y + _z * _z);
      });

      // Log significant movements (every 500ms to avoid console spam)
      final now = DateTime.now();
      if (_lastLogTime == null || 
          now.difference(_lastLogTime!).inMilliseconds > 500) {
        if (_magnitude > 15) {
          _logger.d('📊 Sensor Data - X: ${_x.toStringAsFixed(2)}, '
              'Y: ${_y.toStringAsFixed(2)}, '
              'Z: ${_z.toStringAsFixed(2)}, '
              'Magnitude: ${_magnitude.toStringAsFixed(2)} m/s²');
          _lastLogTime = now;
        }
      }
    });
  }

  void _stopMonitoring() {
    _fallDetectionService.stopMonitoring();
    setState(() {
      _isMonitoring = false;
    });
  }

  String _getAccelerationStatus() {
    if (_magnitude < 15) return 'Normal';
    if (_magnitude < 20) return 'Moderate';
    if (_magnitude < 25) return 'High';
    return 'Fall Detected!';
  }

  Color _getAccelerationColor() {
    if (_magnitude < 15) return Colors.green;
    if (_magnitude < 20) return Colors.orange;
    if (_magnitude < 25) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Detection Test'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safety Warning Card
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, 
                            color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Safety Warning',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '⚠️ Do not drop your phone from heights above 2 meters\n'
                        '⚠️ Test on a soft surface like a bed or couch\n'
                        '⚠️ Hold the phone securely during testing\n'
                        '⚠️ Sudden movements can also trigger the sensor',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status: ${_isMonitoring ? "Monitoring" : "Stopped"}',
                        style: TextStyle(
                          fontSize: 18,
                          color: _isMonitoring ? Colors.green : Colors.red,
                        ),
                      ),
                      if (_isFallDetected)
                        const Text(
                          'FALL DETECTED!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sensor Data Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sensor Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('X: ${_x.toStringAsFixed(2)} m/s²'),
                      Text('Y: ${_y.toStringAsFixed(2)} m/s²'),
                      Text('Z: ${_z.toStringAsFixed(2)} m/s²'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getAccelerationColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Magnitude: ${_magnitude.toStringAsFixed(2)} m/s²',
                              style: TextStyle(
                                color: _getAccelerationColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getAccelerationStatus(),
                              style: TextStyle(
                                color: _getAccelerationColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Threshold Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Threshold Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Fall Threshold: ${FallDetectionService.FALL_THRESHOLD} m/s²'),
                      Text('Stillness Duration: ${FallDetectionService.STILLNESS_DURATION} seconds'),
                      Text('Cancel Timer: ${FallDetectionService.CANCEL_TIMER} seconds'),
                      const SizedBox(height: 8),
                      const Text(
                        'Note: The sensor is sensitive to sudden movements. '
                        'Even dropping from pocket height can trigger the detection.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMonitoring ? Colors.red : Colors.green,
                    ),
                    child: Text(_isMonitoring ? 'Stop Monitoring' : 'Start Monitoring'),
                  ),
                  if (_isFallDetected)
                    ElevatedButton(
                      onPressed: () {
                        _fallDetectionService.cancelAlert();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Cancel Alert'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fallDetectionService.dispose();
    super.dispose();
  }
} 