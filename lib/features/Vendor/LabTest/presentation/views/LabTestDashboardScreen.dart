import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/DiagnosticCenterProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/DiagnosticCenterProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestBookingContentPage.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestDashboardContentPage.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestInsightContentPage.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestNotificationsContentPage.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/MainWidgets/DashboardBottomNav.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/MainWidgets/DashboardDrawer.dart';

class LabTestDashboardScreen extends StatefulWidget {
  final int? initialTab;
  
  const LabTestDashboardScreen({
    super.key,
    this.initialTab,
  });

  @override
  State<LabTestDashboardScreen> createState() => _LabTestDashboardScreenState();
}

class _LabTestDashboardScreenState extends State<LabTestDashboardScreen> {
  int _currentIndex = 0;
  bool _showNotifications = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const LabTestDashboardContentPage(),
    const LabTestBookingContentPage(),
    const LabTestInsightContentPage(),
    const DiagnosticCenterProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab if provided
    if (widget.initialTab != null) {
      _currentIndex = widget.initialTab!;
    }
  }

  String _getAppBarTitle() {
    if (_showNotifications) return 'Notifications';
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Bookings';
      case 2:
        return 'Insights';
      case 3:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  void navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
      _showNotifications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: LabTestColorPalette.backgroundPrimary,
      drawer: DashboardDrawer(
        onNavigate: navigateToPage,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: LabTestColorPalette.textPrimary,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: LabTestColorPalette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: LabTestColorPalette.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showNotifications = !_showNotifications;
              });
            },
          ),
        ],
      ),
      body: _showNotifications
          ? const LabTestNotificationsContentPage()
          : _pages[_currentIndex],
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _showNotifications = false;
          });
        },
      ),
    );
  }
} 