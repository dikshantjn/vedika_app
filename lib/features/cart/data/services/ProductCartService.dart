import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';

class ProductCartService {
  final Dio _dio;

  ProductCartService(this._dio);

  Future<List<ProductCart>> getProductCartItems() async {
    final String? userId = await StorageService.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }
    final response = await _dio.get('${ApiEndpoints.getProductCartItems}/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> cartItems = response.data['cartItems'] ?? [];
      return cartItems.map((e) => ProductCart.fromJson(e)).toList();
    }
    throw Exception('Failed to get cart items: ${response.statusMessage}');
  }

  Future<int> getProductCartCount() async {
    final String? userId = await StorageService.getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }
    final url = '${ApiEndpoints.getProductCartCount}/$userId';
    final response = await _dio.get(url);
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final count = data['count'] as int?;
      return count ?? 0;
    }
    throw Exception('Failed to get product cart count: ${response.statusMessage}');
  }

  Future<bool> deleteCartItem(String cartId) async {
    final response = await _dio.delete('${ApiEndpoints.deleteProductCartItem}/$cartId');
    return response.statusCode == 200;
  }

  Future<ProductCart> updateCartItemQuantity(String cartId, int quantity) async {
    try {
      final String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final url = '${ApiEndpoints.updateProductCartQuantity}/$cartId';
      final response = await _dio.put(
        url,
        data: {'quantity': quantity, 'userId': userId},
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is Map<String, dynamic> && raw['cartItem'] is Map<String, dynamic>) {
          return ProductCart.fromJson(raw['cartItem'] as Map<String, dynamic>);
        }
        // Fallback: construct minimal updated item; view model will merge
        return ProductCart(
          cartId: cartId,
          userId: userId,
          quantity: quantity,
        );
      }
      throw Exception('Failed to update cart item quantity: ${response.statusMessage}');
    } on DioException catch (e) {
      rethrow;
    }
  }
}


