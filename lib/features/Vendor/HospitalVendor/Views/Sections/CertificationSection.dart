import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';

class CertificationSection extends StatelessWidget {
  const CertificationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certifications and Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hospital Certifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        UploadSectionWidget(
          label: 'Upload Certifications',
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadCertifications(files);
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Government Licenses',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        UploadSectionWidget(
          label: 'Upload Government Licenses',
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadLicenses(files);
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'PAN Card',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        UploadSectionWidget(
          label: 'Upload PAN Card',
          onFilesSelected: (List<Map<String, Object>> files) {
            if (files.isNotEmpty) {
              viewModel.uploadPanCard(files[0]);
            }
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Business Registration Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        UploadSectionWidget(
          label: 'Upload Business Registration Documents',
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadBusinessDocuments(files);
          },
        ),
      ],
    );
  }
} 