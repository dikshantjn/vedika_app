import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Orders/MedicineOrderPage.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Products/MedicalProductsProductScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Profile/MedicalStoreVendorProfileContent.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/MedicalStoreVendorBottomNav.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/MedicalStoreVendorDashboardContent.dart';
import 'package:vedika_healthcare/shared/Vendors/Widgets/MedicalStoreVendorDrawerMenu.dart';

class VendorMedicalStoreDashBoardScreen extends StatefulWidget {
  @override
  _VendorMedicalStoreDashBoardScreenState createState() =>
      _VendorMedicalStoreDashBoardScreenState();
}

class _VendorMedicalStoreDashBoardScreenState extends State<VendorMedicalStoreDashBoardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalStoreVendorDashboardViewModel>(context, listen: false)
          .fetchVendorStatus();
    });
  }


  final List<Widget> _pages = [
    const DashboardContent(), // Dashboard Page
     MedicineOrderPage(),
     MedicalProductsProductScreen(),
    const Center(child: Text("Returns Page", style: TextStyle(fontSize: 24))),
    MedicalStoreVendorProfileContent(), // Profile Page
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
        title: _buildAppBarTitle(),
        backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [_buildAppBarActions()],
      ),
      body: _pages[_currentIndex], // Body content will switch based on the selected page index
      bottomNavigationBar: MedicalStoreVendorBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        isSpecialPage: _currentIndex >= 5,
      ),
    );
  }

  Widget _buildAppBarTitle() {
    // Change the AppBar title based on the selected page index
    switch (_currentIndex) {
      case 0:
        return const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      case 1:
        return const Text(
          "Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          "Products",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      case 3:
        return const Text(
          "Returns",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      case 4:
        return const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      default:
        return const Text(
          "Medical Store",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
    }
  }

  Widget _buildAppBarActions() {
    return Consumer<MedicalStoreVendorDashboardViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          children: [
            Text(
              viewModel.isActive ? "Online" : "Offline",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Switch(
              value: viewModel.isActive, // ✅ This now reflects the correct status
              activeColor: MedicalStoreVendorColorPalette.secondaryColor,
              inactiveThumbColor: Colors.grey,
              onChanged: (value) async {
                await viewModel.toggleVendorStatus();

                // ✅ Show toast message with different background colors
                Fluttertoast.showToast(
                  msg: viewModel.isActive ? "You are now Online" : "You are now Offline",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: viewModel.isActive ? Colors.green : Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}
