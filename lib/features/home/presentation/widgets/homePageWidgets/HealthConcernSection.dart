import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HealthConcernColorPalette.dart';

class HealthConcernSection extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"title": "Pregnancy", "image": "assets/health_concern/Pregnancy Icon.png"},
    {"title": "Acne", "image": "assets/health_concern/AcneIcon.png"},
    {"title": "Cold", "image": "assets/health_concern/cold.png"},
    {"title": "Diabetes", "image": "assets/health_concern/Diabetes Icon.png"},
    {"title": "Liver Care", "image": "assets/health_concern/Liver care Icon.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Search by Health Concern",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HealthConcernColorPalette.textDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: HealthConcernColorPalette.primaryBlue,
                ),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: HealthConcernColorPalette.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal scrollable categories
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final gradientColors = HealthConcernColorPalette.getGradientForIndex(index);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      // Category Box
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors[0].withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background Pattern
                            Positioned(
                              right: -8,
                              bottom: -8,
                              child: Icon(
                                Icons.medical_services_outlined,
                                size: 45,
                                color: gradientColors[2].withOpacity(0.15),
                              ),
                            ),
                            // Content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    categories[index]["image"]!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    categories[index]["title"]!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: HealthConcernColorPalette.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
