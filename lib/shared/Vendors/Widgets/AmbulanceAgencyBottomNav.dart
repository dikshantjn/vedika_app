import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';

class AmbulanceAgencyBottomNav extends StatefulWidget {
  final Function(int) onTabSelected;
  final int currentIndex;
  final bool isSpecialPage;

  const AmbulanceAgencyBottomNav({
    Key? key,
    required this.onTabSelected,
    required this.currentIndex,
    this.isSpecialPage = false,
  }) : super(key: key);

  @override
  _AmbulanceAgencyBottomNavState createState() =>
      _AmbulanceAgencyBottomNavState();
}

class _AmbulanceAgencyBottomNavState extends State<AmbulanceAgencyBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AmbulanceAgencyColorPalette.cardWhite,
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
          backgroundColor: AmbulanceAgencyColorPalette.cardWhite,
          currentIndex: widget.currentIndex,
          onTap: widget.onTabSelected,
          selectedItemColor: AmbulanceAgencyColorPalette.primaryRed, // Active icon color
          unselectedItemColor: AmbulanceAgencyColorPalette.iconInactive, // Inactive icon color
          showUnselectedLabels: true,
          elevation: 5,
          items: [
            _buildNavItem(Icons.dashboard, "Dashboard"),
            _buildNavItem(Icons.local_hospital, "Requests"),
            _buildNavItem(Icons.notifications, "Notifications"),
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
}
