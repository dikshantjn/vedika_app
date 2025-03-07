import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';

class PersonalProfileBody extends StatelessWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Email:', viewModel.personalProfile?.email),
          _divider(),
          _buildRow('ABHA ID:', viewModel.personalProfile?.abhaId),
          _divider(),
          _buildRow('Location:', viewModel.personalProfile?.location),
          _divider(),
          _buildRow('Date of Birth:', viewModel.formattedDateOfBirth),
          _divider(),
          _buildRow('Gender:', viewModel.personalProfile?.gender),
          _divider(),
          _buildRow('Blood Group:', viewModel.personalProfile?.bloodGroup),
          _divider(),
          _buildRow('Height:', viewModel.personalProfile?.height != null ? "${viewModel.personalProfile!.height} cm" : null),
          _divider(),
          _buildRow('Weight:', viewModel.personalProfile?.weight != null ? "${viewModel.personalProfile!.weight} kg" : null),
          _divider(),
          _buildRow('Emergency Contact:', viewModel.personalProfile?.emergencyContactNumber),
        ],
      ),
    );
  }

  // Helper method to create consistent row items with null safety
  Widget _buildRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(thickness: 1.2, color: Colors.grey[300]);
  }
}