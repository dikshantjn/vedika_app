import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/MedicalStoreVendorUpdateProfileContent.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/ViewProfile/CertificateListBuilder.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/ViewProfile/StoreLocationWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/ViewProfile/StorePhotosBuilder.dart';

class MedicalStoreVendorProfileContent extends StatefulWidget {
  const MedicalStoreVendorProfileContent({super.key});

  @override
  _MedicalStoreVendorProfileContentState createState() => _MedicalStoreVendorProfileContentState();
}

class _MedicalStoreVendorProfileContentState extends State<MedicalStoreVendorProfileContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalStoreVendorProfileViewModel>(context, listen: false).fetchProfileData();
    });
  }

  final CertificateListBuilder _certificateListBuilder = CertificateListBuilder();
  final StorePhotosBuilder storePhotosBuilder = StorePhotosBuilder();


  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreVendorProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(MedicalStoreVendorProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text("Error: ${viewModel.errorMessage}", style: const TextStyle(color: Colors.red)),
      );
    }

    final profile = viewModel.profile;
    if (profile == null) {
      return const Center(child: Text("No profile data available"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile.name, profile.address, profile.photos),
          const SizedBox(height: 20),
          _buildSection("Basic Information", [
            _buildInfoBox("Medical Store Name", profile.name),
            _buildInfoBox("GST Number", profile.gstNumber),
            _buildInfoBox("PAN Number", profile.panNumber),
          ]),

          // Check if the list is not empty before accessing first element
          _buildCertificatesSection("Registration Certificates", profile.registrationCertificates),
          _buildCertificatesSection("Compliance And License Certificates", profile.complianceCertificates),

          _buildSection("Medicine Details", [
            _buildInfoBox("Type of Medicine", profile.medicineType),
            _buildInfoBox("Rare Medications Available", profile.isRareMedicationsAvailable ? "Yes" : "No"),
          ]),
          _buildSection("Store Details", [
            _buildInfoBox("Address", profile.address),
            _buildInfoBox("Landmark", profile.landmark),
            _buildInfoBox("Store Timing", profile.storeTiming),
            _buildInfoBox("Open Days", profile.storeDays.toString()),
            _buildInfoBox("Contact Number", profile.contactNumber),
            _buildInfoBox("Email", profile.emailId),
            _buildInfoBox("Floor", profile.floor),
          ]),
          _buildSection("Store Location", [StoreLocationWidget(locationString: profile.location)]),
          _buildSection("Store Photos", storePhotosBuilder.buildStorePhotos(profile.photos.isNotEmpty ? profile.photos.first : "")),
        ],
      ),
    );
  }

  Widget _buildCertificatesSection(String title, List<String> certificates) {
    if (certificates.isEmpty) {
      return _buildSection(title, [
        const Text("No certificates available", style: TextStyle(color: Colors.red)),
      ]);
    }

    // Use the first certificate if available
    return _buildSection(
      title,
      _certificateListBuilder.buildCertificateList(certificates.first),
    );
  }

  Widget _buildProfileHeader(String storeName, String address, List<String> photos) {
    final StorePhotosBuilder storePhotosBuilder = StorePhotosBuilder();
    String? storeImageUrl = photos.isNotEmpty ? photos.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MedicalStoreVendorColorPalette.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              storeImageUrl != null
                  ? FutureBuilder<Widget>(
                future: storePhotosBuilder.buildProfilePhoto(storeImageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return _buildPlaceholderIcon();
                  }
                  return snapshot.data!;
                },
              )
                  : _buildPlaceholderIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 2, // Slightly reduced from the top
            right: 2, // Slightly adjusted for better spacing
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50), // Fully rounded shape
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  // Navigate to the MedicalStoreVendorUpdateProfileContent screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalStoreVendorUpdateProfileContent(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.edit,
                  color: MedicalStoreVendorColorPalette.primaryColor,
                  size: 22, // Reduced size for a more compact button
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


// Placeholder icon when no image is available
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.storefront, size: 40, color: Colors.white),
    );
  }



  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

}