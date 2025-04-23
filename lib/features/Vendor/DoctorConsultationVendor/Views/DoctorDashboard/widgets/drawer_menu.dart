import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';

class DoctorDrawerMenu extends StatelessWidget {
  const DoctorDrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          _buildDrawerHeader(context),
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

  Widget _buildDrawerHeader(BuildContext context) {
    // Get the dashboard view model for online status
    final dashboardViewModel = Provider.of<DashboardViewModel>(context);
    
    // Get the profile view model for doctor information
    final profileViewModel = Provider.of<DoctorClinicProfileViewModel>(context);
    final profile = profileViewModel.profile;
    
    // If profile is loading or null, show a placeholder
    if (profileViewModel.isLoading || profile == null) {
      return _buildLoadingDrawerHeader(dashboardViewModel.isOnline);
    }
    
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
          // Profile picture with online/offline indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: profile.profilePicture.isNotEmpty
                  ? CircleAvatar(
                      radius: 37,
                      backgroundImage: NetworkImage(profile.profilePicture),
                    )
                  : CircleAvatar(
                      radius: 37,
                      backgroundColor: DoctorConsultationColorPalette.backgroundCard,
                      child: Text(
                        profile.doctorName.isNotEmpty ? profile.doctorName[0].toUpperCase() : 'D',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                      ),
                    ),
              ),
              // Online/Offline indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: dashboardViewModel.isOnline
                          ? DoctorConsultationColorPalette.successGreen
                          : DoctorConsultationColorPalette.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Doctor name
          Text(
            '${profile.doctorName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Specializations and education qualifications
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Show first specialization if available
              if (profile.specializations.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.specializations.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              // Show first education qualification if available
              if (profile.educationalQualifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.educationalQualifications.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Online/offline status
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: dashboardViewModel.isOnline
                    ? DoctorConsultationColorPalette.successGreen
                    : DoctorConsultationColorPalette.errorRed,
              ),
              const SizedBox(width: 4),
              Text(
                dashboardViewModel.isOnline ? 'Online' : 'Offline',
                style: const TextStyle(
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
  
  // Placeholder header when profile is loading
  Widget _buildLoadingDrawerHeader(bool isOnline) {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 37,
                  backgroundColor: DoctorConsultationColorPalette.backgroundCard,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? DoctorConsultationColorPalette.successGreen
                          : DoctorConsultationColorPalette.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 150,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: isOnline
                    ? DoctorConsultationColorPalette.successGreen
                    : DoctorConsultationColorPalette.errorRed,
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: const TextStyle(
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
        onTap: () {
          // Show a loading indicator before closing the drawer
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          
          // Get the login view model
          final loginViewModel = Provider.of<VendorLoginViewModel>(context, listen: false);
          
          // Perform logout
          loginViewModel.logout().then((_) {
            // Navigate to login screen
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }).catchError((error) {
            // If there's an error, pop the loading dialog and show the drawer again
            Navigator.pop(context); // Pop loading dialog
            
            // Show error dialog instead of using ScaffoldMessenger
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout Error'),
                content: Text('Failed to logout: $error'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        },
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
} 