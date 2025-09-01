import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/NewOrders/NewOrdersScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Orders/MedicineOrderPage.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Products/MedicalProductsProductScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Profile/MedicalStoreVendorProfileContent.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/MedicalStoreVendorBottomNav.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/MedicalStoreVendorDashboardContent.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/MedicalStoreVendorDrawerMenu.dart';

class VendorMedicalStoreDashBoardScreen extends StatefulWidget {
  final int? initialIndex;

  const VendorMedicalStoreDashBoardScreen({
    Key? key,
    this.initialIndex,
  }) : super(key: key);

  @override
  _VendorMedicalStoreDashBoardScreenState createState() =>
      _VendorMedicalStoreDashBoardScreenState();
}

class _VendorMedicalStoreDashBoardScreenState extends State<VendorMedicalStoreDashBoardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set initial index from widget parameter
    if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalStoreVendorDashboardViewModel>(context, listen: false)
          .fetchVendorStatus();
    });
  }

  final List<Widget> _pages = [
    const DashboardContent(),
    // MedicineOrderPage(),
    NewOrdersScreen(),
    MedicalProductsProductScreen(),
    const Center(child: Text("Returns Page", style: TextStyle(fontSize: 24))),
    MedicalStoreVendorProfileContent(),
  ];

  final List<Widget> _specialPages = [
    const Center(child: Text("Reports & Analytics", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Settings Page", style: TextStyle(fontSize: 24))),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
      drawer: MedicalStoreVendorDrawerMenu(onItemSelected: _onTabSelected),
      appBar: AppBar(
        elevation: 0,
        title: _buildAppBarTitle(),
        backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [_buildAppBarActions()],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: MedicalStoreVendorBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        isSpecialPage: _currentIndex >= 5,
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Text(
      _getPageTitle(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Orders";
      case 2:
        return "Products";
      case 3:
        return "Returns";
      case 4:
        return "Profile";
      default:
        return "Medical Store";
    }
  }

  Widget _buildAppBarActions() {
    return Consumer<MedicalStoreVendorDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              // Status Button
              InkWell(
                onTap: () => viewModel.setStatus(!viewModel.isActive),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: viewModel.isActive 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: viewModel.isActive 
                          ? MedicalStoreVendorColorPalette.successColor
                          : MedicalStoreVendorColorPalette.errorColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: viewModel.isActive 
                              ? MedicalStoreVendorColorPalette.successColor
                              : MedicalStoreVendorColorPalette.errorColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        viewModel.isActive ? "Online" : "Offline",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
