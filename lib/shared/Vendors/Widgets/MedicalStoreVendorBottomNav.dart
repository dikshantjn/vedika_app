import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';

class MedicalStoreVendorBottomNav extends StatelessWidget {
  final Function(int) onTabSelected;
  final int currentIndex;
  final bool isSpecialPage; // New parameter to handle special pages
  final int prescriptionCount; // New parameter for prescription count

  const MedicalStoreVendorBottomNav({
    Key? key,
    required this.onTabSelected,
    required this.currentIndex,
    this.isSpecialPage = false, // Default to false
    this.prescriptionCount = 0, // Default to 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme colors

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, // Background remains white
          currentIndex: isSpecialPage ? 0 : currentIndex, // Default to 0 for special pages
          onTap: onTabSelected,
          selectedItemColor: isSpecialPage
              ?  MedicalStoreVendorColorPalette.secondaryColor// Grey out selected color for special pages
              : MedicalStoreVendorColorPalette.primaryColor, // Selected icon color
          unselectedItemColor: MedicalStoreVendorColorPalette.secondaryColor, // Unselected icon color
          showUnselectedLabels: true, // Labels always visible
          elevation: 5,
          items: [
            _buildNavItem(Icons.dashboard, "Dashboard"),
            _buildNavItemWithBadge(Icons.shopping_cart, "Orders", prescriptionCount),
            _buildNavItem(Icons.inventory, "Products"),
            _buildNavItem(Icons.assignment_return, "Returns"),
            _buildNavItem(Icons.person, "Profile"),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 26),
      label: label,
    );
  }

  BottomNavigationBarItem _buildNavItemWithBadge(IconData icon, String label, int count) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(icon, size: 26),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}