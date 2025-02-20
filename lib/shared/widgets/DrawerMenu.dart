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
            _buildDrawerItem(context, Icons.medical_services, "Medicine", "/medicine"),
            _buildDrawerItem(context, Icons.science, "Lab Test", "/labTest"),
            _buildDrawerItem(context, Icons.calendar_today, "Book Appointment", "/appointment"),
            _buildDrawerItem(context, Icons.local_hospital, "Blood Bank", "/bloodBank"),
            _buildDrawerItem(context, Icons.local_pharmacy, "Clinic", "/clinic"),
            _buildDrawerItem(context, Icons.business, "Hospital", "/hospital"),
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

  /// **Builds the drawer header with profile info**
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: ColorPalette.primaryColor,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 20), // Moves everything down slightly
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: ColorPalette.primaryColor),
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
                        Navigator.pushNamed(context, '/profile'); // Navigate to Profile
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
