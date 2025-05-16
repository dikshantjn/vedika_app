import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/services/ProductPartnerOrderService.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../../../../../core/auth/presentation/viewmodel/AuthViewModel.dart';
import '../viewmodels/ProductPartnerDashboardViewModel.dart';
import '../viewmodels/ProductPartnerProductsViewModel.dart';
import '../viewmodels/ProductPartnerOrdersViewModel.dart';
import '../viewmodels/ProductPartnerProfileViewModel.dart';
import '../viewmodels/ProductPartnerAddProductViewModel.dart';
import 'ProductPartnerDashboardPage.dart';
import 'ProductPartnerProductsPage.dart';
import 'ProductPartnerOrdersPage.dart';
import 'ProductPartnerProfilePage.dart';
import 'ProductPartnerAddProductPage.dart';
import 'ProductPartnerSettingsPage.dart';
import 'ProductPartnerNotificationsPage.dart';
import 'package:dio/dio.dart';

class VendorProductPartnerDashBoardScreen extends StatefulWidget {
  final String vendorId;

  const VendorProductPartnerDashBoardScreen({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<VendorProductPartnerDashBoardScreen> createState() =>
      _VendorProductPartnerDashBoardScreenState();
}

class _VendorProductPartnerDashBoardScreenState
    extends State<VendorProductPartnerDashBoardScreen> {
  int _currentIndex = 0;
  bool _showSettings = false;
  bool _showNotifications = false;
  late List<Widget> _pages;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('VendorProductPartnerDashBoardScreen - Initializing with vendorId: ${widget.vendorId}');
    _initializePages();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialIndex')) {
        setState(() {
          _currentIndex = args['initialIndex'] as int;
        });
      }
    });
  }

  void _initializePages() {
    try {
      print('Initializing pages with vendorId: ${widget.vendorId}');
      if (widget.vendorId.isEmpty) {
        throw Exception('Vendor ID is required');
      }

      _pages = [
        ProductPartnerDashboardPage(
          vendorId: widget.vendorId,
        ),
        const ProductPartnerProductsPage(),
        ProductPartnerOrdersPage(
          vendorId: widget.vendorId,
        ),
        ProductPartnerProfilePage(
          vendorId: widget.vendorId,
        ),
      ];
      
      print('Pages initialized successfully');
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      print('Error initializing pages: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    try {
      print('🔄 Starting logout process...');
      
      if (!mounted) {
        print('❌ Widget not mounted, aborting logout');
        return;
      }
      
      print('🔍 Getting AuthViewModel...');
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel == null) {
        print('❌ AuthViewModel is null');
        throw Exception('AuthViewModel not initialized');
      }
      print('✅ AuthViewModel found');

      print('🚪 Calling logout on AuthViewModel...');
      await authViewModel.logout(context);
      print('✅ Logout successful');
      
      if (!mounted) {
        print('❌ Widget not mounted after logout, cannot navigate');
        return;
      }
      
      print('🔄 Navigating to login screen...');
      Navigator.pushReplacementNamed(context, "/login");
      print('✅ Navigation complete');
      
    } catch (e, stackTrace) {
      print('❌ Error during logout:');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      
      if (!mounted) {
        print('❌ Widget not mounted, cannot show error snackbar');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building VendorProductPartnerDashBoardScreen - Loading: $_isLoading, Error: $_error');
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initializePages();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print('Creating ProductPartnerDashboardViewModel');
            final viewModel = ProductPartnerDashboardViewModel();
            viewModel.fetchDashboardData(widget.vendorId);
            return viewModel;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProductPartnerProductsViewModel()),
        ChangeNotifierProvider(
          create: (_) => ProductPartnerOrdersViewModel(
            ProductPartnerOrderService(Dio()),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ProductPartnerProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ProductPartnerAddProductViewModel()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
          lazy: false, // Initialize immediately
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          backgroundColor: ProductPartnerColorPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                setState(() {
                  _showNotifications = true;
                  _showSettings = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                setState(() {
                  _showSettings = true;
                  _showNotifications = false;
                });
              },
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _showSettings
            ? const ProductPartnerSettingsPage()
            : _showNotifications
                ? const ProductPartnerNotificationsPage()
                : _pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    index: 0,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Products',
                    index: 1,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Orders',
                    index: 2,
                  ),
                  _buildBottomNavItem(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (_showSettings) {
      return 'Settings';
    }
    if (_showNotifications) {
      return 'Notifications';
    }
    
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Products';
      case 2:
        return 'Orders';
      case 3:
        return 'Profile';
      default:
        return 'Product Partner';
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: ProductPartnerColorPalette.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer<ProductPartnerDashboardViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ProductPartnerColorPalette.primary,
                        ProductPartnerColorPalette.primaryDark,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: ProductPartnerColorPalette.background,
                              backgroundImage: viewModel.profilePicture.isNotEmpty
                                  ? NetworkImage(viewModel.profilePicture)
                                  : null,
                              child: viewModel.profilePicture.isEmpty
                                  ? Text(
                                      viewModel.partnerName.isNotEmpty
                                          ? viewModel.partnerName[0].toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ProductPartnerColorPalette.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.partnerName.isNotEmpty
                                      ? viewModel.partnerName
                                      : 'Product Partner',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (viewModel.companyLegalName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    viewModel.companyLegalName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                if (viewModel.email.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    viewModel.email,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: viewModel.isActive 
                                  ? ProductPartnerColorPalette.success
                                  : ProductPartnerColorPalette.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              viewModel.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: ProductPartnerColorPalette.spacing),
            _buildDrawerItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              isSelected: _currentIndex == 0 && !_showSettings && !_showNotifications,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                  _showSettings = false;
                  _showNotifications = false;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              isSelected: _currentIndex == 1 && !_showSettings && !_showNotifications,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                  _showSettings = false;
                  _showNotifications = false;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Orders',
              isSelected: _currentIndex == 2 && !_showSettings && !_showNotifications,
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  _showSettings = false;
                  _showNotifications = false;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              isSelected: _currentIndex == 3 && !_showSettings && !_showNotifications,
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                  _showSettings = false;
                  _showNotifications = false;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(height: ProductPartnerColorPalette.largeSpacing),
            _buildDrawerItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              isSelected: _showNotifications,
              onTap: () {
                setState(() {
                  _showNotifications = true;
                  _showSettings = false;
                });
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              isSelected: _showSettings,
              onTap: () {
                setState(() {
                  _showSettings = true;
                  _showNotifications = false;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(height: ProductPartnerColorPalette.largeSpacing),
            _buildDrawerItem(
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(height: ProductPartnerColorPalette.largeSpacing),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textSecondary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: ProductPartnerColorPalette.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index && !_showSettings && !_showNotifications;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _showSettings = false;
          _showNotifications = false;
        });
      },
      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ProductPartnerColorPalette.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ProductPartnerColorPalette.primary : ProductPartnerColorPalette.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages - These should be implemented in separate files
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Page - Coming Soon'),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Products Page - Coming Soon'),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Orders Page - Coming Soon'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page - Coming Soon'),
    );
  }
} 