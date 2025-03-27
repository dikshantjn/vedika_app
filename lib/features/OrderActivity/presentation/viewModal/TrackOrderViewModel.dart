import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/OrderActivity/data/Modals/OrderActivityModel.dart';

class TrackOrderViewModel extends ChangeNotifier {
  List<OrderActivityModel> _orderActivities = [];

  List<OrderActivityModel> get orderActivities => _orderActivities;

  Future<void> fetchOrderActivities(int orderId) async {
    // Simulate fetching order activity data from a backend or database
    // Replace this with actual logic to fetch data
    await Future.delayed(Duration(seconds: 2));

    _orderActivities = [
      OrderActivityModel(activity: "Order Placed", timestamp: "2025-03-25 10:00", status: "Completed"),
      OrderActivityModel(activity: "Processed", timestamp: "2025-03-25 12:00", status: "In Progress"),
      OrderActivityModel(activity: "Shipped", timestamp: "2025-03-25 14:00", status: "In Progress"),
      OrderActivityModel(activity: "Out for Delivery", timestamp: "2025-03-26 09:00", status: "In Progress"),
      OrderActivityModel(activity: "Delivered", timestamp: "2025-03-26 12:00", status: "Completed"),
    ];

    notifyListeners();
  }
}
