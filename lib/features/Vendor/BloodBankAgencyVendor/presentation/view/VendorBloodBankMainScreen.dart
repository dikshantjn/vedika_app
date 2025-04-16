import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodAvailabilityScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankAgencyProfileScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankRequestScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/VendorBloodBankDashBoardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/VendorBloodBankMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';

class VendorBloodBankMainScreen extends StatefulWidget {

  const VendorBloodBankMainScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<VendorBloodBankMainScreen> createState() => _VendorBloodBankMainScreenState();
}

class _VendorBloodBankMainScreenState extends State<VendorBloodBankMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];
  final Map<String, Widget> _screenCache = {};
  late final VendorBloodBankMainViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VendorBloodBankMainViewModel();
    _initializeScreens();
    
    // Check for initialTab argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialTab')) {
        setState(() {
          _currentIndex = args['initialTab'] as int;
        });
      }
      _viewModel.initializeServiceStatus();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _initializeScreens() {
    // Initialize screens with caching
    _screens.add(_getCachedScreen('dashboard', const VendorBloodBankDashBoardScreen()));
    _screens.add(_getCachedScreen('availability', const BloodAvailabilityScreen()));
    _screens.add(_getCachedScreen('requests', const BloodBankRequestScreen()));
    _screens.add(_getCachedScreen('bookings', const BloodBankBookingScreen()));
    _screens.add(_getCachedScreen('profile', const BloodBankAgencyProfileScreen()));
  }

  Widget _getCachedScreen(String key, Widget screen) {
    if (!_screenCache.containsKey(key)) {
      _screenCache[key] = screen;
    }
    return _screenCache[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VendorBloodBankMainViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${viewModel.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.initializeServiceStatus(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          String getAppBarTitle() {
            switch (_currentIndex) {
              case 0:
                return 'Dashboard';
              case 1:
                return 'Blood Availability';
              case 2:
                return 'Blood Requests';
              case 3:
                return 'Bookings';
              case 4:
                return 'Profile';
              default:
                return 'Blood Bank Agency';
            }
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                getAppBarTitle(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              actions: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        viewModel.isServiceActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: viewModel.isServiceActive 
                              ? Colors.green 
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Switch(
                          value: viewModel.isServiceActive,
                          onChanged: viewModel.isToggling
                              ? null
                              : (value) => viewModel.toggleServiceStatus(),
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green.withOpacity(0.3),
                        ),
                        if (viewModel.isToggling)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
            drawer: Drawer(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.bloodtype,
                                size: 30,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Blood Bank Agency',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your blood bank services',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => _handleDrawerItemTap(0),
                    isSelected: _currentIndex == 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.bloodtype,
                    title: 'Blood Availability',
                    onTap: () => _handleDrawerItemTap(1),
                    isSelected: _currentIndex == 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_active,
                    title: 'Live Requests',
                    onTap: () => _handleDrawerItemTap(2),
                    isSelected: _currentIndex == 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'Booking History',
                    onTap: () => _handleDrawerItemTap(3),
                    isSelected: _currentIndex == 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'Insights & Reports',
                    onTap: () {
                      // TODO: Navigate to analytics screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.edit,
                    title: 'Edit Agency Info',
                    onTap: () => _handleDrawerItemTap(4),
                    isSelected: _currentIndex == 4,
                  ),
                  _buildDrawerItem(
                    icon: Icons.access_time,
                    title: 'Service Hours',
                    onTap: () {
                      // TODO: Navigate to service hours screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Navigate to notifications screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.support_agent,
                    title: 'Admin Support',
                    onTap: () {
                      // TODO: Navigate to support screen
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      // Close the drawer first
                      Navigator.pop(context);
                      

                      if (context.mounted) {
                        try {
                          final loginViewModel = Provider.of<VendorLoginViewModel>(context, listen: false);
                          await loginViewModel.logout();
                          
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error during logout. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_currentIndex],
            ),
            bottomNavigationBar: Container(
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                          _buildNavItem(Icons.bloodtype, 'Availability', 1),
                          _buildNavItem(Icons.notifications_active, 'Requests', 2),
                          _buildNavItem(Icons.history, 'Bookings', 3),
                          _buildNavItem(Icons.person, 'Profile', 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleDrawerItemTap(int index) {
    setState(() => _currentIndex = index);
    Navigator.pop(context);
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

