import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:vedika_healthcare/features/blog/data/services/BlogService.dart';

class BlogViewModel extends ChangeNotifier {
  final BlogService _blogService = BlogService();
  
  List<BlogModel> _blogs = [];
  BlogModel? _selectedBlog;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BlogModel> get blogs => _blogs;
  BlogModel? get selectedBlog => _selectedBlog;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all blogs
  Future<void> loadAllBlogs() async {
    print('[BlogViewModel] Loading all blogs...');
    _setLoading(true);
    _clearError();
    try {
      _blogs = await _blogService.fetchAllBlogs();
      print('[BlogViewModel] Loaded blogs: ' + _blogs.length.toString());
      notifyListeners();
    } catch (e) {
      print('[BlogViewModel] Error: ' + e.toString());
      _setError('Failed to load blogs: $e');
    } finally {
      print('[BlogViewModel] Done loading.');
      _setLoading(false);
    }
  }

  // Load blogs by category
  Future<void> loadBlogsByCategory(String categoryId) async {
    print('[BlogViewModel] Loading blogs for category: $categoryId');
    _setLoading(true);
    _clearError();
    try {
      _blogs = await _blogService.fetchBlogsByCategory(categoryId);
      print('[BlogViewModel] Loaded blogs for category: ' + _blogs.length.toString());
      notifyListeners();
    } catch (e) {
      print('[BlogViewModel] Error: ' + e.toString());
      _setError('Failed to load blogs for category: $e');
    } finally {
      print('[BlogViewModel] Done loading blogs for category.');
      _setLoading(false);
    }
  }

  void selectBlog(BlogModel blog) {
    _selectedBlog = blog;
    notifyListeners();
  }

  void clearSelectedBlog() {
    _selectedBlog = null;
    notifyListeners();
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