import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/EditPersonalProfileScreen.dart';

class PersonalProfileEdit extends StatelessWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileEdit({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Use the methods from the view model
    bool isProfileComplete = viewModel.isProfileComplete();
    double profileCompletion = viewModel.calculateProfileCompletion();

    return Column(
      children: [
        // Existing content goes here...

        // Show the button with profile completion percentage
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: SizedBox(
            width: double.infinity, // Full width
            child: ElevatedButton(
              onPressed: () {
                _navigateToEditPersonalProfileScreen(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isProfileComplete ? 'Edit' : 'Complete Your Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '(${(profileCompletion * 100).toStringAsFixed(0)}% Complete)',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Navigate to the full-screen edit profile screen
  void _navigateToEditPersonalProfileScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonalProfileScreen(viewModel: viewModel),
      ),
    );
  }
}
