import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyLocationPicker.dart';

class PaymentLocationSection extends StatelessWidget {
  final AmbulanceAgencyStorageService storageService = AmbulanceAgencyStorageService();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceAgencyViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomSwitch(
            title: 'Online Payment Available',
            value: viewModel.isOnlinePaymentAvailable,
            onChanged: (value) {
              viewModel.updateBooleanField('isOnlinePaymentAvailable', value);
            },
          ),
          const SizedBox(height: 16),

          // Office Photos Upload
          _buildSectionTitle('Upload Office Photos'),
          UploadSectionWidget(
            label: 'Office Photos',
            onFilesSelected: (List<Map<String, Object>> files) async {
              for (var fileData in files) {
                final file = fileData['file'] as File;
                final name = fileData['name'] as String;

                viewModel.addOfficePhoto(file, name);
              }
            },
          ),

// Training Certifications Upload
          _buildSectionTitle('Upload Training Certifications'),
          UploadSectionWidget(
            label: 'Training Certifications',
            onFilesSelected: (List<Map<String, Object>> files) async {
              for (var fileData in files) {
                final file = fileData['file'] as File;
                final name = fileData['name'] as String;

                viewModel.addTrainingCertification(file, name);
              }
            },
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('Set Ambulance Agency Location'),
          AmbulanceAgencyLocationPicker(
            onLocationSelected: (location) {
              viewModel.preciseLocationController.text = location;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCustomSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
