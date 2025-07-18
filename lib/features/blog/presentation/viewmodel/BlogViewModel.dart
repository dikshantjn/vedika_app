import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:vedika_healthcare/features/blog/data/services/BlogService.dart';

class BlogViewModel extends ChangeNotifier {
  final BlogService _blogService = BlogService();
  
  List<BlogModel> _blogs = [];
  List<BlogModel> _featuredBlogs = [];
  BlogModel? _selectedBlog;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  // Getters
  List<BlogModel> get blogs => _blogs;
  List<BlogModel> get featuredBlogs => _featuredBlogs;
  BlogModel? get selectedBlog => _selectedBlog;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  // Get filtered blogs based on selected category
  List<BlogModel> get filteredBlogs {
    if (_selectedCategory == 'All') {
      return _blogs;
    }
    return _blogs.where((blog) => blog.category == _selectedCategory).toList();
  }

  // Get unique categories from blogs
  List<String> get categories {
    final categories = _blogs.map((blog) => blog.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  // Load all blogs
  Future<void> loadAllBlogs() async {
    _setLoading(true);
    _clearError();
    
    try {
      _blogs = await _blogService.getAllBlogs();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load blogs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load featured blogs
  Future<void> loadFeaturedBlogs() async {
    try {
      _featuredBlogs = await _blogService.getFeaturedBlogs();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load featured blogs: $e');
    }
  }

  // Load blog by ID
  Future<void> loadBlogById(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      _selectedBlog = await _blogService.getBlogById(id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load blog: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search blogs by category
  Future<void> searchBlogsByCategory(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (category == 'All') {
        _blogs = await _blogService.getAllBlogs();
      } else {
        _blogs = await _blogService.searchBlogsByCategory(category);
      }
      _selectedCategory = category;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search blogs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear selected blog
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

  // Initialize view model
  Future<void> initialize() async {
    await Future.wait([
      loadAllBlogs(),
      loadFeaturedBlogs(),
    ]);
  }
} 