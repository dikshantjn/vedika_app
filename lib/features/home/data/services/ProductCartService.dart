import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class ProductCartService {
  final Dio _dio;

  ProductCartService(this._dio);

  Future<bool> checkProductInCart(String productId) async {
    try {
      String? userId = await StorageService.getUserId();
      print('Checking cart status for userId: $userId, productId: $productId');
      
      final response = await _dio.post(
        ApiEndpoints.checkProductInCart,
        data: {
          'userId': userId,
          'productId': productId,
        },
      );

      print('Cart check response: ${response.data}');
      
      if (response.statusCode == 200) {
        final isInCart = response.data['isInCart'] ?? false;
        print('Product is in cart: $isInCart');
        return isInCart;
      } else {
        print('Error response status: ${response.statusCode}');
        throw Exception('Failed to check cart status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error checking cart: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception('Failed to check cart status: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Failed to check cart status: ${e.message}');
    } catch (e) {
      print('Error checking cart: $e');
      throw Exception('Failed to check cart status: $e');
    }
  }

  Future<ProductCart> addToCart({required ProductCart cartItem}) async {
    try {
      // Convert ProductCart object to request body
      final requestBody = cartItem.toJson();

      final response = await _dio.post(
        ApiEndpoints.addToProductCart,
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response data into ProductCart model
        final responseData = response.data['cartItem'];
        return ProductCart.fromJson(responseData);
      } else {
        throw Exception('Failed to add item to cart: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error adding to cart: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception('Failed to add item to cart: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Failed to add item to cart: ${e.message}');
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<List<ProductCart>> getProductCartItems() async {
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await _dio.get(
        '${ApiEndpoints.getProductCartItems}/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = response.data['cartItems'] ?? [];
        return cartItems.map((item) => ProductCart.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get cart items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error getting cart items: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception('Failed to get cart items: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Failed to get cart items: ${e.message}');
    } catch (e) {
      print('Error getting cart items: $e');
      throw Exception('Failed to get cart items: $e');
    }
  }

  Future<bool> deleteCartItem(String cartId) async {
    try {
      print('Deleting cart item with ID: $cartId');
      
      final response = await _dio.delete(
        '${ApiEndpoints.deleteProductCartItem}/$cartId',
      );

      if (response.statusCode == 200) {
        print('Cart item deleted successfully');
        return true;
      } else {
        print('Failed to delete cart item: ${response.statusMessage}');
        throw Exception('Failed to delete cart item: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error deleting cart item: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception('Failed to delete cart item: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Failed to delete cart item: ${e.message}');
    } catch (e) {
      print('Error deleting cart item: $e');
      throw Exception('Failed to delete cart item: $e');
    }
  }

  Future<ProductCart> updateCartItemQuantity(String cartId, int quantity) async {
    try {
      print('Updating cart item quantity. Cart ID: $cartId, New quantity: $quantity');
      
      final response = await _dio.put(
        '${ApiEndpoints.updateProductCartQuantity}/$cartId',
        data: {'quantity': quantity},
      );

      if (response.statusCode == 200) {
        print('Cart item quantity updated successfully');
        final responseData = response.data['cartItem'];
        return ProductCart.fromJson(responseData);
      } else {
        print('Failed to update cart item quantity: ${response.statusMessage}');
        throw Exception('Failed to update cart item quantity: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Dio error updating cart item quantity: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception('Failed to update cart item quantity: ${e.response?.data['message'] ?? e.message}');
      }
      throw Exception('Failed to update cart item quantity: ${e.message}');
    } catch (e) {
      print('Error updating cart item quantity: $e');
      throw Exception('Failed to update cart item quantity: $e');
    }
  }
} 