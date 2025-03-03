import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';

class PersonalProfileHeader extends StatelessWidget {
  final UserProfileViewModel viewModel;

  PersonalProfileHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Container with background color for profile picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color for the profile picture
              shape: BoxShape.circle, // Make the container circular
            ),
            child: ClipOval(  // Use ClipOval for perfectly rounded image
              child: viewModel.personalProfile.photoUrl.isNotEmpty
                  ? Image.network(
                viewModel.personalProfile.photoUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // If the image fails to load, return the default icon
                  return Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[400],
                  );
                },
              )
                  : Icon(
                Icons.person,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
          ),
          SizedBox(width: 16),
          // Use Flexible widget to avoid overflow
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.personalProfile.name.isNotEmpty
                      ? viewModel.personalProfile.name
                      : 'Name not available', // Show 'Name not available' if name is empty or null
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  viewModel.personalProfile.email.isNotEmpty
                      ? viewModel.personalProfile.email
                      : 'Email not available', // Show 'Email not available' if email is empty or null
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
