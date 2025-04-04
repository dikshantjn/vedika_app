import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';

class AgencyInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceAgencyViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Agency Name',
            controller: viewModel.agencyNameController,
          ),
          _buildTextField(
            label: 'GST Number',
            controller: viewModel.gstNumberController,
          ),
          _buildTextField(
            label: 'PAN Number',
            controller: viewModel.panNumberController,
          ),
          _buildTextField(
            label: 'Owner Name',
            controller: viewModel.ownerNameController,
          ),
          _buildTextField(
            label: 'Registration Number', // Added Registration Number
            controller: viewModel.registrationNumberController,
          ),
          _buildTextField(
            label: 'Contact Number',
            controller: viewModel.contactNumberController,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(
            label: 'Email',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            label: 'Website',
            controller: viewModel.websiteController,
          ),
        ],
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          hintText: 'Enter your $label',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
