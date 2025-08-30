import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/cart/data/services/CartService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';

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
    
    notifyListeners();
  }

  void removeProductFromCart(String productId) {
    _productCart.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }

  void updateProductQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProductFromCart(productId);
      return;
    }
    
    final index = _productCart.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      _productCart[index]['quantity'] = quantity;
      notifyListeners();
    }
  }

  void clearProductCart() {
    _productCart.clear();
    notifyListeners();
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
    notifyListeners();
  }

  void removeMedicineOrder(String orderId) {
    _medicineOrders.removeWhere((order) => order.orderId == orderId);
    notifyListeners();
  }

  void updateMedicineOrderStatus(String orderId, String status) {
    final index = _medicineOrders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      // Create a new Order with updated status
      final updatedOrder = _medicineOrders[index].copyWith(status: status);
      _medicineOrders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void clearMedicineOrders() {
    _medicineOrders.clear();
    notifyListeners();
  }

  // Loading States
  void setProductLoading(bool loading) {
    _isProductLoading = loading;
    notifyListeners();
  }

  void setMedicineLoading(bool loading) {
    _isMedicineLoading = loading;
    notifyListeners();
  }

  // Error Handling
  void setProductError(String? error) {
    _productError = error;
    notifyListeners();
  }

  void setMedicineError(String? error) {
    _medicineError = error;
    notifyListeners();
  }

  void clearProductError() {
    _productError = null;
    notifyListeners();
  }

  void clearMedicineError() {
    _medicineError = null;
    notifyListeners();
  }

  // Payment and Order Placement Methods
  void setPlacingOrder(bool placing) {
    _isPlacingOrder = placing;
    notifyListeners();
  }

  void setOrderPlacementError(String? error) {
    _orderPlacementError = error;
    notifyListeners();
  }

  void clearOrderPlacementError() {
    _orderPlacementError = null;
    notifyListeners();
  }

  /// Handle payment success and place the medicine order
  Future<bool> handlePaymentSuccess({
    required String orderId,
    required String addressId,
    required String paymentId,
    String? authToken,
  }) async {
    try {
      print('🎯 [CartViewModel] Handling payment success for order: $orderId');
      setPlacingOrder(true);
      clearOrderPlacementError();

      final result = await _cartService.placeMedicineOrder(
        orderId: orderId,
        addressId: addressId,
        paymentId: paymentId,
        authToken: authToken,
      );

      if (result['success'] == true) {
        print('✅ [CartViewModel] Order placed successfully');
        print('📊 [CartViewModel] Order details: ${result['data']}');
        
        // Update the order status in local list if it exists
        final orderIndex = _medicineOrders.indexWhere((order) => order.orderId == orderId);
        if (orderIndex != -1) {
          // Create a new Order with updated fields
          final updatedOrder = _medicineOrders[orderIndex].copyWith(
            status: 'payment_completed',
            addressId: addressId,
            paymentId: paymentId,
          );
          _medicineOrders[orderIndex] = updatedOrder;
        }
        
        notifyListeners();
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

  // Initialize with mock data (for development)
  void initializeWithMockData() {
    // Mock product cart data
    _productCart = [
      {
        'id': '1',
        'name': 'Vitamin D3 1000IU',
        'price': 299.0,
        'quantity': 2,
        'image': 'https://via.placeholder.com/80x80',
        'brand': 'HealthVit',
      },
      {
        'id': '2',
        'name': 'Omega-3 Fish Oil Capsules',
        'price': 450.0,
        'quantity': 1,
        'image': 'https://via.placeholder.com/80x80',
        'brand': 'NutriLife',
      },
    ];

    // Mock medicine orders data
    _medicineOrders = [
      Order(
        orderId: 'MED-001-2024',
        vendorId: 'vendor-001',
        prescriptionId: 'prescription-001',
        userId: 'user-001',
        totalAmount: 450.0,
        platformFee: 0.0,
        status: 'pending',
        note: 'Skip paracetamol if fever not present',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
        vendor: OrderVendor(
          vendorId: 'vendor-001',
          name: 'HealthCare Pharmacy',
        ),
      ),
      Order(
        orderId: 'MED-002-2024',
        vendorId: 'vendor-002',
        prescriptionId: 'prescription-002',
        userId: 'user-001',
        totalAmount: 320.0,
        platformFee: 0.0,
        status: 'confirmed',
        note: 'Full course treatment',
        createdAt: DateTime(2024, 1, 14),
        updatedAt: DateTime(2024, 1, 14),
        vendor: OrderVendor(
          vendorId: 'vendor-002',
          name: 'MedPlus Store',
        ),
      ),
    ];

    notifyListeners();
  }

  // Checkout Methods
  Future<bool> checkoutProducts() async {
    try {
      setProductLoading(true);
      clearProductError();
      
      // TODO: Implement actual checkout API call
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      
      // Clear cart after successful checkout
      clearProductCart();
      return true;
    } catch (e) {
      setProductError('Checkout failed: $e');
      return false;
    } finally {
      setProductLoading(false);
    }
  }

  Future<bool> cancelMedicineOrder(String orderId) async {
    try {
      setMedicineLoading(true);
      clearMedicineError();
      
      // TODO: Implement actual cancel API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      // Remove order from local list
      removeMedicineOrder(orderId);
      return true;
    } catch (e) {
      setMedicineError('Failed to cancel order: $e');
      return false;
    } finally {
      setMedicineLoading(false);
    }
  }
}
