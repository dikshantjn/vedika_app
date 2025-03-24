import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';

class RequestAcceptedWidget extends StatelessWidget {
  final MedicalStore store;

  RequestAcceptedWidget({required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset('assets/animations/storeAccepted.json', width: 100, height: 100),
        Text("Request accepted by ${store.name}!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }
}
