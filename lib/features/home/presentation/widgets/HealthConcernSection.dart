import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HealthConcernColorPalette.dart';

class HealthConcernSection extends StatelessWidget {
  final List<Map<String, String>> categories = [
  {"title": "Pregnancy", "image": "assets/health_concern/offer.png"},
  {"title": "Acne", "image": "assets/health_concern/offer.png"},
  {"title": "Cold", "image": "assets/health_concern/offer.png"},
  {"title": "Diabetes", "image": "assets/health_concern/offer.png"},
  {"title": "Live Care", "image": "assets/health_concern/offer.png"},
];


@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Search by Health Concern",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text("View All", style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
            ],
          ),

          // Horizontal scrollable categories
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      // Dotted Border Box
                      DottedBorder(
                        color: Colors.grey,
                        strokeWidth: 1.5,
                        dashPattern: [5, 5],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(10),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: HealthConcernColorPalette.colors[index % HealthConcernColorPalette.colors.length], // Use color palette
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Image.asset(
                              categories[index]["image"]!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),

                      // Category name below the box
                      Text(
                        categories[index]["title"]!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
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
