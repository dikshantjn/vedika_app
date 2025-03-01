import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/PrescriptionFormatDialog.dart';

class PrescriptionUploadWidget extends StatelessWidget {
  const PrescriptionUploadWidget({Key? key}) : super(key: key);

  void _showPrescriptionInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PrescriptionFormatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LabTestAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.blue.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upload Prescription (Optional)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPrescriptionInfoDialog(context),
                    child: Icon(Icons.info_outline, color: Colors.blue.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (viewModel.prescriptionImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(viewModel.prescriptionImage!.path),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              // Centered Upload Button
              Center(
                child: SizedBox(
                  width: 150, // Reduced button width
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_file, color: Colors.white, size: 18), // Smaller icon
                    label: Text(
                      "Upload",
                      style: TextStyle(fontSize: 14), // Smaller text
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Reduced padding
                    ),
                    onPressed: viewModel.pickImage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
