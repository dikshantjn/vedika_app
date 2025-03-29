import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class TrackOrderService {
  // Static method to fetch user orders
  Future<List<MedicineOrderModel>> fetchUserOrders() async {
    try {
      // Mock userId
      String userId = 'sampleUserId';

      // Static data for orders
      List<MedicineOrderModel> orders = [
        MedicineOrderModel(
          orderId: '#ORD12345',
          prescriptionId: 'PRES123',
          userId: userId,
          vendorId: 'VENDOR001',
          addressId: 'ADDR001',
          appliedCoupon: 'COUPON01',
          discountAmount: 50.0,
          subtotal: 500.0,
          totalAmount: 450.0,
          orderStatus: 'Out for Delivery',
          paymentMethod: 'Credit Card',
          transactionId: 'TXN123456',
          paymentStatus: 'Paid',
          deliveryStatus: 'Out for Delivery',
          estimatedDeliveryDate: DateTime.now().add(Duration(hours: 2)),
          trackingId: 'TRACK123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          user: UserModel.empty(), // Assuming UserModel.empty() provides mock user data
          orderItems: [
            CartModel(
              cartId: '1',
              productId: '101',
              name: 'Paracetamol',
              price: 50.0,
              quantity: 5,
            ),
            CartModel(
              cartId: '2',
              productId: '102',
              name: 'Azithromycin',
              price: 100.0,
              quantity: 3,
            ),
          ],
        ),
        // Add more static orders if necessary
      ];
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load orders');
    }
  }

  // Static method to update order status
  Future<MedicineOrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      // Static data for a single order update
      MedicineOrderModel updatedOrder = MedicineOrderModel(
        orderId: orderId,
        prescriptionId: 'PRES123',
        userId: 'sampleUserId',
        vendorId: 'VENDOR001',
        addressId: 'ADDR001',
        appliedCoupon: 'COUPON01',
        discountAmount: 50.0,
        subtotal: 500.0,
        totalAmount: 450.0,
        orderStatus: status,
        paymentMethod: 'Credit Card',
        transactionId: 'TXN123456',
        paymentStatus: 'Paid',
        deliveryStatus: status,
        estimatedDeliveryDate: DateTime.now().add(Duration(hours: 2)),
        trackingId: 'TRACK123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        user: UserModel.empty(), // Assuming UserModel.empty() provides mock user data
        orderItems: [
          CartModel(
            cartId: '1',
            productId: '101',
            name: 'Paracetamol',
            price: 50.0,
            quantity: 5,
          ),
          CartModel(
            cartId: '2',
            productId: '102',
            name: 'Azithromycin',
            price: 100.0,
            quantity: 3,
          ),
        ],
      );
      return updatedOrder;
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status');
    }
  }
}
