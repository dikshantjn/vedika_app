import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/viewmodels/product_partner_viewmodel.dart';

class CompanyInfoSection extends StatefulWidget {
  @override
  _CompanyInfoSectionState createState() => _CompanyInfoSectionState();
}

class _CompanyInfoSectionState extends State<CompanyInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final viewModel = Provider.of<ProductPartnerViewModel>(context, listen: false);
        viewModel.setProfilePicture(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductPartnerViewModel>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Upload
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              image: viewModel.profilePicture != null
                                  ? DecorationImage(
                                      image: FileImage(File(viewModel.profilePicture!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: viewModel.profilePicture == null
                                ? Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload Profile Picture',
                          style: TextStyle(
                            color: ColorPalette.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Company Legal Name
                  _buildTextField(
                    controller: viewModel.companyLegalNameController,
                    label: 'Company Legal Name',
                    hint: 'Enter your company\'s legal name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter company legal name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Brand Name
                  _buildTextField(
                    controller: viewModel.brandNameController,
                    label: 'Brand Name',
                    hint: 'Enter your brand name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter brand name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Phone Number
                  _buildTextField(
                    controller: viewModel.phoneNumberController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Email
                  _buildTextField(
                    controller: viewModel.emailController,
                    label: 'Email',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Password
                  _buildTextField(
                    controller: viewModel.passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Confirm Password
                  _buildTextField(
                    controller: viewModel.confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != viewModel.passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // GST Number
                  _buildTextField(
                    controller: viewModel.gstNumberController,
                    label: 'GST Number',
                    hint: 'Enter your GST number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter GST number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // PAN Card Number
                  _buildTextField(
                    controller: viewModel.panCardNumberController,
                    label: 'PAN Card Number',
                    hint: 'Enter your PAN card number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter PAN card number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorPalette.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
} 