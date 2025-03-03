import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';
import 'package:vedika_healthcare/features/Profile/presentation/widgets/PersonalProfileTab/PersonalProfileBody.dart';
import 'package:vedika_healthcare/features/Profile/presentation/widgets/PersonalProfileTab/PersonalProfileDelete.dart';
import 'package:vedika_healthcare/features/Profile/presentation/widgets/PersonalProfileTab/PersonalProfileEdit.dart';
import 'package:vedika_healthcare/features/Profile/presentation/widgets/PersonalProfileTab/PersonalProfileHeader.dart';

class PersonalProfileTab extends StatelessWidget {
  final UserProfileViewModel viewModel;

  PersonalProfileTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content of the profile
        ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonalProfileHeader(viewModel: viewModel),
                SizedBox(height: 16),
                PersonalProfileBody(viewModel: viewModel),
              ],
            ),
          ],
        ),

        // Edit button positioned at the bottom center
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: PersonalProfileEdit(viewModel: viewModel),
          ),
        ),
      ],
    );
  }
}
