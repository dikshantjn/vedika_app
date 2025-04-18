import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          'Certifications and Licenses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Certifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        UploadSectionWidget(
          label: 'Upload Certifications',
          onFilesSelected: (files) {
            for (var file in files) {
              viewModel.addCertification({
                'name': file['name'] as String,
                'url': '', // URL will be set after upload
              });
            }
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
          onFilesSelected: (files) {
            for (var file in files) {
              viewModel.addLicense({
                'name': file['name'] as String,
                'url': '', // URL will be set after upload
              });
            }
          },
        ),
       
      ],
    );
  }
} 