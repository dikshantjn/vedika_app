import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';

class MedicalStoreVendorDrawerMenu extends StatelessWidget {
  final Function(int) onItemSelected;

  const MedicalStoreVendorDrawerMenu({Key? key, required this.onItemSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
      child: Column(
        children: [
          // Header Section
          SizedBox(
            width: double.infinity,
            child: Container(
              constraints: const BoxConstraints.expand(height: 180),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MedicalStoreVendorColorPalette.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Consumer<MedicalStoreVendorDashboardViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.store, size: 40, color: MedicalStoreVendorColorPalette.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        viewModel.storeName ?? "Medical Store",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.storeEmail ?? "No Email available",
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.dashboard, "Dashboard", 0),
                _buildDrawerItem(context, Icons.shopping_cart, "Orders", 1),
                _buildDrawerItem(context, Icons.inventory, "Inventory", 2),
                _buildDrawerItem(context, Icons.assignment_return, "Returns", 3),
                _buildDrawerItem(context, Icons.person, "Profile", 4),

                const Divider(),

                _buildDrawerItem(context, Icons.exit_to_app, "Logout", -1, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int index, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? MedicalStoreVendorColorPalette.errorColor : MedicalStoreVendorColorPalette.secondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? MedicalStoreVendorColorPalette.errorColor : MedicalStoreVendorColorPalette.textPrimary,
        ),
      ),
      onTap: () async {
        if (isLogout) {
          // Get the ViewModel instance
          final viewModel = Provider.of<VendorLoginViewModel>(context, listen: false);

          // Call the logout method
          await viewModel.logout();

          // Navigate to Login Page after logout
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        } else {
          onItemSelected(index);
          Navigator.pop(context);
        }
      },
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}
