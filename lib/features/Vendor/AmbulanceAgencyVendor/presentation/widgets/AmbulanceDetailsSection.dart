import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:provider/provider.dart';

class AmbulanceDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceAgencyViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number of Ambulances Field
          _buildTextField(
            label: 'Number of Ambulances',
            initialValue: viewModel.agency?.numOfAmbulances.toString(),
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(numOfAmbulances: int.tryParse(value) ?? 0));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Number of Ambulances is required';
              }
              return null;
            },
          ),
          // Driver License Field
          _buildTextField(
            label: 'Driver License Number',
            initialValue: viewModel.agency?.driverLicense,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(driverLicense: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Driver License Number is required';
              }
              return null;
            },
          ),
          // Driver KYC Completed Switch
          _buildSwitchListTile(
            title: 'Driver KYC Completed',
            value: viewModel.agency?.driverKYC ?? false,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(driverKYC: value));
            },
          ),
          // Driver Trained for Emergency Situations Switch
          _buildSwitchListTile(
            title: 'Driver Trained for Emergency Situations',
            value: viewModel.agency?.driverTrained ?? false,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(driverTrained: value));
            },
          ),
          // Ambulance Types Field
          _buildTextField(
            label: 'Types of Ambulances',
            initialValue: viewModel.agency?.ambulanceTypes.join(', '),
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(ambulanceTypes: value.split(', ')));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ambulance Types are required';
              }
              return null;
            },
          ),
          // GPS Tracking Available Switch
          _buildSwitchListTile(
            title: 'GPS Tracking Available',
            value: viewModel.agency?.gpsTrackingAvailable ?? false,
            onChanged: (value) {
              viewModel.updateAgency(viewModel.agency!.copyWith(gpsTrackingAvailable: value));
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
          // Error border for validation
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

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }
}
