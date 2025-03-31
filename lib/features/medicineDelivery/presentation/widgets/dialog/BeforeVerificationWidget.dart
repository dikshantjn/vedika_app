import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BeforeVerificationWidget extends StatefulWidget {
  final int initialTime; // Time in seconds
  final VoidCallback onTimeExpired; // Callback when time runs out

  const BeforeVerificationWidget({
    Key? key,
    required this.initialTime,
    required this.onTimeExpired, // Added this
  }) : super(key: key);

  @override
  _BeforeVerificationWidgetState createState() => _BeforeVerificationWidgetState();
}

class _BeforeVerificationWidgetState extends State<BeforeVerificationWidget> {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel(); // Stop timer when countdown ends
        widget.onTimeExpired(); // Call the callback when time expires
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lottie Animation
        Lottie.asset(
          'assets/animations/scanPrescription.json',
          height: 120,
          width: 120,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 12),

        // Title Text
        const Text(
          'Verifying Prescription...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Live Countdown Timer Text
        Text(
          'Time Remaining: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')} minutes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        // Information Text for Verification Process
        const Text(
          'It will take up to 5 minutes to verify. You can leave.',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
