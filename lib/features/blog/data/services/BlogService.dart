import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';

class BlogService {
  static const String baseUrl = 'https://api.vedikahealthcare.com'; // Replace with your actual API base URL
  
  // Get all blogs
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/blogs'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load blogs');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockBlogs();
    }
  }

  // Get featured blogs
  Future<List<BlogModel>> getFeaturedBlogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/blogs/featured'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load featured blogs');
      }
    } catch (e) {
      // Return mock featured blogs for development
      return _getMockBlogs().where((blog) => blog.isFeatured).toList();
    }
  }

  // Get blog by ID
  Future<BlogModel?> getBlogById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/blogs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BlogModel.fromJson(data);
      } else {
        throw Exception('Failed to load blog');
      }
    } catch (e) {
      // Return mock blog for development
      final mockBlogs = _getMockBlogs();
      return mockBlogs.firstWhere((blog) => blog.id == id, orElse: () => mockBlogs.first);
    }
  }

  // Search blogs by category
  Future<List<BlogModel>> searchBlogsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/blogs/category/$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search blogs');
      }
    } catch (e) {
      // Return mock blogs filtered by category for development
      return _getMockBlogs().where((blog) => blog.category.toLowerCase() == category.toLowerCase()).toList();
    }
  }

  // Mock data for development
  List<BlogModel> _getMockBlogs() {
    return [
      BlogModel(
        id: '1',
        title: '10 Essential Health Tips for Daily Wellness',
        content: 'Maintaining good health is crucial for a happy and productive life. Here are 10 essential tips that can help you stay healthy and energized throughout the day...',
        author: 'Dr. Sarah Johnson',
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 2)),
        tags: ['Wellness', 'Health Tips', 'Daily Routine'],
        readTime: 5,
        category: 'Wellness',
        isFeatured: true,
      ),
      BlogModel(
        id: '2',
        title: 'Understanding Mental Health: A Complete Guide',
        content: 'Mental health is as important as physical health. This comprehensive guide covers everything you need to know about maintaining good mental health...',
        author: 'Dr. Michael Chen',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 5)),
        tags: ['Mental Health', 'Psychology', 'Wellness'],
        readTime: 8,
        category: 'Mental Health',
        isFeatured: true,
      ),
      BlogModel(
        id: '3',
        title: 'Nutrition Basics: Building a Healthy Diet',
        content: 'A balanced diet is the foundation of good health. Learn about the essential nutrients your body needs and how to incorporate them into your daily meals...',
        author: 'Dr. Emily Rodriguez',
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 7)),
        tags: ['Nutrition', 'Diet', 'Healthy Eating'],
        readTime: 6,
        category: 'Nutrition',
        isFeatured: false,
      ),
      BlogModel(
        id: '4',
        title: 'Exercise and Fitness: Getting Started',
        content: 'Regular exercise is key to maintaining physical and mental health. Discover simple ways to incorporate fitness into your busy lifestyle...',
        author: 'Dr. James Wilson',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 10)),
        tags: ['Fitness', 'Exercise', 'Health'],
        readTime: 7,
        category: 'Fitness',
        isFeatured: false,
      ),
      BlogModel(
        id: '5',
        title: 'Sleep Hygiene: Improving Your Sleep Quality',
        content: 'Quality sleep is essential for overall health and well-being. Learn effective strategies to improve your sleep hygiene and get better rest...',
        author: 'Dr. Lisa Thompson',
        imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2fe2f8d207?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 12)),
        tags: ['Sleep', 'Wellness', 'Health'],
        readTime: 4,
        category: 'Wellness',
        isFeatured: false,
      ),
      BlogModel(
        id: '6',
        title: 'Preventive Healthcare: Why Regular Check-ups Matter',
        content: 'Preventive healthcare can save lives and reduce healthcare costs. Understand the importance of regular check-ups and screenings...',
        author: 'Dr. Robert Davis',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        publishedDate: DateTime.now().subtract(Duration(days: 15)),
        tags: ['Preventive Care', 'Health Check-ups', 'Medical'],
        readTime: 6,
        category: 'Healthcare',
        isFeatured: true,
      ),
    ];
  }
} 