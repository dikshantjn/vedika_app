import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class CategoryGrid extends StatefulWidget {
  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.category,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Popular Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showMoreCategoriesSheet(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.teal,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          Container(
            height: 120,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  setState(() {
                    _isScrolling = true;
                  });
                } else if (scrollNotification is ScrollEndNotification) {
                  setState(() {
                    _isScrolling = false;
                  });
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    margin: EdgeInsets.only(right: 16),
                    child: _buildCategoryItem(categories[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String categoryName) {
    // Define a map of colors for different categories
    final Map<String, Color> categoryColors = {
      "Medicine": Color(0xFFE3F2FD),
      "Tests": Color(0xFFE8F5E9),
      "Health Products": Color(0xFFFFF3E0),
      "Fitness": Color(0xFFF3E5F5),
      "Skin Care": Color(0xFFFCE4EC),
      "Baby Care": Color(0xFFE0F7FA),
      "Ayurveda": Color(0xFFE8F5E9),
      "Diabetes": Color(0xFFFFEBEE),
      "Pain Relief": Color(0xFFE3F2FD),
      "Dental Care": Color(0xFFE0F7FA),
      "Hair Care": Color(0xFFF3E5F5),
      "Women's Care": Color(0xFFFCE4EC),
      "Supplements": Color(0xFFFFF3E0),
      "Vitamins": Color(0xFFE8F5E9),
      "Allergy Care": Color(0xFFE3F2FD),
      "Mental Wellness": Color(0xFFF3E5F5),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: categoryColors[categoryName] ?? Color(0xFFE3F2FD),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (categoryColors[categoryName] ?? Color(0xFFE3F2FD)).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                categoryIcons[categoryName] ?? categoryImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              categoryName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreCategoriesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "All Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(categories[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
