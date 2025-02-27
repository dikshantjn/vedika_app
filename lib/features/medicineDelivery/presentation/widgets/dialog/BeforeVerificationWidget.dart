import 'package:flutter/material.dart';
// Widget for the UI before verification
class BeforeVerificationWidget extends StatelessWidget {
  final int remainingTime;

  const BeforeVerificationWidget({
    Key? key,
    required this.remainingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Text
        Text(
          'Verifying Prescription...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        // Countdown Timer Text
        Text(
          'Time Remaining: ${remainingTime ~/ 60}:${remainingTime % 60 < 10 ? '0' : ''}${remainingTime % 60} minutes',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        // Adjust the spacing between timer and "leave" message
        SizedBox(height: 8),
        // Information Text for Verification Process
        Text(
          'It will take 5 minutes to verify. You can leave.',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
