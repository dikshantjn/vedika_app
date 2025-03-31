import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class AfterVerificationWidget extends StatelessWidget {
  final String medicalStoreName;
  final VoidCallback onTrackOrder;

  const AfterVerificationWidget({
    Key? key,
    required this.medicalStoreName,
    required this.onTrackOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lottie Animation for Success
        Lottie.asset(
          'assets/animations/verified.json',
          height: 120,
          width: 120,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10),

        // Success Message
        const Text(
          'Prescription Verified!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 10),

        // Store Verification Details
        Text(
          'Verified by: $medicalStoreName',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 20),

        // Track Order Button
        OutlinedButton(
          onPressed: onTrackOrder,
          child: const Text('Track Your Order', style: TextStyle(fontSize: 16)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: ColorPalette.primaryColor),
          ),
        ),
      ],
    );
  }
}
