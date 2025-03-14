import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HealthConcernColorPalette.dart';

class BrandSection extends StatelessWidget {
  final List<Map<String, String>> brands = [
    {"name": "Cipla", "logo": "assets/brands/Cipla Icon.png"},
    {"name": "Sun Pharma", "logo": "assets/brands/SunPharma Icon.png"},
    {"name": "Dr. Reddy's", "logo": "assets/brands/Dr. Reddys Icon.png"},
    {"name": "Lupin", "logo": "assets/brands/Lupin Icon.jpg"},
    {"name": "Zydus Cadila", "logo": "assets/brands/Zydus Cadila Icon.png"},
    {"name": "Aurobindo Pharma", "logo": "assets/brands/Aurobindo Icon.png"},
    {"name": "Biocon", "logo": "assets/brands/Biocon Icon.png"},
    {"name": "Torrent Pharma", "logo": "assets/brands/Torrent Pharma Icon.png"},
    {"name": "Alkem Labs", "logo": "assets/brands/Alkem Labs Icon.png"},
    {"name": "Glenmark", "logo": "assets/brands/Glenmark Icon.png"},
    {"name": "Wockhardt", "logo": "assets/brands/Wockhardt Icon.png"},
    {"name": "Natco Pharma", "logo": "assets/brands/Natco Icon.png"},
  ];


  @override
  Widget build(BuildContext context) {
    return Container(
      color: HealthConcernColorPalette.lightMint, // Light mint background
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "Search by Brands",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // Grid of Brands (4 columns, 3 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Disable grid scrolling
            itemCount: 12, // Only show first 12 brands
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 items per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1, // Keep items square
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // Circular Brand Logo
                  CircleAvatar(
                    radius: 30, // Adjust size
                    backgroundColor: Colors.grey.shade200, // Light background
                    child: Padding(
                      padding: const EdgeInsets.all(10), // Padding inside circle
                      child: Image.asset(
                        brands[index]["logo"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  // Brand Name
                  Text(
                    brands[index]["name"]!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 15),

          // See All Button (Full width, grey background, border)
          Container(
            width: double.infinity, // Full width
            height: 36, // Reduce height
            decoration: BoxDecoration(
              color: HealthConcernColorPalette.lightMint, // Background color
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black), // Border
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Remove extra padding
                minimumSize: Size(0, 36), // Set minimum height
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap area padding
              ),
              onPressed: () {
                // Implement navigation to all brands page
              },
              child: Text(
                "See All Brands",
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
