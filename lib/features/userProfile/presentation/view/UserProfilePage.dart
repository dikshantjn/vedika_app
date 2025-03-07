import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/MedicalProfileTab/MedicalProfileTab.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileTab.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs for Personal and Medical Profile
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personalViewModel = context.watch<UserPersonalProfileViewModel>();
    final medialViewModel = context.watch<UserMedicalProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0), // Custom height for AppBar
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0), // Position the title down
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          foregroundColor: Colors.white,
          backgroundColor: ColorPalette.primaryColor,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorPalette.primaryColor, Colors.teal.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white, // Active tab indicator color
            labelColor: Colors.white, // Text color for active tab
            unselectedLabelColor: Colors.white70, // Text color for inactive tab
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Tab text style
            tabs: [
              Tab(text: 'Personal Profile'),
              Tab(text: 'Medical Profile'),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding for body content
        child: TabBarView(
          controller: _tabController,
          children: [
            PersonalProfileTab(viewModel: personalViewModel), // Personal Profile Tab
            MedicalProfileTab(viewModel: medialViewModel), // Medical Profile Tab
          ],
        ),
      ),
    );
  }
}
