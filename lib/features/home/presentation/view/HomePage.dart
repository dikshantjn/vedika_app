import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/BrandSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/CategoryGrid.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/HealthConcernSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/OfferSlider.dart';
import 'package:vedika_healthcare/shared/widgets/BottomNavBar.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/SearchBox.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/MedicalBox.dart'; // Import MedicalBox widget

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Height of the AppBar
        child: ClipPath(
          clipper: _CurvedAppBarClipper(),
          child: Container(
            height: 90.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 28.0), // Move items down
              child: Row(
                children: [
                  // Profile Picture replacing Menu Icon
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer(); // Open drawer when tapped
                        },
                        child: CircleAvatar(
                          radius: 20, // Adjust size as needed
                          backgroundColor: ColorPalette.primaryColor, // Grey background
                          child: Icon(
                            Icons.person, // Person icon
                            size: 24, // Adjust icon size
                            color: Colors.white, // Icon color
                          ),
                        ),
                      );
                    },
                  ),

                  // Location Section (After Profile)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Home text with downward arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Home', // Location type (Home, Office, etc.)
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorPalette.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: ColorPalette.primaryColor,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: ColorPalette.primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '123 Random Street, City', // Random location
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorPalette.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Cart Icon with Light Circular Background
                  // Cart Icon with Badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.primaryColor.withOpacity(0.1), // Light background
                          shape: BoxShape.circle, // Circular shape
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Handle Cart Icon Press
                          },
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: ColorPalette.primaryColor,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red, // Badge background color
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '3', // Replace with cart item count dynamically
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView( // Wrap the entire body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Box
              SearchBox(controller: _searchController),

              MedicalBoxRow(),
              SizedBox(height: 10),  // Space between MedicalBoxes and Slider
              OfferSlider(),  // Add the slider widget here
              HealthConcernSection(), // Add the HealthConcernSection widget
              // Add additional widgets/content here
              CategoryGrid(),
              BrandSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarItemTapped,
      ),
    );
  }
}


class _CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0); // Start from top left corner
    path.lineTo(0, size.height); // Go down the left edge
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.75, size.height); // Create curve
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - 30); // Create curve
    path.lineTo(size.width, 0); // Go up the right edge
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
