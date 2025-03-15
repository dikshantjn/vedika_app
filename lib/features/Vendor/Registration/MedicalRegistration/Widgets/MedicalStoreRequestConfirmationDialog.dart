import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';

class MedicalStoreRequestConfirmationDialog extends StatelessWidget {
  final MedicalStoreRegistrationViewModel viewModel;

  const MedicalStoreRequestConfirmationDialog({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 12),

            /// **Title**
            const Text(
              "Request Submitted!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            /// **Store ID Display**
            Text(
              "Your Store ID: ${viewModel.generatedStoreId}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            /// **Confirmation Message**
            const Text(
              "Your onboard request is under review. You will be notified once it's approved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            /// **OK Button**
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(context, AppRoutes.vendor); // Navigate to Vendor Page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
