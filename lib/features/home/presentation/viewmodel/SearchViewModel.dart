import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/services/SearchService.dart';

class SearchViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String _currentQuery = '';

  List<Map<String, dynamic>> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String get currentQuery => _currentQuery;

  void search(String query) {
    if (query == _currentQuery) return;
    
    _currentQuery = query;
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    Future.delayed(Duration(milliseconds: 300), () {
      _suggestions = SearchService.getSearchSuggestions(query);
      _isLoading = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    _suggestions = [];
    _currentQuery = '';
    notifyListeners();
  }
} 