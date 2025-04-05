import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/EditAgencyProfileViewModel.dart';

class BasicInfoSection extends StatelessWidget {
  final EditAgencyProfileViewModel viewModel;

  const BasicInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.basicInfoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Basic Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildField(
                  controller: viewModel.agencyNameController,
                  label: "Agency Name",
                  icon: Icons.business,
                ),
                _buildField(
                  controller: viewModel.ownerNameController,
                  label: "Owner Name",
                  icon: Icons.person,
                ),
                _buildField(
                  controller: viewModel.registrationNumberController,
                  label: "Registration Number",
                  icon: Icons.confirmation_number,
                ),
                _buildField(
                  controller: viewModel.gstNumberController,
                  label: "GST Number",
                  icon: Icons.receipt_long,
                ),
                _buildField(
                  controller: viewModel.panNumberController,
                  label: "PAN Number",
                  icon: Icons.credit_card,
                ),
                _buildField(
                  controller: viewModel.contactNumberController,
                  label: "Contact Number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                _buildField(
                  controller: viewModel.emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val != null && val.contains('@') ? null : "Invalid email",
                ),
                _buildField(
                  controller: viewModel.websiteController,
                  label: "Website",
                  icon: Icons.language,
                ),
                _buildField(
                  controller: viewModel.addressController,
                  label: "Address",
                  icon: Icons.location_on,
                ),
                _buildField(
                  controller: viewModel.landmarkController,
                  label: "Landmark",
                  icon: Icons.place,
                ),
                _buildField(
                  controller: viewModel.cityController,
                  label: "City",
                  icon: Icons.location_city,
                ),
                _buildField(
                  controller: viewModel.stateController,
                  label: "State",
                  icon: Icons.map,
                ),
                _buildField(
                  controller: viewModel.pinCodeController,
                  label: "PIN Code",
                  icon: Icons.pin,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator ?? (val) => val == null || val.isEmpty ? "Required" : null,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AmbulanceAgencyColorPalette.secondaryTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
