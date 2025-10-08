import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogCategoryModel.dart';
import 'package:vedika_healthcare/features/blog/data/services/BlogService.dart';

class BlogCategoryViewModel extends ChangeNotifier {
  final BlogService _blogService = BlogService();
  
  List<BlogCategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BlogCategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    print('[BlogCategoryViewModel] Loading categories...');
    _setLoading(true);
    _clearError();
    try {
      _categories = await _blogService.fetchBlogCategories();
      print('[BlogCategoryViewModel] Loaded categories: ' + _categories.length.toString());
      notifyListeners();
    } catch (e) {
      print('[BlogCategoryViewModel] Error: ' + e.toString());
      _setError('Failed to load categories: $e');
    } finally {
      print('[BlogCategoryViewModel] Done loading categories.');
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
