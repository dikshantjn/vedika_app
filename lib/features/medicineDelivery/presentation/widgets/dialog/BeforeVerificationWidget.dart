import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class BeforeVerificationWidget extends StatefulWidget {
  final int initialTime; // Time in seconds
  final VoidCallback onTimeExpired; // Callback when time runs out
  final String? message;
  final String? lottieAsset;
  final VoidCallback? onClose;

  const BeforeVerificationWidget({
    Key? key,
    required this.initialTime,
    required this.onTimeExpired,
    this.message,
    this.lottieAsset,
    this.onClose,
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
        timer.cancel();
        widget.onTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie Animation (no background)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Lottie.asset(
                widget.lottieAsset ?? 'assets/animations/scanPrescription.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title Text with Gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.blue, Colors.blue.shade700],
            ).createShader(bounds),
            child: Text(
              widget.message ?? 'Searching Nearest Medical Shops...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Timer Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                Text(
                  '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')} min',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Information Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'It will take up to 5 minutes to search. You can leave.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: widget.onClose,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorPalette.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                foregroundColor: ColorPalette.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ],
      ),
    );
  }
}
