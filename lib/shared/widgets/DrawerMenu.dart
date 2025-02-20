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
          _buildHeader(),
          _buildSubscriptionSection(),
          Divider(),
          _buildSection([
            _buildDrawerItem(Icons.medical_services, "Medicine"),
            _buildDrawerItem(Icons.science, "Lab Test"),
            _buildDrawerItem(Icons.calendar_today, "Book Appointment"),
            _buildDrawerItem(Icons.local_hospital, "Blood Bank"),
            _buildDrawerItem(Icons.local_pharmacy, "Clinic"),
            _buildDrawerItem(Icons.business, "Hospital"),
          ]),
          Divider(),
          _buildSection([
            _buildDrawerItem(Icons.storefront, "Are You a Vendor?"),
            _buildDrawerItem(Icons.settings, "Settings"),
            _buildDrawerItem(Icons.help, "Help Center"),
            _buildDrawerItem(Icons.article, "Terms & Conditions"),
          ]),
        ],
      ),
    );
  }

  /// **Builds the drawer header with profile info**
  Widget _buildHeader() {
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
                      onTap: () {}, // Add navigation action
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
  Widget _buildSubscriptionSection() {
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
      onTap: () {}, // Add action
    );
  }

  /// **Builds individual drawer items**
  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: ColorPalette.primaryColor),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Added arrow icon
      onTap: () {}, // Add navigation action
    );
  }

  /// **Groups multiple drawer items together**
  Widget _buildSection(List<Widget> items) {
    return Column(children: items);
  }
}
