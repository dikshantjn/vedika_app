import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/UploadSectionWidget.dart';

class MedicalStorePhotosLocation extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStorePhotosLocation({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Photos & Location"),

        // Upload Photos Section with Multiple File Selection
        UploadSectionWidget(
          label: "Upload Latest Photos of Medical Store",
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.photos = files; // Directly store the list of maps (dt & file)
            viewModel.notifyListeners();
          },
        ),



        const SizedBox(height: 15),

        // Google Maps Location Picker
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Precise Location using Google Maps",
                style: TextStyle(
                  fontSize: 14,
                  color: MedicalStoreVendorColorPalette.textColor,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  String selectedLocation = await _selectLocationOnMap();
                  viewModel.location = selectedLocation;
                  viewModel.notifyListeners();
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                  child: Center(
                    child: viewModel.location.isEmpty
                        ? const Icon(Icons.map, size: 50, color: Colors.grey)
                        : Text(viewModel.location, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String> _selectLocationOnMap() async {
    // Mock function to simulate Google Maps selection
    await Future.delayed(const Duration(seconds: 1));
    return "Selected Location: 12.9716° N, 77.5946° E"; // Replace with actual map logic
  }
}
