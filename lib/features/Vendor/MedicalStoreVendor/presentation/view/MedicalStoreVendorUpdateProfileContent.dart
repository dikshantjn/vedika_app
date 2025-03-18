import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStoreBasicInfo.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStoreDetails.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStoreMedicineDetails.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStorePaymentOptions.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStorePhotosLocation.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStoreRegistration.dart';

class MedicalStoreVendorUpdateProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreVendorUpdateProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
          appBar: AppBar(
            title: const Text(
              "Medical Store Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedicalStoreBasicInfo(viewModel: viewModel),
                MedicalStoreRegistration(viewModel: viewModel),
                MedicalStoreMedicineDetails(viewModel: viewModel),
                MedicalStorePaymentOptions(viewModel: viewModel),
                MedicalStoreDetails(viewModel: viewModel),
                MedicalStorePhotosLocation(viewModel: viewModel),

                // Save Button
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.saveProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Save Profile",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
