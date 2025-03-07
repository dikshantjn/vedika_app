import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class DrawerMenu extends StatefulWidget {

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();

    // Fetch the user details when the DrawerMenu is initialized
    final userViewModel = context.read<UserViewModel>();

    // Retrieve the user ID asynchronously
    StorageService.getUserId().then((userId) {
      if (userId != null) {
        userViewModel.fetchUserDetails(userId);
      } else {
        // Handle case where userId is null (e.g., user not logged in)
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, userViewModel),
          _buildSubscriptionSection(context),
          Divider(),
          _buildSection(context, [
            _buildDrawerItem(context, Icons.local_hospital, "Blood Bank", "/bloodBank"),
            _buildDrawerItem(context, Icons.medical_services, "Medicine", "/medicine"),
            _buildDrawerItem(context, Icons.business, "Hospital", "/hospital"),
            _buildDrawerItem(context, Icons.local_pharmacy, "Clinic", "/clinic"),
            _buildDrawerItem(context, Icons.science, "Lab Test", "/labTest"),
            _buildDrawerItem(context, Icons.history, "Order History", "/orderHistory"),
            _buildDrawerItem(context, Icons.notification_important, "Notification/Remainder", "/notification"),
            _buildDrawerItem(context, Icons.receipt, "Health Records", "/healthRecords"),
            _buildDrawerItem(context, Icons.logout, "Logout", "/logout"),
          ]),
          Divider(),
          _buildSection(context, [
            _buildDrawerItem(context, Icons.storefront, "Are You a Vendor?", "/vendor"),
            _buildDrawerItem(context, Icons.settings, "Settings", "/settings"),
            _buildDrawerItem(context, Icons.help, "Help Center", "/help"),
            _buildDrawerItem(context, Icons.article, "Terms & Conditions", "/terms"),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserViewModel userViewModel) {
    List<bool> requiredFields = [
      userViewModel.user?.name?.isNotEmpty ?? false,
      userViewModel.user?.phoneNumber?.isNotEmpty ?? false,
      userViewModel.user?.abhaId?.isNotEmpty ?? false,
      userViewModel.user?.emailId?.isNotEmpty ?? false,
      userViewModel.user?.dateOfBirth != null,
      userViewModel.user?.gender?.isNotEmpty ?? false,
      userViewModel.user?.bloodGroup?.isNotEmpty ?? false,
      userViewModel.user?.height != null,
      userViewModel.user?.weight != null,
      userViewModel.user?.emergencyContactNumber?.isNotEmpty ?? false,
      userViewModel.user?.location?.isNotEmpty ?? false,
      userViewModel.user?.city?.isNotEmpty ?? false,
    ];

    int filledFields = requiredFields.where((isFilled) => isFilled).length;
    double profileCompletion = filledFields / requiredFields.length;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.userProfile);
      },
      child: Container(
        color: ColorPalette.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 20),
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
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: ColorPalette.primaryColor),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(profileCompletion * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userViewModel.user?.name?.isNotEmpty ?? false)
                        Text(
                          userViewModel.user!.name!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      if (userViewModel.user?.name?.isNotEmpty ?? false) SizedBox(height: 4),
                      if (!(userViewModel.user?.name?.isNotEmpty ?? false))
                        Text(
                          userViewModel.user?.phoneNumber ?? '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      if (!(userViewModel.user?.name?.isNotEmpty ?? false)) SizedBox(height: 4),
                      Text(
                        "View and edit profile",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${(profileCompletion * 100).toStringAsFixed(0)}% completed",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }





  Widget _buildSubscriptionSection(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[200],
      leading: Icon(Icons.star, color: ColorPalette.primaryColor),
      title: Row(
        children: [
          Text("Vedika "),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFF874292),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Plus",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      subtitle: Text("Health plan for your family"),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, '/vedikaPlus');
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: ColorPalette.primaryColor),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> items) {
    return Column(children: items);
  }
}
