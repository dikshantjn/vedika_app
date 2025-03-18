import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/CustomSwitch.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/DropdownWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/SectionTitle.dart';

class MedicalStoreMedicineDetails extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStoreMedicineDetails({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Medicine Details"),
        DropdownWidget(
          label: "Type of Medicine",
          items: ["Alopathy", "Homeopathy", "Ayurvedic", "Generic"],
          selectedValue: viewModel.medicineType,
          onChanged: (value) {
            viewModel.medicineType = value!;
            viewModel.notifyListeners(); // Ensure UI updates
          },
        ),
        CustomSwitch(
          label: "Availability of Rare or Specialized Medications",
          value: viewModel.isRareMedicationsAvailable,
          onChanged: (value) {
            viewModel.isRareMedicationsAvailable = value;
            viewModel.notifyListeners(); // Ensure UI updates
          },
        ),

      ],
    );
  }
}
