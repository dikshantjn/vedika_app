import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileBody.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileHeader.dart';

class PersonalProfileTab extends StatefulWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileTab({required this.viewModel});

  @override
  _PersonalProfileTabState createState() => _PersonalProfileTabState();
}

class _PersonalProfileTabState extends State<PersonalProfileTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch profile data when the tab is initialized
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    await widget.viewModel.fetchUserProfile();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PersonalProfileHeader(viewModel: widget.viewModel),
        const SizedBox(height: 16),
        PersonalProfileBody(viewModel: widget.viewModel),
      ],
    );
  }
}

