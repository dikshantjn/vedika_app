import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';

class MedicineProductService {
  final Dio _dio = Dio();

  MedicineProductService() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    );
  }

  // 📌 Add a New Medicine Product
  Future<MedicineProduct> addProduct(String token, MedicineProduct product) async {
    Response response = await _handleRequest(() => _dio.post(
      ApiEndpoints.addProduct,
      data: jsonEncode(product.toJson()),
      options: Options(headers: _getAuthHeaders(token)),
    ));

    if (response.statusCode == 201) {
      return MedicineProduct.fromJson(response.data);
    }
    throw Exception("Failed to add product");
  }

  // 📌 Get All Products
  Future<List<MedicineProduct>> getAllProducts(String token) async {
    Response response = await _handleRequest(() => _dio.get(
      ApiEndpoints.getAllProducts,
      options: Options(headers: _getAuthHeaders(token)),
    ));

    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List).map((e) => MedicineProduct.fromJson(e)).toList();
    }
    return [];
  }

  // 📌 Get Product by ID
  Future<MedicineProduct?> getProductById(String token, String productId) async {
    Response response = await _handleRequest(() => _dio.get(
      "${ApiEndpoints.getProductById}$productId",
      options: Options(headers: _getAuthHeaders(token)),
    ));

    if (response.statusCode == 200 && response.data != null) {
      return MedicineProduct.fromJson(response.data);
    }
    return null;
  }

  // 📌 Update a Product
  Future<MedicineProduct> updateProduct(String token, String productId, MedicineProduct updatedProduct) async {
    Response response = await _handleRequest(() => _dio.put(
      "${ApiEndpoints.updateProduct}$productId",
      data: jsonEncode(updatedProduct.toJson()),
      options: Options(headers: _getAuthHeaders(token)),
    ));

    if (response.statusCode == 200) {
      return MedicineProduct.fromJson(response.data);
    }
    throw Exception("Failed to update product");
  }

  // 📌 Delete a Product
  Future<void> deleteProduct(String token, String productId) async {
    Response response = await _handleRequest(() => _dio.delete(
      "${ApiEndpoints.deleteProduct}$productId",
      options: Options(headers: _getAuthHeaders(token)),
    ));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete product");
    }
  }

// 📌 Get Medicine Suggestions (Search Query)
  Future<List<MedicineProduct>> getMedicineSuggestions(String vendorId, String query) async {
    try {
      // Send GET request with vendorId and query parameters
      Response response = await _handleRequest(() => _dio.get(
        "${ApiEndpoints.getMedicineSuggestions}",
        queryParameters: {
          'vendorId': vendorId,  // Pass the vendorId as a query parameter
          's': query,            // Pass the search query as a query parameter
        },
      ));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // Check if the response contains medicines and map them to MedicineProduct
        List<dynamic> medicinesData = response.data['medicines'];
        return medicinesData.map((e) => MedicineProduct.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching medicines: $e");
    }
    return [];
  }


  // 🔹 Get Authorization Headers with Token
  Map<String, String> _getAuthHeaders(String token) {
    return {"Authorization": "Bearer $token"};
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
        data: error.response?.data ?? {"error": "An unexpected error occurred"},
      );
    }
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 500,
      data: {"error": "An unknown error occurred"},
    );
  }
}
