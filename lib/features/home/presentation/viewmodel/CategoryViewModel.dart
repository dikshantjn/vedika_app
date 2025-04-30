import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/services/CategoryService.dart';

class CategoryViewModel extends ChangeNotifier {
  // Get category by index
  Map<String, dynamic> getCategory(int index) {
    return CategoryService.getCategory(index);
  }

  // Get all categories
  List<Map<String, dynamic>> getAllCategories() {
    return CategoryService.getAllCategories();
  }

  // Get subcategories for a category
  List<String> getSubCategories(int categoryIndex) {
    return CategoryService.getSubCategories(categoryIndex);
  }
} 