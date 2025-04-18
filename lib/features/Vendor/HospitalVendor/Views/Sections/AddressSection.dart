import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: viewModel.addressController,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
            hintText: 'Enter hospital address',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter hospital address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.landmarkController,
          decoration: const InputDecoration(
            labelText: 'Landmark',
            border: OutlineInputBorder(),
            hintText: 'Enter nearby landmark',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter landmark';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: viewModel.selectedState.isNotEmpty ? viewModel.selectedState : null,
          decoration: const InputDecoration(
            labelText: 'State',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra')),
            DropdownMenuItem(value: 'Gujarat', child: Text('Gujarat')),
            // Add more states as needed
          ],
          onChanged: (value) {
            if (value != null) {
              viewModel.updateState(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select state';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: viewModel.selectedCity.isNotEmpty ? viewModel.selectedCity : null,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
            DropdownMenuItem(value: 'Pune', child: Text('Pune')),
            // Add more cities as needed
          ],
          onChanged: (value) {
            if (value != null) {
              viewModel.updateCity(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select city';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: viewModel.pincodeController,
          decoration: const InputDecoration(
            labelText: 'Pincode',
            border: OutlineInputBorder(),
            hintText: 'Enter pincode',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter pincode';
            }
            if (value.length != 6) {
              return 'Pincode must be 6 digits';
            }
            return null;
          },
        ),
      ],
    );
  }
} 