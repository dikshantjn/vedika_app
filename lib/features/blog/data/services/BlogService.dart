import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class BlogService {
  static const String baseUrl = 'https://api.vedikahealthcare.com'; // Replace with your actual API base URL
  
  // Fetch all blogs from the new API
  Future<List<BlogModel>> fetchAllBlogs() async {
    try {
      print('[BlogService] Fetching all blogs from: ' + ApiEndpoints.blogPosts);
      final response = await http.get(
        Uri.parse(ApiEndpoints.blogPosts),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true && data['posts'] is List) {
          return (data['posts'] as List).map((e) => BlogModel.fromJson(e)).toList();
        } else {
          print('[BlogService] API response does not contain posts.');
          return [];
        }
      } else {
        print('[BlogService] Failed to load blogs, status: ' + response.statusCode.toString());
        throw Exception('Failed to load blogs');
      }
    } catch (e) {
      print('[BlogService] Exception: ' + e.toString());
      return [];
    }
  }

  // Mock data for development
  List<BlogModel> _getMockBlogs() {
    return [
      BlogModel(
        blogPostId: '1',
        title: 'Sample Blog 1',
        message: '<h1>Sample Blog 1</h1><p>This is a sample blog post.</p>',
        link: 'https://example.com/blog1',
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=300&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        postedToFacebook: false,
        postedToLinkedIn: false,
        postedToBlogger: false,
      ),
      BlogModel(
        blogPostId: '2',
        title: 'Sample Blog 2',
        message: '<h1>Sample Blog 2</h1><p>This is another sample blog post.</p>',
        link: 'https://example.com/blog2',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        postedToFacebook: false,
        postedToLinkedIn: false,
        postedToBlogger: false,
      ),
    ];
  }
} 