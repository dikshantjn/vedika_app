import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/UploadSectionWidget.dart';

class MedicalStoreRegistration extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStoreRegistration({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Registration & Licensing"),

        // Upload Registration Certificate Section
        UploadSectionWidget(
          label: "Upload Registration Certificate (PDF, PNG, JPG)",
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadRegistrationCertificates(files);
          },
        ),

        // Upload Compliance Certificate Section
        UploadSectionWidget(
          label: "Upload Compliance Certificate (PDF, PNG, JPG)",
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadComplianceCertificates(files);
          },
        ),
      ],
    );
  }
}