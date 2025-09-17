import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Hospital Name',
          controller: viewModel.hospitalNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter hospital name';
            }
            return null;
          },
          prefixIcon: Icons.local_hospital,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          controller: viewModel.emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Password',
          controller: viewModel.passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          prefixIcon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm Password',
          controller: viewModel.confirmPasswordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != viewModel.passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          prefixIcon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Contact Number',
          controller: viewModel.phoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Contact number';
            }
            if (value.length != 10) {
              return 'Contact number must be 10 digits';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'GST Number',
          controller: viewModel.gstNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter GST number';
            }
            if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(value)) {
              return 'Please enter a valid GST number';
            }
            return null;
          },
          prefixIcon: Icons.receipt_long,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Website',
          controller: viewModel.websiteController,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$').hasMatch(value)) {
                return 'Please enter a valid website URL';
              }
            }
            return null;
          },
          prefixIcon: Icons.language,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Owner Name',
          controller: viewModel.ownerNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner\'s name';
            }
            return null;
          },
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Owner Contact Number',
          controller: viewModel.ownerContactController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner\'s contact number';
            }
            if (value.length != 10) {
              return 'Contact number must be 10 digits';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'PAN Number',
          controller: viewModel.panNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PAN number';
            }
            if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
              return 'Please enter a valid PAN number';
            }
            return null;
          },
          prefixIcon: Icons.credit_card,
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: HospitalVendorColorPalette.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: HospitalVendorColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: HospitalVendorColorPalette.primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: HospitalVendorColorPalette.backgroundPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: HospitalVendorColorPalette.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: HospitalVendorColorPalette.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: HospitalVendorColorPalette.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: HospitalVendorColorPalette.errorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: HospitalVendorColorPalette.errorRed,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          color: HospitalVendorColorPalette.errorRed,
          fontSize: 12,
        ),
      ),
    );
  }
} 