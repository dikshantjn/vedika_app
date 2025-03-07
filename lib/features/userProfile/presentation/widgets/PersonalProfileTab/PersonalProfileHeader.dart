import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';

class PersonalProfileHeader extends StatelessWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // If personalProfile is null, show a placeholder or loading indicator
    if (viewModel.personalProfile == null) {
      return Center(
        child: CircularProgressIndicator(), // Loading indicator
      );
    }

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
          // Profile picture container
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color for the profile picture
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: viewModel.personalProfile?.photoUrl.isNotEmpty == true
                  ? Image.network(
                viewModel.personalProfile!.photoUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
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
          // User information
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.personalProfile!.name.isNotEmpty
                      ? viewModel.personalProfile!.name
                      : 'Name not available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  viewModel.personalProfile!.phoneNumber.isNotEmpty
                      ? viewModel.personalProfile!.phoneNumber
                      : 'Phone Number not available',
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
