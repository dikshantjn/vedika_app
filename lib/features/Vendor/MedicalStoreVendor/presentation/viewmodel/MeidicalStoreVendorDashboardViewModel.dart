import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineReturnRequestModel.dart';

class MedicalStoreVendorDashboardViewModel extends ChangeNotifier {
  bool isServiceOnline = true;

  // Sample Medicine Orders (5 records)
  List<MedicineOrderModel> orders = [
    MedicineOrderModel(orderId: '001', customerName: 'John Doe', status: 'Pending'),
    MedicineOrderModel(orderId: '002', customerName: 'Jane Smith', status: 'Accepted'),
    MedicineOrderModel(orderId: '003', customerName: 'Emily Johnson', status: 'Shipped'),
    MedicineOrderModel(orderId: '004', customerName: 'Michael Brown', status: 'Delivered'),
    MedicineOrderModel(orderId: '005', customerName: 'David Wilson', status: 'Canceled'),
  ];

  // Sample Return Requests (5 records)
  List<MedicineReturnRequestModel> returnRequests = [
    MedicineReturnRequestModel(orderId: '006', customerName: 'Mark Lee', status: 'Pending'),
    MedicineReturnRequestModel(orderId: '007', customerName: 'Sophia Martinez', status: 'Approved'),
    MedicineReturnRequestModel(orderId: '008', customerName: 'Olivia Taylor', status: 'Rejected'),
    MedicineReturnRequestModel(orderId: '009', customerName: 'Daniel Harris', status: 'Processing'),
    MedicineReturnRequestModel(orderId: '010', customerName: 'James Anderson', status: 'Completed'),
  ];

  // Store Analytics Data
  MedicalStoreAnalyticsModel analytics = MedicalStoreAnalyticsModel(
    totalOrders: 150,
    averageOrderValue: 100,
    ordersToday: 20,
    returnsThisWeek: 5,
  );

  // Function to Toggle Online/Offline Status
  void toggleServiceStatus() {
    isServiceOnline = !isServiceOnline;
    notifyListeners();
  }
}
