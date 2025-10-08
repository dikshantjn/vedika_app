import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartService.dart';
import 'package:vedika_healthcare/features/cart/data/services/ProductCartService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'dart:convert';

class CartViewModel extends ChangeNotifier {
  // Services
  final CartService _cartService = CartService();

  // Product Cart
  List<Map<String, dynamic>> _productCart = [];
  bool _isProductLoading = false;
  String? _productError;

  // Medicine Orders
  List<Order> _medicineOrders = [];
  bool _isMedicineLoading = false;
  String? _medicineError;

  // Payment and Order Placement
  bool _isPlacingOrder = false;
  String? _orderPlacementError;

  // Medicine Cart Count
  int _medicineCartCount = 0;
  int _productCartCount = 0;
  bool _isLoadingCartCount = false;
  String? _cartCountError;

  // Socket connection
  IO.Socket? _socket;
  bool _disposed = false;

  // Callback for cart count updates
  Function()? onCartCountUpdate;
  // Callback for medicine orders updates (to refresh MedicineOrderTab)
  Function()? onMedicineOrdersUpdate;

  // Getters
  List<Map<String, dynamic>> get productCart => _productCart;
  bool get isProductLoading => _isProductLoading;
  String? get productError => _productError;
  
  List<Order> get medicineOrders => _medicineOrders;
  bool get isMedicineLoading => _isMedicineLoading;
  String? get medicineError => _medicineError;
  
  // Payment and Order Placement getters
  bool get isPlacingOrder => _isPlacingOrder;
  String? get orderPlacementError => _orderPlacementError;

  // Medicine Cart Count getters
  int get medicineCartCount => _medicineCartCount;
  int get productCartCount => _productCartCount;
  int get cartCount => _medicineCartCount + _productCartCount;
  bool get isLoadingCartCount => _isLoadingCartCount;
  String? get cartCountError => _cartCountError;

  // Constructor
  CartViewModel() {
    initSocketConnection();
  }

  // Socket connection initialization
  void initSocketConnection() async {
    
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        debugPrint("❌ User ID not found for socket registration");
        return;
      }

      // Close existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
        'forceNew': true,
        'upgrade': true,
        'rememberUpgrade': true,
        'path': '/socket.io/',
        'query': {'userId': userId},
      });

      // Set up event listeners
      _socket!.onConnect((_) {
        
        _socket!.emit('register', userId);
      });

      _socket!.onConnectError((data) {
        
        _attemptReconnect();
      });

      _socket!.onError((data) {
        
      });

      _socket!.onDisconnect((_) {
        
        _attemptReconnect();
      });

      // Product cart count updates
      _socket!.on('cart:updateCount', (data) async {
        try {
          final payload = data is String ? json.decode(data) : data as Map<String, dynamic>;
          final count = payload['count'] as int?;
          if (count != null) {
            updateProductCartCount(count);
          } else {
            
          }
        } catch (e, st) {
          
        }
      });

      // Add event listener for orderStatusUpdated
      _socket!.on('orderStatusUpdated', (data) async {
        await _handleOrderStatusUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
    } catch (e) {
      
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected) {
        
        _socket!.connect();
      }
    });
  }

  Future<void> _handleOrderStatusUpdate(dynamic data) async {
    try {
      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;

      // Update medicine cart count if provided
      final int? medCount = orderData['medicineCartCount'] as int?;
      if (medCount != null) {
        updateMedicineCartCount(medCount);
      }

      // Notify listeners to refresh medicine orders UI
      if (onMedicineOrdersUpdate != null) {
        onMedicineOrdersUpdate!();
      }

      final medicineCartCount = orderData['medicineCartCount'];

      if (medicineCartCount != null) {

        // Update the cart count
        updateMedicineCartCount(medicineCartCount);
      } else {
        
      }
    } catch (e, stackTrace) {
      
    }
  }

  // Product Cart Methods
  void addProductToCart(Map<String, dynamic> product) {
    final existingIndex = _productCart.indexWhere((item) => item['id'] == product['id']);
    
    if (existingIndex != -1) {
      // Update quantity if product already exists
      _productCart[existingIndex]['quantity'] = (_productCart[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      // Add new product with quantity 1
      _productCart.add({...product, 'quantity': 1});
    }
    
    if (!_disposed) notifyListeners();
  }

  void removeProductFromCart(String productId) {
    _productCart.removeWhere((item) => item['id'] == productId);
    if (!_disposed) notifyListeners();
  }

  void updateProductQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProductFromCart(productId);
      return;
    }
    
    final index = _productCart.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      _productCart[index]['quantity'] = quantity;
      if (!_disposed) notifyListeners();
    }
  }

  void clearProductCart() {
    _productCart.clear();
    if (!_disposed) notifyListeners();
  }

  double get productCartTotal {
    return _productCart.fold<double>(
      0,
      (sum, product) => sum + ((product['price'] ?? 0) * (product['quantity'] ?? 1)),
    );
  }

  int get productCartItemCount {
    return _productCart.fold<int>(
      0,
      (sum, product) => sum + ((product['quantity'] as int?) ?? 1),
    );
  }

  // Medicine Orders Methods
  void addMedicineOrder(Order order) {
    _medicineOrders.add(order);
    if (!_disposed) notifyListeners();
  }

  void removeMedicineOrder(String orderId) {
    _medicineOrders.removeWhere((order) => order.orderId == orderId);
    if (!_disposed) notifyListeners();
  }

  void updateMedicineOrderStatus(String orderId, String status) {
    final index = _medicineOrders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      // Create a new Order with updated status
      final updatedOrder = _medicineOrders[index].copyWith(status: status);
      _medicineOrders[index] = updatedOrder;
      if (!_disposed) notifyListeners();
    }
  }

  void clearMedicineOrders() {
    _medicineOrders.clear();
    if (!_disposed) notifyListeners();
  }

  // Loading States
  void setProductLoading(bool loading) {
    _isProductLoading = loading;
    if (!_disposed) notifyListeners();
  }

  void setMedicineLoading(bool loading) {
    _isMedicineLoading = loading;
    if (!_disposed) notifyListeners();
  }

  // Error Handling
  void setProductError(String? error) {
    _productError = error;
    if (!_disposed) notifyListeners();
  }

  void setMedicineError(String? error) {
    _medicineError = error;
    if (!_disposed) notifyListeners();
  }

  void clearProductError() {
    _productError = null;
    if (!_disposed) notifyListeners();
  }

  void clearMedicineError() {
    _medicineError = null;
    if (!_disposed) notifyListeners();
  }

  // Payment and Order Placement Methods
  void setPlacingOrder(bool placing) {
    _isPlacingOrder = placing;
    if (!_disposed) notifyListeners();
  }

  void setOrderPlacementError(String? error) {
    _orderPlacementError = error;
    if (!_disposed) notifyListeners();
  }

  void clearOrderPlacementError() {
    _orderPlacementError = null;
    if (!_disposed) notifyListeners();
  }

  // Medicine Cart Count Methods
  void setLoadingCartCount(bool loading) {
    _isLoadingCartCount = loading;
    if (!_disposed) notifyListeners();
  }

  void setCartCountError(String? error) {
    _cartCountError = error;
    if (!_disposed) notifyListeners();
  }

  void clearCartCountError() {
    _cartCountError = null;
    if (!_disposed) notifyListeners();
  }

  void updateMedicineCartCount(int count) {
    _medicineCartCount = count;
    if (!_disposed) notifyListeners();
    // Trigger callback even if count is unchanged
    if (onCartCountUpdate != null) {
      onCartCountUpdate!();
    }
  }

  void updateProductCartCount(int count) {
    _productCartCount = count;
    if (!_disposed) notifyListeners();
    if (onCartCountUpdate != null) {
      onCartCountUpdate!();
    }
  }

  /// Fetch medicine cart count from API
  Future<bool> fetchMedicineCartCount({
    required String userId,
    String? authToken,
  }) async {
    try {
      setLoadingCartCount(true);
      clearCartCountError();

      final result = await _cartService.getMedicineCartCount(
        userId: userId,
        authToken: authToken,
      );

      if (result['success'] == true) {
        final count = result['medicineCartCount'] as int;
        updateMedicineCartCount(count);
        return true;
      } else {
        setCartCountError(result['message'] ?? 'Failed to get cart count');
        return false;
      }
    } catch (e) {
      setCartCountError('Error fetching cart count: $e');
      return false;
    } finally {
      setLoadingCartCount(false);
    }
  }

  /// Fetch product cart count from API
  Future<bool> fetchProductCartCount() async {
    try {
      setLoadingCartCount(true);
      clearCartCountError();

      final service = ProductCartService(Dio());
      final count = await service.getProductCartCount();
      updateProductCartCount(count);
      return true;
    } catch (e) {
      setCartCountError('Error fetching product cart count: $e');
      return false;
    } finally {
      setLoadingCartCount(false);
    }
  }

  /// Handle payment success and place the medicine order
  Future<bool> handlePaymentSuccess({
    required List<String> orderIds,
    required String addressId,
    required String paymentId,
    String? authToken,
  }) async {
    try {
      setPlacingOrder(true);
      clearOrderPlacementError();

      final result = await _cartService.placeMedicineOrder(
        orderIds: orderIds,
        addressId: addressId,
        paymentId: paymentId,
        authToken: authToken,
      );

      if (result['success'] == true) {
        print('✅ [CartViewModel] Order placed successfully');
        print('📊 [CartViewModel] Order details: ${result['data']}');
        
        // Update the order status in local list if it exists
        for (final id in orderIds) {
          final orderIndex = _medicineOrders.indexWhere((order) => order.orderId == id);
          if (orderIndex != -1) {
            final updatedOrder = _medicineOrders[orderIndex].copyWith(
              status: 'payment_completed',
              addressId: addressId,
              paymentId: paymentId,
            );
            _medicineOrders[orderIndex] = updatedOrder;
          }
        }
        
        if (!_disposed) notifyListeners();
        return true;
      } else {
        print('❌ [CartViewModel] Failed to place order: ${result['message']}');
        setOrderPlacementError(result['message'] ?? 'Failed to place order');
        return false;
      }
    } catch (e) {
      print('🚨 [CartViewModel] Error placing order: $e');
      setOrderPlacementError('Error placing order: $e');
      return false;
    } finally {
      setPlacingOrder(false);
    }
  }

  // Dispose method for socket cleanup
  @override
  void dispose() {
    _disposed = true;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }
}
