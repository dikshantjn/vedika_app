import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: DoctorConsultationColorPalette.errorRed,
            ),
            SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 