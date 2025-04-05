import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';

class AmbulanceAgencySettingsScreen extends StatelessWidget {
  const AmbulanceAgencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmbulanceAgencyColorPalette.backgroundWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AmbulanceAgencyColorPalette.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSettingItem(
                    icon: Icons.person,
                    title: "Account",
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.lock,
                    title: "Privacy",
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications,
                    title: "Notifications",
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.color_lens,
                    title: "Appearance",
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.info,
                    title: "About",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AmbulanceAgencyColorPalette.secondaryTeal),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
