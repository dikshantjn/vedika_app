import 'package:flutter/material.dart';
import 'fall_detection_service.dart';

class FallDetectionWidget extends StatefulWidget {
  const FallDetectionWidget({Key? key}) : super(key: key);

  @override
  State<FallDetectionWidget> createState() => _FallDetectionWidgetState();
}

class _FallDetectionWidgetState extends State<FallDetectionWidget> {
  final FallDetectionService _fallDetectionService = FallDetectionService();
  bool _isMonitoring = false;
  bool _isFallDetected = false;

  @override
  void initState() {
    super.initState();
    _fallDetectionService.fallDetectedStream.listen((isFallDetected) {
      setState(() {
        _isFallDetected = isFallDetected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fall Detection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isMonitoring,
                  onChanged: (value) {
                    setState(() {
                      _isMonitoring = value;
                      if (value) {
                        _fallDetectionService.startMonitoring();
                      } else {
                        _fallDetectionService.stopMonitoring();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isFallDetected)
              Column(
                children: [
                  const Text(
                    'Fall Detected!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _fallDetectionService.cancelAlert();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cancel Alert'),
                  ),
                ],
              )
            else if (_isMonitoring)
              const Text(
                'Monitoring for falls...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              )
            else
              const Text(
                'Fall detection is off',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
          ],
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