import 'package:dio/dio.dart';
import '../../../../../core/constants/ApiEndpoints.dart';
import '../models/VendorProduct.dart';

class ProductPartnerProductService {
  final Dio _dio = Dio();

  // Singleton pattern
  static final ProductPartnerProductService _instance = ProductPartnerProductService._internal();
  factory ProductPartnerProductService() => _instance;
  ProductPartnerProductService._internal();

  Future<List<VendorProduct>> getVendorProducts(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getVendorProducts}/$vendorId',
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsData = response.data['products'];
        return productsData.map((data) => VendorProduct.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error fetching products: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      throw Exception('Failed to fetch products: ${e.message}');
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<VendorProduct> addProduct(VendorProduct product) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.addProductPartnerProduct,
        data: product.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final productData = response.data['product'];
        return VendorProduct.fromJson(productData);
      } else {
        throw Exception('Failed to add product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error adding product: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      throw Exception('Failed to add product: ${e.message}');
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  Future<VendorProduct> updateProduct(String productId, VendorProduct product) async {
    try {
      print('Updating product with ID: $productId');
      print('Update data: ${product.toJson()}');
      
      final response = await _dio.put(
        '${ApiEndpoints.updateVendorProduct}/$productId',
        data: product.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );


      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> && response.data['product'] != null) {
          final productData = response.data['product'];
          print('Updated product data: $productData');
          return VendorProduct.fromJson(productData);
        } else {
          print('Error: Invalid response format');
          throw Exception('Invalid response format: product data not found');
        }
      } else {
        print('Error: Invalid status code ${response.statusCode}');
        throw Exception('Failed to update product: ${response.data['message'] ?? response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error updating product: ${e.message}');
      print('Dio error type: ${e.type}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
      }
      throw Exception('Failed to update product: ${e.message}');
    } catch (e, stackTrace) {
      print('Error updating product: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final url = '${ApiEndpoints.deleteVendorProduct}/$productId';
      print('Deleting product with ID: $productId');
      print('Request URL: $url');
      
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Product deleted successfully');
        return;
      } else {
        print('Error: Invalid status code ${response.statusCode}');
        throw Exception('Failed to delete product: ${response.data['message'] ?? response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error deleting product: ${e.message}');
      print('Dio error type: ${e.type}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
        print('Error response headers: ${e.response?.headers}');
      }
      throw Exception('Failed to delete product: ${e.message}');
    } catch (e, stackTrace) {
      print('Error deleting product: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<VendorProduct?> getProductById(String productId) async {
    try {
      final url = '${ApiEndpoints.getVendorProduct}/$productId';
      print('Fetching product with ID: $productId');
      print('Request URL: $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final productData = response.data['product'];
          if (productData != null) {
            print('Product data: $productData');
            return VendorProduct.fromJson(productData);
          }
        }
        print('Error: Product data is null in response');
        return null;
      } else {
        print('Error: Invalid status code ${response.statusCode}');
        throw Exception('Failed to fetch product: ${response.data['message'] ?? response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error fetching product: ${e.message}');
      print('Dio error type: ${e.type}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        print('Error response status: ${e.response?.statusCode}');
        print('Error response headers: ${e.response?.headers}');
      }
      throw Exception('Failed to fetch product: ${e.message}');
    } catch (e, stackTrace) {
      print('Error fetching product: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch product: $e');
    }
  }
} 