import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
class RequestSentWidget extends StatelessWidget {
  final List<MedicalStore> nearbyStores;

  RequestSentWidget({required this.nearbyStores});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Request sent to nearby stores...", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ...nearbyStores.map((store) => Text("• ${store.name}", style: TextStyle(color: Colors.grey[700]))),
      ],
    );
  }
}
