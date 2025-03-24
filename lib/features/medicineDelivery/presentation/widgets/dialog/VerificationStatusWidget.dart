import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VerificationStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset('assets/animations/verified.json', width: 100, height: 100),
        Text("Prescription Verified!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }
}
