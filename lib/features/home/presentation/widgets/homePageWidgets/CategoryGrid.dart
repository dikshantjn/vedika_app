import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class CategoryGrid extends StatelessWidget {
  // List of categories
  final List<String> categories = [
    "Medicine",
    "Tests",
    "Health Products",
    "Fitness",
    "Skin Care",
    "Baby Care",
    "Ayurveda",
    "Diabetes",
    "Pain Relief",
    "Dental Care",
    "Hair Care",
    "Women's Care",
    "Supplements",
    "Vitamins",
    "Allergy Care",
    "Mental Wellness",
  ];

  // Map to associate category names with their image paths
  final Map<String, String> categoryIcons = {
    "Medicine": "assets/category/Medicine Icon.png",
    "Tests": "assets/category/Tests Icon.png",
    "Health Products": "assets/category/Health Products Icon.png",
    "Fitness": "assets/category/Fitness Icon.png",
    "Skin Care": "assets/category/Skin Care Icon.png",
    "Baby Care": "assets/category/Baby Care Icon.png",
    "Ayurveda": "assets/category/Ayurveda Icon.png",
    "Diabetes": "assets/category/Diabetes Icon.png",
    "Pain Relief": "assets/category/PainRelief Icon.png",
    "Dental Care": "assets/category/Dental Care Icon.png",
    "Hair Care": "assets/category/Hair Care Icon.png",
    "Women's Care": "assets/category/Women Care Icon.png",
    "Supplements": "assets/category/Supplements Icon.png",
    "Vitamins": "assets/category/Vitamins Icon.png",
    "Allergy Care": "assets/category/Allergy Icon.png",
    "Mental Wellness": "assets/category/Mental Wellness Icon.png",
  };

  final String categoryImage = "assets/category/category.png";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100, // Background color
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Popular Categories",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 300, // Adjusted height for larger boxes
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 8 + 1, // Show first 8 categories + "More Categories" button
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                if (index < 8) {
                  return Column(
                    children: [
                      _buildCategoryBox(categories[index]), // Pass the category name
                      SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          categories[index],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: () => _showMoreCategoriesSheet(context),
                    child: Column(
                      children: [
                        _buildMoreCategoriesBox(categories.length - 8),
                        SizedBox(height: 4),
                        Text(
                          "More Categories",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreCategoriesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes bottom sheet full-screen if needed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none, // Allows the close button to be outside the modal
          children: [
            Container(
              padding: EdgeInsets.all(16),
              height: 400, // Adjust height as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "More Categories",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: _buildMoreCategoriesGrid(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -50, // Moves the button above the bottom sheet
              right: 16, // Aligns it to the right
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // Close bottom sheet
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, size: 24, color: Colors.black54),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // GridView for more categories inside the bottom sheet
  Widget _buildMoreCategoriesGrid() {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length - 8, // Show remaining categories
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildCategoryBox(categories[index + 8]), // Pass the category name
            SizedBox(height: 4),
            Flexible(
              child: Text(
                categories[index + 8], // Display remaining categories
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryBox(String categoryName) {
    // Get the image path for the category
    String imagePath = categoryIcons[categoryName] ?? categoryImage;

    return Container(
      height: 60, // Box size
      width: 60,
      decoration: BoxDecoration(
        color: ColorPalette.categoryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildMoreCategoriesBox(int moreCount) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "+$moreCount",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
      ),
    );
  }
}
