import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/AmbulanceAgencyLocationPicker.dart'; // Import the new widget

class PaymentLocationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceAgencyViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Online Payment Switch
          SwitchListTile(
            title: Text('Online Payment Available'),
            value: viewModel.agency?.isOnlinePaymentAvailable ?? false,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(isOnlinePaymentAvailable: value));
            },
          ),

          // Upload Office Photos Section using UploadSectionWidget
          UploadSectionWidget(
            label: 'Office Photos',
            onFilesSelected: (files) {
              // Assuming you want to save the selected files (Office Photos) into the agency model
              viewModel.updateAgency(viewModel.agency!.copyWith(officePhotos: files.toString())); // You can store the file paths or any identifier
            },
          ),

          // Ambulance Agency Location Picker (Replacing Precise Location Text Field)
          AmbulanceAgencyLocationPicker(
            onLocationSelected: (location) {
              // You can use the location (latitude, longitude) string here
              print("Selected Location: $location");

              // Assuming you want to save the selected location into the agency model
              viewModel.updateAgency(viewModel.agency!.copyWith(preciseLocation: location));
            },
          ),
        ],
      ),
    );
  }
}
