import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/services/CategoryService.dart';

class SearchService {
  // Search suggestions based on categories and services
  static List<Map<String, dynamic>> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];

    final List<Map<String, dynamic>> suggestions = [];
    final String lowercaseQuery = query.toLowerCase();

    // Add service routes as suggestions
    final serviceRoutes = [
      {
        'name': 'Ambulance',
        'route': '/ambulance-search',
        'icon': Icons.emergency,
        'type': 'service'
      },
      {
        'name': 'Blood Bank',
        'route': '/blood-bank',
        'icon': Icons.bloodtype,
        'type': 'service'
      },
      {
        'name': 'Medicine Order',
        'route': '/medicine-order',
        'icon': Icons.medical_services,
        'type': 'service'
      },
      {
        'name': 'Hospital Search',
        'route': '/hospital-search',
        'icon': Icons.local_hospital,
        'type': 'service'
      },
      {
        'name': 'Clinic Search',
        'route': '/clinic-search',
        'icon': Icons.medical_information,
        'type': 'service'
      },
      {
        'name': 'Lab Test',
        'route': '/labTest',
        'icon': Icons.science,
        'type': 'service'
      },
    ];

    // Add matching service routes
    for (var service in serviceRoutes) {
      if (service['name'].toString().toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(service);
      }
    }

    // Add matching categories and their subcategories
    final categories = CategoryService.getAllCategories();
    for (var category in categories) {
      // Check category name
      if (category['name'].toString().toLowerCase().contains(lowercaseQuery)) {
        suggestions.add({
          'name': category['name'],
          'icon': category['icon'],
          'type': 'category',
          'route': '/product-list',
          'params': {
            'category': category['name'],
            'subCategory': null
          }
        });
      }

      // Check subcategories
      for (var subCategory in category['subCategories']) {
        if (subCategory.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add({
            'name': subCategory,
            'icon': category['icon'],
            'type': 'subcategory',
            'parentCategory': category['name'],
            'route': '/product-list',
            'params': {
              'category': category['name'],
              'subCategory': subCategory
            }
          });
        }
      }
    }

    return suggestions;
  }
} 