import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconData,
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
              iconData,
              size: 80,
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 