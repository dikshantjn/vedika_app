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
          'Hospital Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: HospitalVendorColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
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
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
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
          label: 'Phone Number',
          controller: viewModel.phoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit phone number';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
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