import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:provider/provider.dart';

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
            initialValue: viewModel.agency?.agencyName,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(agencyName: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Agency Name is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'GST Number',
            initialValue: viewModel.agency?.gstNumber,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(gstNumber: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'GST Number is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'PAN Number',
            initialValue: viewModel.agency?.panNumber,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(panNumber: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PAN Number is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'Owner Name',
            initialValue: viewModel.agency?.ownerName,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(ownerName: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Owner Name is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'Contact Number',
            initialValue: viewModel.agency?.contactNumber,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(contactNumber: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Contact Number is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'Email',
            initialValue: viewModel.agency?.email,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(email: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
          ),
          _buildTextField(
            label: 'Website',
            initialValue: viewModel.agency?.website,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(website: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Website is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
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
          // Consistent Border Styling
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
          // Add the error border when validation fails, but keep the same shape and padding
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

}

