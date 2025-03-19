import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/CustomCheckbox.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/SectionTitle.dart';

class MedicalStorePaymentOptions extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStorePaymentOptions({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Payment Options"),
        CustomCheckbox(
          label: "Online Payment",
          value: viewModel.isOnlinePayment,
          onChanged: (value) {
            viewModel.isOnlinePayment = value!;
            viewModel.notifyListeners();
          },
        ),
      ],
    );
  }
}
