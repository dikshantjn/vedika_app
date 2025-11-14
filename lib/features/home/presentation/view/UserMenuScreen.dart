import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/viewmodel/CoreNotificationViewModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/VendorRegistrationPage.dart';

class UserMenuScreen extends StatelessWidget {
  const UserMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final userViewModel = context.watch<UserViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Menu',
          style: TextStyle(
            color: ColorPalette.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ColorPalette.primaryColor),
          onPressed: () {
            // Use MainScreenNavigator for safe back behavior within MainScreen
            final didGoBack = MainScreenNavigator.instance.goBack();
            if (!didGoBack) {
              Navigator.maybePop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: ColorPalette.primaryColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.aiChat,
                arguments: {'initialQuery': ''},
              );
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: ColorPalette.primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.newCartScreen);
            },
            tooltip: 'Cart',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, auth, userViewModel),
            const SizedBox(height: 16),
            _buildMembershipBox(context),
            const SizedBox(height: 16),
            _buildMenuList(context),
            const SizedBox(height: 20),
            if (auth.isLoggedIn)
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthViewModel>().logout(context, navigate: false);
                  // Optionally show a confirmation and stay on the same screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out')),
                  );
                },
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorRegistrationPage()),
                );
              },
              icon: Icon(Icons.store_mall_directory_outlined, color: ColorPalette.primaryColor),
              label: Text(
                'Login as Vendor',
                style: TextStyle(color: ColorPalette.primaryColor, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorPalette.primaryColor.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF874292),
            const Color(0xFF6B3B7A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF874292).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.membership),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Vedika ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Plus",
                              style: TextStyle(
                                color: Color(0xFF874292),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Health plan for your family",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final unreadCount = context.watch<CoreNotificationViewModel>().unreadCount;
    final tiles = <Widget>[
      _buildSimpleTile(
        context,
        icon: Icons.shopping_bag_rounded,
        title: "My Orders",
        onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
      ),
      _buildNotificationsTile(context, unreadCount),
      _buildSimpleTile(
        context,
        icon: Icons.medical_services_rounded,
        title: "Health Records",
        onTap: () => Navigator.pushNamed(context, AppRoutes.healthRecords),
      ),
      _buildSimpleTile(
        context,
        icon: Icons.local_shipping_rounded,
        title: "Track Order",
        onTap: () => Navigator.pushNamed(context, AppRoutes.trackOrderScreen),
      ),
      _buildInviteTile(context),
      _buildSimpleTile(
        context,
        icon: Icons.settings_rounded,
        title: "Settings",
        onTap: () => Navigator.pushNamed(context, AppRoutes.settingsPage),
      ),
      _buildSimpleTile(
        context,
        icon: Icons.help_rounded,
        title: "Help Center",
        onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
      ),
      _buildSimpleTile(
        context,
        icon: Icons.description_rounded,
        title: "Terms & Conditions",
        onTap: () => Navigator.pushNamed(context, '/terms'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorPalette.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: ColorPalette.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
    }

  Widget _buildNotificationsTile(BuildContext context, int unreadCount) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_rounded, color: ColorPalette.primaryColor, size: 20),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
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
      title: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
      onTap: () => Navigator.pushNamed(context, AppRoutes.notification),
    );
  }

  Widget _buildInviteTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorPalette.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.share_rounded, color: ColorPalette.primaryColor, size: 20),
      ),
      title: Text(
        "Invite Friends",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
      onTap: () async {
        const String appLink = "https://play.google.com/store/apps/details?id=com.vedika.healthcare";
        const String appName = "Vedika Healthcare";
        const String message = """Hey! I've been using $appName and it's been amazing for managing my health needs. 

📱 Download the app here: $appLink

✨ Features:
• Order medicines online
• Consult with doctors
• Track health records
• Get health insights
• And much more!

Join me on Vedika Healthcare for better health management! 🏥""";
        await Share.share(message, subject: 'Join me on $appName');
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthViewModel auth, UserViewModel userViewModel) {
    final isLoggedIn = auth.isLoggedIn;
    final name = isLoggedIn ? (userViewModel.user?.name ?? 'User') : 'Guest';
    final phone = isLoggedIn ? (userViewModel.user?.phoneNumber ?? '') : '';
    final email = isLoggedIn ? (userViewModel.user?.emailId ?? '') : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                ),
                child: Icon(Icons.person, color: ColorPalette.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isLoggedIn && (phone.isNotEmpty || email.isNotEmpty))
                      Row(
                        children: [
                          if (phone.isNotEmpty) ...[
                            Text(
                              phone,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                          if (phone.isNotEmpty && email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (email.isNotEmpty)
                            Expanded(
                              child: Text(
                                email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    if (!isLoggedIn)
                      Text(
                        'Sign in to sync your health experience',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Always navigate to userProfile; AuthGuard will gate and open login if needed
                  Navigator.pushNamed(context, AppRoutes.userProfile);
                },
                child: Text(
                  isLoggedIn ? 'Edit' : 'Login',
                  style: TextStyle(
                    color: ColorPalette.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthViewModel auth) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            color: Colors.deepPurple,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.notification);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.favorite_outline,
            title: 'Membership',
            color: Colors.pink,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.membership);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: ColorPalette.primaryColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: ColorPalette.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      dense: true,
    );
  }
}


