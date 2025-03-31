import 'package:flutter/material.dart';

class FindMoreMedicalShopsWidget extends StatelessWidget {
  final VoidCallback onFindMore;
  final VoidCallback onCancel;

  const FindMoreMedicalShopsWidget({
    Key? key,
    required this.onFindMore,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Icon(
            Icons.location_off, // Icon to indicate no shops found
            size: 80,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),

          // Title Text
          const Text(
            "Couldn't find any medical shop near you",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Subtitle Text
          const Text(
            "Would you like to search again? It will take an additional 5 minutes.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // "Find More" Button
          ElevatedButton(
            onPressed: onFindMore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Find More Medical Shops",
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel Button
          TextButton(
            onPressed: onCancel,
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
