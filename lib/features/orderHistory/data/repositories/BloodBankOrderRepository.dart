import 'package:vedika_healthcare/features/orderHistory/data/models/BloodBankOrder.dart';

class BloodBankOrderRepository {
  // Mock Data List
  final List<BloodBankOrder> _mockOrders = [
    BloodBankOrder(
      orderId: "BB001",
      userId: "U123",
      bloodBankId: "BBANK01",
      bloodBankName: "Red Cross Blood Bank",
      bloodType: "O+",
      unitsOrdered: 2,
      orderDate: "2025-02-27",
      totalPrice: 500.0,
      status: "Completed",
    ),
    BloodBankOrder(
      orderId: "BB002",
      userId: "U123",
      bloodBankId: "BBANK02",
      bloodBankName: "City Hospital Blood Bank",
      bloodType: "A-",
      unitsOrdered: 1,
      orderDate: "2025-02-26",
      totalPrice: 250.0,
      status: "Pending",
    ),
    BloodBankOrder(
      orderId: "BB003",
      userId: "U123",
      bloodBankId: "BBANK03",
      bloodBankName: "Lifeline Blood Center",
      bloodType: "B+",
      unitsOrdered: 3,
      orderDate: "2025-02-25",
      totalPrice: 750.0,
      status: "Cancelled",
    ),
  ];

  /// Fetch Blood Bank Orders (Mock Data)
  Future<List<BloodBankOrder>> getBloodBankOrders(String userId) async {
    // Simulate network delay

    // Filter orders for the given userId
    return _mockOrders.where((order) => order.userId == userId).toList();
  }

  /// Place a Blood Bank Order (Mock Data)
  Future<void> placeBloodBankOrder(BloodBankOrder order) async {
    await Future.delayed(Duration(seconds: 1));

    // Add the new order to mock list
    _mockOrders.add(order);
  }

  /// Cancel Blood Bank Order (Mock Data)
  Future<void> cancelBloodBankOrder(String orderId) async {
    await Future.delayed(Duration(seconds: 1));

    // Find and remove the order by orderId
    _mockOrders.removeWhere((order) => order.orderId == orderId);
  }
}
