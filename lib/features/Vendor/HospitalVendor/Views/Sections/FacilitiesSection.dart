import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';

class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HospitalRegistrationViewModel>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildFacilitySwitch(
          context,
          'Lift Access',
          viewModel.hasLiftAccess,
          viewModel.toggleLiftAccess,
        ),
        const SizedBox(height: 16),
        _buildFacilitySwitch(
          context,
          'Parking Available',
          viewModel.hasParking,
          viewModel.toggleParking,
        ),
        const SizedBox(height: 16),
        _buildFacilitySwitch(
          context,
          'Ambulance Service',
          viewModel.providesAmbulanceService,
          viewModel.toggleAmbulanceService,
        ),
        const SizedBox(height: 16),
        _buildFacilitySwitch(
          context,
          'Wheelchair Access',
          viewModel.hasWheelchairAccess,
          viewModel.toggleWheelchairAccess,
        ),
        const SizedBox(height: 16),
        _buildFacilitySwitch(
          context,
          'Online Consultancy',
          viewModel.providesOnlineConsultancy,
          viewModel.toggleOnlineConsultancy,
        ),
        const SizedBox(height: 20),
        const Text(
          'About Hospital',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.aboutController,
          decoration: const InputDecoration(
            labelText: 'Write about your hospital',
            border: OutlineInputBorder(),
            hintText: 'Describe your hospital, its history, and achievements...',
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please write about your hospital';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFacilitySwitch(
    BuildContext context,
    String label,
    bool value,
    VoidCallback onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
} 