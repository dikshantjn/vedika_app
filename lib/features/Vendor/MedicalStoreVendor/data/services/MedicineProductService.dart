import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class MedicineProductService {
  final Dio _dio = Dio();
  final String token; // 🔥 JWT token for authentication

  MedicineProductService(this.token) {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // 🔥 Pass JWT token in headers
      },
    );
  }

  // 📌 Add a New Medicine Product
  Future<Response> addProduct(Map<String, dynamic> productData) async {
    return _handleRequest(() => _dio.post(ApiEndpoints.addProduct, data: jsonEncode(productData)));
  }

  // 📌 Get All Products
  Future<Response> getAllProducts() async {
    return _handleRequest(() => _dio.get(ApiEndpoints.getAllProducts));
  }

  // 📌 Get Product by ID
  Future<Response> getProductById(String productId) async {
    return _handleRequest(() => _dio.get("${ApiEndpoints.getProductById}$productId"));
  }

  // 📌 Update a Product
  Future<Response> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    return _handleRequest(() => _dio.put("${ApiEndpoints.updateProduct}$productId", data: jsonEncode(updatedData)));
  }

  // 📌 Delete a Product
  Future<Response> deleteProduct(String productId) async {
    return _handleRequest(() => _dio.delete("${ApiEndpoints.deleteProduct}$productId"));
  }

  // 📌 Get Inventory (Vendor ID Extracted from JWT)
  Future<Response> getInventory() async {
    return _handleRequest(() => _dio.get(ApiEndpoints.getInventory));
  }

  // 📌 Handle API Requests & Errors
  Future<Response> _handleRequest(Future<Response> Function() request) async {
    try {
      return await request();
    } catch (error) {
      return _handleError(error);
    }
  }

  // 📌 Error Handling Function
  Response _handleError(dynamic error) {
    if (error is DioException) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: error.response?.statusCode ?? 500,
        statusMessage: error.message,
        data: error.response?.data ?? {"error": "An unexpected error occurred"},
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
        data: {"error": "An unknown error occurred"},
      );
    }
  }
}
