import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
// import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/pages/appointments_page.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/pages/dashboard_page.dart';
// import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/pages/history_page.dart';
// import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/pages/profile_page.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/drawer_menu.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DashboardViewModel.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  
  // Pages for bottom navigation
  final List<Widget> _pages = [
    const DashboardPage(),
    // Using placeholders for pages that aren't implemented yet
    const Center(child: Text('Appointments Page - Coming Soon')),
    const Center(child: Text('History Page - Coming Soon')),
    const Center(child: Text('Profile Page - Coming Soon')),
  ];
  
  // Titles for app bar
  final List<String> _titles = [
    'Dashboard',
    'Appointments',
    'History',
    'Profile',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..init(),
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: DoctorConsultationColorPalette.primaryBlue,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
              appBar: _buildAppBar(viewModel),
              drawer: const DoctorDrawerMenu(),
              body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                children: _pages,
              ),
              bottomNavigationBar: _buildBottomNavigation(),
              floatingActionButton: _currentIndex == 1 // Show FAB only on Appointments page
                  ? FloatingActionButton(
                      onPressed: () {
                        // TODO: Add new appointment logic
                      },
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(DashboardViewModel viewModel) {
    return AppBar(
      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
      elevation: 0,
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        // Online/Offline Status Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                viewModel.toggleOnlineStatus();
                _showStatusChangeSnackbar(viewModel.isOnline);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: viewModel.isOnline 
                        ? DoctorConsultationColorPalette.successGreen 
                        : DoctorConsultationColorPalette.errorRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      viewModel.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Show notifications
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showStatusChangeSnackbar(bool isOnline) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.check_circle : Icons.error,
              color: isOnline 
                ? DoctorConsultationColorPalette.successGreen 
                : DoctorConsultationColorPalette.errorRed,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                isOnline 
                  ? 'You are now online. Patients can book appointments.' 
                  : 'You are now offline. No new appointments will be scheduled.',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: isOnline 
          ? DoctorConsultationColorPalette.successGreen.withOpacity(0.8) 
          : DoctorConsultationColorPalette.errorRed.withOpacity(0.8),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _tabController.animateTo(index);
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: DoctorConsultationColorPalette.primaryBlue,
          unselectedItemColor: DoctorConsultationColorPalette.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
} 