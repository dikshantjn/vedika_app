import 'package:flutter/material.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';

class ProductPartnerSettingsPage extends StatelessWidget {
  const ProductPartnerSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProductPartnerColorPalette.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Account Settings',
              children: [
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: 'Profile Settings',
                  subtitle: 'Manage your profile information',
                  onTap: () {
                    // Navigate to profile settings
                  },
                ),
                _buildSettingTile(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'Password and security settings',
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                _buildSettingTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification Preferences',
                  subtitle: 'Manage notification settings',
                  onTap: () {
                    // Navigate to notification preferences
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Business Settings',
              children: [
                _buildSettingTile(
                  icon: Icons.business_outlined,
                  title: 'Business Information',
                  subtitle: 'Update business details',
                  onTap: () {
                    // Navigate to business information
                  },
                ),
                _buildSettingTile(
                  icon: Icons.payment_outlined,
                  title: 'Payment Settings',
                  subtitle: 'Manage payment methods and preferences',
                  onTap: () {
                    // Navigate to payment settings
                  },
                ),
                _buildSettingTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory Settings',
                  subtitle: 'Configure inventory management',
                  onTap: () {
                    // Navigate to inventory settings
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'App Settings',
              children: [
                _buildSettingTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Change app language',
                  onTap: () {
                    // Show language selection dialog
                  },
                ),
                _buildSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  subtitle: 'Change app theme',
                  onTap: () {
                    // Show theme selection dialog
                  },
                ),
                _buildSettingTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    // Show about dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ProductPartnerColorPalette.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: ProductPartnerColorPalette.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
} 