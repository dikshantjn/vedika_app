import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceBookingHistroyScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceRequestsScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/EditAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Settings/AmbulanceAgencySettingsScreen.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyBottomNav.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyDrawerMenu.dart';
import 'package:vedika_healthcare/shared/utils/WrapWithBackHandler.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyNotificationScreen.dart'; // Import new notification screen

class AmbulanceAgencyMainScreen extends StatefulWidget {
  @override
  _AmbulanceAgencyMainScreenState createState() =>
      _AmbulanceAgencyMainScreenState();
}

class _AmbulanceAgencyMainScreenState extends State<AmbulanceAgencyMainScreen> {
  int _currentIndex = 0;
  bool _isSwitchedOn = false;

  Widget? _specialPage; // 🔥 Special overlay page (like edit, settings etc.)

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    _screens.addAll([
      AmbulanceAgencyDashboardScreen(),
      AmbulanceRequestsScreen(),
      AmbulanceBookingHistoryScreen(),
      AmbulanceAgencyProfileScreen(
        onEditPressed: () => _openSpecialPage(const EditAgencyProfileScreen()),
      ),
    ]);
  }

  void _openSpecialPage(Widget page) {
    setState(() {
      _specialPage = page;
    });
  }

  void _closeSpecialPage() {
    setState(() {
      _specialPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ambulance',
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
            child: Row(
              children: [
                Switch(
                  value: _isSwitchedOn,
                  onChanged: (bool value) {
                    setState(() {
                      _isSwitchedOn = value;
                    });
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
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    _openSpecialPage(AmbulanceAgencyNotificationScreen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: AmbulanceAgencyDrawerMenu(
        onItemSelected: (index) {
          if (index <= 3) {
            setState(() {
              _currentIndex = index;
              _specialPage = null;
            });
          } else if (index == 4) {
            // Settings screen logic
            _openSpecialPage(const AmbulanceAgencySettingsScreen()); // <- use your actual settings screen here
          }
        },
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
          if (_specialPage != null)
            Positioned.fill(
              child: WrapWithBackHandler(
                child: _specialPage!,
                onClose: _closeSpecialPage,
              ),
            ),
        ],
      ),
      bottomNavigationBar: AmbulanceAgencyBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (int index) {
          setState(() {
            _currentIndex = index;
            _specialPage = null; // 👈 Close special page if open
          });
        },
      ),
    );
  }
}
