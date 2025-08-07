import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/CategoryViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductListScreen.dart';

class CategoryGrid extends StatefulWidget {
  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToProductList(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA), // Light attractive background
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
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
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.category,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Product Categories",
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
              child: Consumer<CategoryViewModel>(
                builder: (context, categoryViewModel, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categoryViewModel.getAllCategories().length,
                    itemBuilder: (context, index) {
                      final category = categoryViewModel.getCategory(index);
                      return GestureDetector(
                        onTap: () => _navigateToProductList(context, category['name']),
                        child: Container(
                          width: 90,
                          margin: EdgeInsets.only(right: 16),
                          child: _buildCategoryBox(category),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBox(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: category['color'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                category['icon'],
                color: _getIconColor(category['color']),
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              category['name'],
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

  Color _getIconColor(Color backgroundColor) {
    // Return appropriate icon color based on background
    if (backgroundColor == Color(0xFFE3F2FD)) return Color(0xFF1976D2); // Blue
    if (backgroundColor == Color(0xFFE8F5E9)) return Color(0xFF388E3C); // Green
    if (backgroundColor == Color(0xFFFFF3E0)) return Color(0xFFF57C00); // Orange
    if (backgroundColor == Color(0xFFF3E5F5)) return Color(0xFF7B1FA2); // Purple
    if (backgroundColor == Color(0xFFFFEBEE)) return Color(0xFFD32F2F); // Red
    if (backgroundColor == Color(0xFFE0F2F1)) return Color(0xFF00796B); // Teal
    if (backgroundColor == Color(0xFFE8EAF6)) return Color(0xFF3F51B5); // Indigo
    return Colors.teal; // Default
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
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
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
                child: Consumer<CategoryViewModel>(
                  builder: (context, categoryViewModel, child) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categoryViewModel.getAllCategories().length,
                        itemBuilder: (context, index) {
                          final category = categoryViewModel.getCategory(index);
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Close bottom sheet
                              _navigateToProductList(context, category['name']);
                            },
                            child: _buildCategoryBox(category),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
