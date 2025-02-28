import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/BannerSlider.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/BrandSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/CategoryGrid.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/HealthConcernSection.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/SearchBox.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/BottomNavBar.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/features/home/presentation/widgets/homePageWidgets/MedicalBox.dart'; // Import MedicalBox widget

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
  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).fetchAndSaveLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,  // Allows content to extend behind the bottom bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: ClipPath(
          clipper: _CurvedAppBarClipper(),
          child: Container(
            height: 90.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 28.0),
              child: Row(
                children: [
                  // Drawer Icon (Profile)
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: ColorPalette.primaryColor,
                          child: Icon(Icons.person, size: 24, color: Colors.white),
                        ),
                      );
                    },
                  ),

                  // Location Section
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorPalette.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: ColorPalette.primaryColor),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: ColorPalette.primaryColor, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '123 Random Street, City',
                              style: TextStyle(fontSize: 14, color: ColorPalette.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Cart Icon
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/goToCart");
                    },
                    icon: Icon(Icons.shopping_cart_outlined, color: ColorPalette.primaryColor),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '3', // Replace with actual cart item count
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
            ],
              ),
            ),
          ),
        ),
      ),
      drawer: DrawerMenu(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 70), // Prevents content from overlapping the floating bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBox(controller: _searchController),
                MedicalBoxRow(),
                SizedBox(height: 10),
                BannerSlider(),
                HealthConcernSection(),
                CategoryGrid(),
                BrandSection(),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            bottom: -10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onNavBarItemTapped,
              ),
            ),
          ),
        ],
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
