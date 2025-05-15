import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';

class ProductService {
  final Dio _dio = Dio();

  // Get products by category
  Future<List<VendorProduct>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getProductsByCategory}/$category');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => VendorProduct.fromJson(json)).toList();
      } else {
        print('Error fetching products by category: Status code ${response.statusCode}');
        print('Response data: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('DioException in getProductsByCategory:');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Error response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Unexpected error in getProductsByCategory: $e');
      return [];
    }
  }

  // Get products by subcategory
  Future<List<VendorProduct>> getProductsBySubCategory(String subCategory) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getProductsByCategory}/$subCategory');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => VendorProduct.fromJson(json)).toList();
      } else {
        print('Error fetching products by subcategory: Status code ${response.statusCode}');
        print('Response data: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('DioException in getProductsBySubCategory:');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Error response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Unexpected error in getProductsBySubCategory: $e');
      return [];
    }
  }

  // Get product by ID
  Future<VendorProduct?> getProductById(String id) async {
    try {
      if (id.isEmpty) {
        print('Error: Empty product ID provided');
        return null;
      }

      final response = await _dio.get('${ApiEndpoints.getVendorProduct}/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          print('Error: No data received from API');
          return null;
        }

        try {
          // Check if the response has a nested 'product' field
          if (data is Map<String, dynamic> && data.containsKey('product')) {
            final productData = data['product'];
            if (productData != null) {
              return VendorProduct.fromJson(productData);
            }
          }
          // If no nested structure, try parsing the data directly
          return VendorProduct.fromJson(data);
        } catch (e) {
          print('Error parsing product data: $e');
          print('Raw data: $data');
          return null;
        }
      } else {
        print('Error fetching product by ID: Status code ${response.statusCode}');
        print('Response data: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      print('DioException in getProductById:');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Error response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error in getProductById: $e');
      return null;
    }
  }

  // Search products
  Future<List<VendorProduct>> searchProducts(String query) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getVendorProducts}?search=$query');
      
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => VendorProduct.fromJson(json)).toList();
      } else {
        print('Error searching products: Status code ${response.statusCode}');
        print('Response data: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('DioException in searchProducts:');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Error response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Unexpected error in searchProducts: $e');
      return [];
    }
  }
} 