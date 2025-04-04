import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceNotificationsScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceRequestsScreen.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyBottomNav.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyDrawerMenu.dart';

class AmbulanceAgencyMainScreen extends StatefulWidget {
  @override
  _AmbulanceAgencyMainScreenState createState() =>
      _AmbulanceAgencyMainScreenState();
}

class _AmbulanceAgencyMainScreenState extends State<AmbulanceAgencyMainScreen> {
  int _currentIndex = 0; // Track selected tab index
  bool _isSwitchedOn = false; // Switch state for the app bar

  // List of screens for each tab
  final List<Widget> _screens = [
    AmbulanceAgencyDashboardScreen(),
    AmbulanceRequestsScreen(),
    AmbulanceNotificationsScreen(),
    AmbulanceAgencyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ambulance Agency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AmbulanceAgencyColorPalette.textOnDark,
          ),
        ),
        elevation: 0,
        backgroundColor: AmbulanceAgencyColorPalette.accentCyan,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Switch(
              value: _isSwitchedOn,
              onChanged: (bool value) {
                setState(() {
                  _isSwitchedOn = value;
                });
                // Show Toast when switch is toggled
                Fluttertoast.showToast(
                  msg: value ? "Switch ON" : "Switch OFF",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: AmbulanceAgencyColorPalette.secondaryTeal,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              },
              activeColor: AmbulanceAgencyColorPalette.iconActive,
              inactiveThumbColor: AmbulanceAgencyColorPalette.iconInactive,
              inactiveTrackColor: AmbulanceAgencyColorPalette.iconInactive.withOpacity(0.3),
            ),
          ),
        ],
      ),
      drawer: AmbulanceAgencyDrawerMenu(
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index; // Update the selected tab
          });
        },
      ),
      body: _screens[_currentIndex], // Show the screen based on the selected tab
      bottomNavigationBar: AmbulanceAgencyBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (int index) {
          setState(() {
            _currentIndex = index; // Update the selected tab
          });
        },
      ),
    );
  }
}
