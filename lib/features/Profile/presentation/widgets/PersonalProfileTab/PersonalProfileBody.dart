import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';

class PersonalProfileBody extends StatelessWidget {
  final UserProfileViewModel viewModel;

  PersonalProfileBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Number and Location
          _buildRow('Contact Number:', viewModel.personalProfile.contactNumber),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          _buildRow('Location:', viewModel.personalProfile.location),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          // Date of Birth and Gender
          _buildRow('Date of Birth:', viewModel.formattedDateOfBirth),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          _buildRow('Gender:', viewModel.personalProfile.gender),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          // Blood Group, Height, and Weight
          _buildRow('Blood Group:', viewModel.personalProfile.bloodGroup),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          _buildRow('Height:', '${viewModel.personalProfile.height} cm'),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          _buildRow('Weight:', '${viewModel.personalProfile.weight} kg'),
          Divider(thickness: 1.2, color: Colors.grey[300]),

          // Emergency Contact
          _buildRow('Emergency Contact:', viewModel.personalProfile.emergencyContactNumber),
        ],
      ),
    );
  }

  // Helper method to create consistent row items
  Widget _buildRow(String title, String value) {
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
            value,
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
}
