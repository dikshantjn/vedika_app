import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

class OwnerInfoSection extends StatelessWidget {
  const OwnerInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Owner Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: viewModel.ownerNameController,
          decoration: const InputDecoration(
            labelText: 'Owner Name',
            border: OutlineInputBorder(),
            hintText: 'Enter owner\'s full name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner\'s name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.ownerContactController,
          decoration: const InputDecoration(
            labelText: 'Owner Contact Number',
            border: OutlineInputBorder(),
            hintText: 'Enter owner\'s contact number',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner\'s contact number';
            }
            if (value.length != 10) {
              return 'Contact number must be 10 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.panNumberController,
          decoration: const InputDecoration(
            labelText: 'PAN Number',
            border: OutlineInputBorder(),
            hintText: 'Enter PAN number',
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PAN number';
            }
            // PAN format validation: ABCDE1234F
            if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
              return 'Please enter a valid PAN number';
            }
            return null;
          },
        ),
      ],
    );
  }
} 