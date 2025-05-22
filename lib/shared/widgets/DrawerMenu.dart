import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final userViewModel = context.read<UserViewModel>();
    final userId = await StorageService.getUserId();
      if (userId != null) {
      await userViewModel.fetchUserDetails(userId);
      }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final notificationViewModel = context.watch<NotificationViewModel>();

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, userViewModel),
          _buildSubscriptionSection(context),
          _buildDivider(),
          _buildSectionTitle("Main Menu"),
          _buildSection(context, [
            _buildDrawerItem(context, Icons.shopping_bag_rounded, "My Orders", "/orderHistory"),
            _buildNotificationItem(context, notificationViewModel),
            _buildDrawerItem(context, Icons.medical_services_rounded, "Health Records", "/healthRecords"),
            _buildDrawerItem(context, Icons.local_shipping_rounded, "Track Order", AppRoutes.trackOrderScreen),
            _buildDrawerItem(context, Icons.logout_rounded, "Logout", "/logout"),
          ]),
          _buildDivider(),
          _buildSectionTitle("More"),
          _buildSection(context, [
            _buildDrawerItem(context, Icons.settings_rounded, "Settings", "/settings"),
            _buildDrawerItem(context, Icons.help_rounded, "Help Center", "/help"),
            _buildDrawerItem(context, Icons.description_rounded, "Terms & Conditions", "/terms"),
          ]),
          SizedBox(height: 20),
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserViewModel userViewModel) {
    List<bool> essentialFields = [
      userViewModel.user?.name?.isNotEmpty ?? false,
      userViewModel.user?.phoneNumber?.isNotEmpty ?? false,
      userViewModel.user?.emailId?.isNotEmpty ?? false,
      userViewModel.user?.dateOfBirth != null,
      userViewModel.user?.gender?.isNotEmpty ?? false,
      userViewModel.user?.bloodGroup?.isNotEmpty ?? false,
      userViewModel.user?.height != null,
      userViewModel.user?.weight != null,
      userViewModel.user?.emergencyContactNumber?.isNotEmpty ?? false,
      userViewModel.user?.location?.isNotEmpty ?? false,
    ];

    int filledEssentialFields = essentialFields.where((isFilled) => isFilled).length;
    double profileCompletion = filledEssentialFields / essentialFields.length;

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, AppRoutes.userProfile);
        _fetchUserDetails();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorPalette.primaryColor,
              ColorPalette.primaryColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: profileCompletion,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                      backgroundColor: Colors.white,
                        child: userViewModel.user?.photo?.isNotEmpty == true
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: userViewModel.user!.photo!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: ColorPalette.primaryColor,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: ColorPalette.primaryColor,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${(profileCompletion * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userViewModel.user?.name?.isNotEmpty ?? false)
                        Text(
                          userViewModel.user!.name!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      if (userViewModel.user?.name?.isNotEmpty ?? false) SizedBox(height: 4),
                        Text(
                          userViewModel.user?.phoneNumber ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(width: 4),
                      Text(
                            "Tap to view profile",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF874292),
            Color(0xFF6B3B7A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF874292).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/vedikaPlus'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_rounded, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
        children: [
                          Text(
                            "Vedika ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
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
                      SizedBox(height: 4),
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
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(8),
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
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationViewModel viewModel) {
    final unreadCount = viewModel.notifications.where((n) => !n.isRead).length;
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_rounded, color: ColorPalette.primaryColor, size: 20),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
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
      title: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
      onTap: () {
        Navigator.pushNamed(context, "/notification");
      },
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> items) {
    return Column(children: items);
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Version 1.0.0",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
