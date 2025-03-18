import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/TextFieldWidget.dart';

class MedicalStoreBasicInfo extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStoreBasicInfo({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Basic Information"),

        TextFieldWidget(
          label: "Name of Medical Store",
          initialValue: viewModel.storeName,
          onChanged: (value) {
            viewModel.storeName = value;
            viewModel.notifyListeners();
          },
        ),
        TextFieldWidget(
          label: "GST Number",
          initialValue: viewModel.gstNumber,
          onChanged: (value) {
            viewModel.gstNumber = value;
            viewModel.notifyListeners();
          },
        ),
        TextFieldWidget(
          label: "PAN Number",
          initialValue: viewModel.panNumber,
          onChanged: (value) {
            viewModel.panNumber = value;
            viewModel.notifyListeners();
          },
        ),

        // Added Email ID Field
        TextFieldWidget(
          label: "Email ID",
          initialValue: viewModel.emailId,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            viewModel.emailId = value;
            viewModel.notifyListeners();
          },
        ),

        // Added Contact Number Field
        TextFieldWidget(
          label: "Contact Number",
          initialValue: viewModel.contactNumber,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            viewModel.contactNumber = value;
            viewModel.notifyListeners();
          },
        ),
      ],
    );
  }
}
