import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyNotificationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceBookingHistroyScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceRequestsScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/EditAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Settings/AmbulanceAgencySettingsScreen.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyBottomNav.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/AmbulanceAgencyDrawerMenu.dart';
import 'package:vedika_healthcare/shared/utils/WrapWithBackHandler.dart';

class AmbulanceAgencyMainScreen extends StatefulWidget {
  @override
  _AmbulanceAgencyMainScreenState createState() =>
      _AmbulanceAgencyMainScreenState();
}

class _AmbulanceAgencyMainScreenState extends State<AmbulanceAgencyMainScreen> {
  int _currentIndex = 0;
  Widget? _specialPage;
  final List<Widget> _screens = [];


  @override
  void initState() {
    super.initState();

    final viewModel = Provider.of<AmbulanceMainViewModel>(context, listen: false);
    viewModel.fetchVendorStatus();

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
    final viewModel = Provider.of<AmbulanceMainViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
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
                  value: viewModel.isActive,
                  onChanged: (bool value) async {
                    await viewModel.toggleVendorStatus();

                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Status Changed',
                        message: viewModel.isActive
                            ? 'You are now ONLINE'
                            : 'You are now OFFLINE',
                        contentType: viewModel.isActive
                            ? ContentType.success
                            : ContentType.warning,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(snackBar);
                  },
                  activeColor: AmbulanceAgencyColorPalette.iconActive,
                  inactiveThumbColor: AmbulanceAgencyColorPalette.iconInactive,
                  inactiveTrackColor: AmbulanceAgencyColorPalette.iconInactive.withOpacity(0.3),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
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
            _openSpecialPage(const AmbulanceAgencySettingsScreen());
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
            _specialPage = null;
          });
        },
      ),
    );
  }
}
