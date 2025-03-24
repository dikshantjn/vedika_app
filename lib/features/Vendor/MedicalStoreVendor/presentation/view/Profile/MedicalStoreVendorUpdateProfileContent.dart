import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStoreBasicInfo.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStoreDetails.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStoreMedicineDetails.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStorePaymentOptions.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStorePhotosLocation.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/MedicalStoreRegistration.dart';

class MedicalStoreVendorUpdateProfileContent extends StatefulWidget {
  @override
  _MedicalStoreVendorUpdateProfileContentState createState() =>
      _MedicalStoreVendorUpdateProfileContentState();
}

class _MedicalStoreVendorUpdateProfileContentState
    extends State<MedicalStoreVendorUpdateProfileContent> {
  @override
  void initState() {
    super.initState();

    // Fetch profile data when the widget is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch data from ViewModel
      context.read<MedicalStoreVendorUpdateProfileViewModel>().fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreVendorUpdateProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
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
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
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
            body: Center(
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        }

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
                      viewModel.updateStoreProfile(context);
                      print("updateStoreProfile clicked");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Update Profile",
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
