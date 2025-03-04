import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class DrawerMenu extends StatelessWidget {
  final colorPalette = ColorPalette();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
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
            _buildDrawerItem(context, Icons.login, "Login", "/login"),
            _buildDrawerItem(context, Icons.app_registration, "Sign Up", "/signUp"),



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

  Widget _buildHeader(BuildContext context) {
    double profileCompletion = 0.50; // Example value

    return Container(
      color: ColorPalette.primaryColor,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20), // Moves everything down slightly
          Row(
            children: [
              // Stack to create circular progress around the avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  // Circular progress indicator (placed behind the avatar)
                  SizedBox(
                    width: 64, // Adjusted size to fit around the avatar
                    height: 64,
                    child: CircularProgressIndicator(
                      value: profileCompletion, // Profile completion value
                      strokeWidth: 5, // Adjusted thickness for better visibility
                      backgroundColor: Colors.white.withOpacity(0.3), // Background color
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Progress color
                    ),
                  ),
                  // Profile Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: ColorPalette.primaryColor),
                  ),
                  // Percentage text positioned at the upper left corner
                  Positioned(
                    top: 0, // Moves it to the upper part
                    left: 0, // Moves it towards the left side
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7), // Background for the percentage text
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: Text(
                        '${(profileCompletion * 100).toStringAsFixed(0)}%', // Show percentage
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
                    Text("Krushna Zarekar",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/userProfile'); // Navigate to Profile
                      },
                      child: Text("View and edit profile",
                          style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ),
                    Text("9% completed",
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10), // Adds more space below profile section
        ],
      ),
    );
  }


  /// **Builds Vedika Plus subscription section**
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
              color: Color(0xFF874292), // Rounded box color
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
      }, // Navigate to Vedika Plus
    );
  }

  /// **Builds individual drawer items with navigation**
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: ColorPalette.primaryColor),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Added arrow icon
      onTap: () {
        Navigator.pushNamed(context, route);
      }, // Navigate to respective screen
    );
  }

  /// **Groups multiple drawer items together**
  Widget _buildSection(BuildContext context, List<Widget> items) {
    return Column(children: items);
  }
}
