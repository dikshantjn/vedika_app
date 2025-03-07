import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileBody.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileEdit.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileHeader.dart';

class PersonalProfileTab extends StatefulWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileTab({required this.viewModel});

  @override
  _PersonalProfileTabState createState() => _PersonalProfileTabState();
}

class _PersonalProfileTabState extends State<PersonalProfileTab> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchUserProfile(); // Ensure fetchUserProfile is called on init
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonalProfileHeader(viewModel: widget.viewModel),
                SizedBox(height: 16),
                PersonalProfileBody(viewModel: widget.viewModel),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: PersonalProfileEdit(viewModel: widget.viewModel),
          ),
        ),
      ],
    );
  }
}

