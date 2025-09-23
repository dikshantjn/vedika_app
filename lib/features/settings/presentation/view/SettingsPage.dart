import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _marketingEmails = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final scope = MainScreenScope.maybeOf(context);
            if (scope != null) {
              scope.setIndex(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('General'),
          _card(
            children: [
              _tile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                trailing: _chip(text: _language),
                onTap: _showLanguageSheet,
              ),
              _divider(),
              _tile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: _darkMode,
                  activeColor: ColorPalette.primaryColor,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('Notifications'),
          _card(
            children: [
              _tile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Order updates, reminders, offers',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: ColorPalette.primaryColor,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ),
              _divider(),
              _tile(
                icon: Icons.local_offer_outlined,
                title: 'Marketing Emails',
                trailing: Switch(
                  value: _marketingEmails,
                  activeColor: ColorPalette.primaryColor,
                  onChanged: (v) => setState(() => _marketingEmails = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('Privacy & Security'),
          _card(
            children: [
              _tile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              _divider(),
              _tile(
                icon: Icons.security_outlined,
                title: 'Two-Factor Authentication',
                subtitle: 'Add extra security to your account',
                onTap: () {},
              ),
              _divider(),
              _tile(
                icon: Icons.description_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionHeader('App'),
          _card(
            children: [
              _tile(
                icon: Icons.info_outline,
                title: 'About Vedika',
                onTap: () {},
              ),
              _divider(),
              _tile(
                icon: Icons.system_update_alt_outlined,
                title: 'Check for Updates',
                trailing: _chip(text: 'v1.0.0'),
                onTap: () {},
              ),
              _divider(),
              _tile(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with ❤ for better healthcare',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorPalette.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: ColorPalette.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _chip({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: ColorPalette.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languages = ['English', 'Hindi', 'Marathi'];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...languages.map((lang) => RadioListTile<String>(
                    value: lang,
                    groupValue: _language,
                    activeColor: ColorPalette.primaryColor,
                    title: Text(lang),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _language = val);
                        Navigator.pop(context);
                      }
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}


