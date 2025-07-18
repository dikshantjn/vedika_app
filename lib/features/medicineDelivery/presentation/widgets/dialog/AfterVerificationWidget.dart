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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success Animation Container with enhanced styling
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.withOpacity(0.1),
                Colors.green.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Lottie.asset(
            'assets/animations/verified.json',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),

        // Success Title with enhanced gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.green.shade600,
              Colors.green.shade800,
            ],
          ).createShader(bounds),
          child: const Text(
            'Prescription Accepted by Medical Store!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // Medical Store Name with simple styling
        Text(
          medicalStoreName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Information note
        Text(
          'Please wait while the medical store adds the mentioned medicines from your prescription to your cart.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.orange.shade800,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Track Order Button with outlined style
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTrackOrder,
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorPalette.primaryColor,
              side: BorderSide(
                color: ColorPalette.primaryColor,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.transparent,
            ),
            icon: Icon(
              Icons.local_shipping_rounded,
              color: ColorPalette.primaryColor,
              size: 22,
            ),
            label: const Text(
              'Track Your Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Additional note below button
        Text(
          'Click here to track your order',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
