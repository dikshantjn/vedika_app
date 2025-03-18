import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/MedicalStoreVendorUpdateProfileContent.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorProfileViewModel.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/MedicalStoreVendorDrawerMenu.dart';

class MedicalStoreVendorProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalStoreVendorProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
          appBar: AppBar(
            title: const Text(
              "Medical Store Profile",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Navigate to the update profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicalStoreVendorUpdateProfileContent()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(viewModel.storeName, viewModel.address),
                const SizedBox(height: 20),
                _buildProfileSection("Basic Information", [
                  _buildInfoBox(Icons.store, "Medical Store Name", viewModel.storeName),
                  _buildInfoBox(Icons.assignment, "GST Number", viewModel.gstNumber),
                  _buildInfoBox(Icons.credit_card, "PAN Number", viewModel.panNumber),
                ]),
                _buildProfileSection("Registration & Licensing", [
                  _buildCertificateBox(Icons.verified, "Registration Certificate", viewModel.registrationCertificate),
                  _buildCertificateBox(Icons.assignment_turned_in, "Compliance Certificate", viewModel.complianceCertificate),
                ]),
                _buildProfileSection("Medicine Details", [
                  _buildInfoBox(Icons.local_pharmacy, "Type of Medicine", viewModel.medicineType),
                  _buildInfoBox(Icons.medical_services, "Rare/Specialized Medications", viewModel.isRareMedicationsAvailable ? "Yes" : "No"),
                ]),
                _buildProfileSection("Payment Options", [
                  _buildInfoBox(Icons.payment, "Online Payment Available", viewModel.isOnlinePayment ? "Yes" : "No"),
                ]),
                _buildProfileSection("Store Details", [
                  _buildInfoBox(Icons.place, "Address", viewModel.address),
                  _buildInfoBox(Icons.location_on, "Nearby Landmark", viewModel.nearbyLandmark),
                  _buildInfoBox(Icons.access_time, "Store Timing", viewModel.storeTiming),
                  _buildInfoBox(Icons.calendar_today, "Open Days", viewModel.storeOpenDays),
                  _buildInfoBox(Icons.phone, "Contact Number", viewModel.contactNumber),
                  _buildInfoBox(Icons.email, "Email ID", viewModel.emailId),
                  _buildInfoBox(Icons.business, "Floor", viewModel.floor),
                  _buildInfoBox(Icons.elevator, "Lift Access", viewModel.isLiftAccess ? "Yes" : "No"),
                  _buildInfoBox(Icons.accessible, "Wheelchair Access", viewModel.isWheelchairAccess ? "Yes" : "No"),
                  _buildInfoBox(Icons.local_parking, "Parking Available", viewModel.isParkingAvailable ? "Yes" : "No"),
                ]),
                _buildProfileSection("Store Location", [_buildGoogleMapsSection()]),
                _buildProfileSection("Store Photos", [_buildStorePhotos(viewModel.storeImages)]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String storeName, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MedicalStoreVendorColorPalette.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  address,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateBox(IconData icon, String label, String filePath) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              // Implement logic to open file
            },
            child: const Text("View Certificate", style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
        image: DecorationImage(
          image: AssetImage("assets/images/map_placeholder.png"), // Replace with actual map API
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Icon(Icons.map, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildStorePhotos(List<String> imagePaths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imagePaths.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePaths[index], fit: BoxFit.cover),
        );
      },
    );
  }
}
