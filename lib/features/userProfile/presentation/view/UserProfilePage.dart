import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/MedicalProfileTab/MedicalProfileTab.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/widgets/PersonalProfileTab/PersonalProfileTab.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: Colors.grey[50],
      drawer: DrawerMenu(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorPalette.primaryColor,
                ColorPalette.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'My Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.95),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorColor: Colors.transparent,
                    labelColor: ColorPalette.primaryColor,
                    unselectedLabelColor: Colors.white,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 18),
                            const SizedBox(width: 6),
                            Text('Personal'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text('Medical'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            PersonalProfileTab(viewModel: personalViewModel),
            MedicalProfileTab(viewModel: medialViewModel),
          ],
        ),
      ),
    );
  }
}
