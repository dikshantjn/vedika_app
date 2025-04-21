import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class DoctorDrawerMenu extends StatelessWidget {
  const DoctorDrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () => _navigateToPage(context, 0),
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Appointments',
                  onTap: () => _navigateToPage(context, 1),
                ),
                _buildDrawerItem(
                  icon: Icons.history_outlined,
                  title: 'History',
                  onTap: () => _navigateToPage(context, 2),
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () => _navigateToPage(context, 3),
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    // TODO: Navigate to settings
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Navigate to help
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    // TODO: Navigate to about
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DoctorConsultationColorPalette.primaryBlue,
            DoctorConsultationColorPalette.primaryBlueDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 37,
              backgroundColor: DoctorConsultationColorPalette.backgroundCard,
              backgroundImage: const AssetImage('assets/images/doctor_profile.png'),
              onBackgroundImageError: (_, __) {},
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dr. John Doe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cardiologist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.successGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: DoctorConsultationColorPalette.successGreen,
              ),
              const SizedBox(width: 4),
              const Text(
                'Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: DoctorConsultationColorPalette.primaryBlue,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: DoctorConsultationColorPalette.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: DoctorConsultationColorPalette.textSecondary,
        size: 18,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      visualDensity: VisualDensity.compact,
      dense: true,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: DoctorConsultationColorPalette.borderLight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: DoctorConsultationColorPalette.errorRed,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: DoctorConsultationColorPalette.errorRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    Navigator.pop(context);
    // Get the TabController from the parent and animate to the selected page
    // This is a simplified approach - in a real app, you might want to use a state management solution
    // or navigation service to handle this more elegantly
    final scaffold = Scaffold.of(context);
    if (scaffold.hasDrawer) {
      // Close the drawer
      Navigator.pop(context);
      // TODO: Navigate to the correct page
      // Simplified approach just for demo purposes
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: DoctorConsultationColorPalette.errorRed,
              ),
              const SizedBox(width: 10),
              const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle logout
                Navigator.pop(context);
                // TODO: Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 