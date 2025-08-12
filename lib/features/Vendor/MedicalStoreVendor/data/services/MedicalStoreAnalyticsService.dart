import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineReturnRequestModel.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreInsightsModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreDashboardChartsModel.dart';

class MedicalStoreAnalyticsService {
  
  // Mock data for analytics
  static List<MedicineOrderModel> _mockOrders = [
    MedicineOrderModel(
      orderId: 'ORD-001',
      prescriptionId: 'PRES-001',
      userId: 'USER-001',
      vendorId: 'VENDOR-001',
      discountAmount: 50.0,
      subtotal: 500.0,
      totalAmount: 450.0,
      orderStatus: 'Pending',
      paymentStatus: 'Paid',
      deliveryStatus: 'Pending',
      selfDelivery: false,
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      user: UserModel(
        userId: 'USER-001',
        name: 'John Doe',
        emailId: 'john@example.com',
        phoneNumber: '1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'Male',
        location: '123 Main St',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      orderItems: [],
      deliveryCharge: 30.0,
      platformFee: 20.0,
    ),
    MedicineOrderModel(
      orderId: 'ORD-002',
      prescriptionId: 'PRES-002',
      userId: 'USER-002',
      vendorId: 'VENDOR-001',
      discountAmount: 0.0,
      subtotal: 800.0,
      totalAmount: 800.0,
      orderStatus: 'Accepted',
      paymentStatus: 'Paid',
      deliveryStatus: 'Processing',
      selfDelivery: true,
      createdAt: DateTime.now().subtract(Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(Duration(hours: 6)),
      user: UserModel(
        userId: 'USER-002',
        name: 'Jane Smith',
        emailId: 'jane@example.com',
        phoneNumber: '9876543210',
        dateOfBirth: DateTime(1985, 5, 15),
        gender: 'Female',
        location: '456 Oak Ave',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      orderItems: [],
      deliveryCharge: 0.0,
      platformFee: 20.0,
    ),
    MedicineOrderModel(
      orderId: 'ORD-003',
      prescriptionId: 'PRES-003',
      userId: 'USER-003',
      vendorId: 'VENDOR-001',
      discountAmount: 100.0,
      subtotal: 1200.0,
      totalAmount: 1100.0,
      orderStatus: 'OutForDelivery',
      paymentStatus: 'Paid',
      deliveryStatus: 'OutForDelivery',
      selfDelivery: false,
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      user: UserModel(
        userId: 'USER-003',
        name: 'Mike Johnson',
        emailId: 'mike@example.com',
        phoneNumber: '5551234567',
        dateOfBirth: DateTime(1992, 8, 20),
        gender: 'Male',
        location: '789 Pine St',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      orderItems: [],
      deliveryCharge: 30.0,
      platformFee: 20.0,
    ),
    MedicineOrderModel(
      orderId: 'ORD-004',
      prescriptionId: 'PRES-004',
      userId: 'USER-004',
      vendorId: 'VENDOR-001',
      discountAmount: 0.0,
      subtotal: 300.0,
      totalAmount: 300.0,
      orderStatus: 'Delivered',
      paymentStatus: 'Paid',
      deliveryStatus: 'Delivered',
      selfDelivery: true,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      updatedAt: DateTime.now().subtract(Duration(days: 3)),
      user: UserModel(
        userId: 'USER-004',
        name: 'Sarah Wilson',
        emailId: 'sarah@example.com',
        phoneNumber: '4449876543',
        dateOfBirth: DateTime(1988, 12, 10),
        gender: 'Female',
        location: '321 Elm St',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      orderItems: [],
      deliveryCharge: 0.0,
      platformFee: 20.0,
    ),
    MedicineOrderModel(
      orderId: 'ORD-005',
      prescriptionId: 'PRES-005',
      userId: 'USER-005',
      vendorId: 'VENDOR-001',
      discountAmount: 75.0,
      subtotal: 600.0,
      totalAmount: 525.0,
      orderStatus: 'Cancelled',
      paymentStatus: 'Refunded',
      deliveryStatus: 'Cancelled',
      selfDelivery: false,
      createdAt: DateTime.now().subtract(Duration(days: 4)),
      updatedAt: DateTime.now().subtract(Duration(days: 4)),
      user: UserModel(
        userId: 'USER-005',
        name: 'David Brown',
        emailId: 'david@example.com',
        phoneNumber: '7778889999',
        dateOfBirth: DateTime(1995, 3, 25),
        gender: 'Male',
        location: '654 Maple Dr',
        city: 'Mumbai',
        createdAt: DateTime.now(),
        status: true,
      ),
      orderItems: [],
      deliveryCharge: 30.0,
      platformFee: 20.0,
    ),
  ];

  static List<MedicineReturnRequestModel> _mockReturnRequests = [
    MedicineReturnRequestModel(
      orderId: 'ORD-001',
      customerName: 'John Doe',
      status: 'Pending',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    MedicineReturnRequestModel(
      orderId: 'ORD-002',
      customerName: 'Jane Smith',
      status: 'Approved',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    MedicineReturnRequestModel(
      orderId: 'ORD-003',
      customerName: 'Mike Johnson',
      status: 'Rejected',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    MedicineReturnRequestModel(
      orderId: 'ORD-004',
      customerName: 'Sarah Wilson',
      status: 'Processing',
      createdAt: DateTime.now().subtract(Duration(days: 4)),
    ),
    MedicineReturnRequestModel(
      orderId: 'ORD-005',
      customerName: 'David Brown',
      status: 'Completed',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  // Get analytics based on time filter
  static Future<MedicalStoreAnalyticsModel> getAnalytics(String timeFilter) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate API delay
    
    List<MedicineOrderModel> filteredOrders = _filterOrdersByTime(_mockOrders, timeFilter);
    List<MedicineReturnRequestModel> filteredReturns = _filterReturnsByTime(_mockReturnRequests, timeFilter);
    
    int totalOrders = filteredOrders.length;
    double averageOrderValue = totalOrders > 0 
        ? filteredOrders.fold(0.0, (sum, order) => sum + order.totalAmount) / totalOrders 
        : 0.0;
    int ordersToday = filteredOrders.where((order) => 
        order.createdAt.isAfter(DateTime.now().subtract(Duration(days: 1)))).length;
    int returnsThisWeek = filteredReturns.where((request) => 
        request.createdAt.isAfter(DateTime.now().subtract(Duration(days: 7)))).length;

    return MedicalStoreAnalyticsModel(
      totalOrders: totalOrders,
      averageOrderValue: averageOrderValue.toInt(),
      ordersToday: ordersToday,
      returnsThisWeek: returnsThisWeek,
    );
  }

  // Get dashboard insights based on time filter (mocked)
  static Future<MedicalStoreInsightsModel> getInsights(String timeFilter) async {
    await Future.delayed(Duration(milliseconds: 400));

    // Use filtered data to make the dummy insights feel coherent
    final orders = _filterOrdersByTime(_mockOrders, timeFilter);
    final returns = _filterReturnsByTime(_mockReturnRequests, timeFilter);

    final int totalOrdersReceived = orders.length;
    final int ordersConfirmed = orders
        .where((o) => [
              'Accepted',
              'Confirmed',
              'OutForDelivery',
              'Delivered',
            ].contains(o.orderStatus))
        .length;

    // Dummy but friendly values
    final String avgTimeToFulfillPrescription = '2h 15m';
    final String mostOrderedMedicine = 'Paracetamol 500mg';
    final int unavailableRequestsThisWeek = returns
        .where((r) => r.status.toLowerCase() == 'rejected')
        .length;
    final String topRegionOfDemand = 'Andheri East, Mumbai';
    final double revenueThisMonth = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final int fastMovingMedicineCount = 8; // dummy
    final int repeatBuyers30Days = 23; // dummy
    final double deliveryCompletionRate = totalOrdersReceived == 0
        ? 0
        : (orders.where((o) => o.deliveryStatus == 'Delivered').length / totalOrdersReceived) * 100.0;

    return MedicalStoreInsightsModel(
      totalOrdersReceived: totalOrdersReceived,
      ordersConfirmed: ordersConfirmed,
      avgTimeToFulfillPrescription: avgTimeToFulfillPrescription,
      mostOrderedMedicine: mostOrderedMedicine,
      unavailableRequestsThisWeek: unavailableRequestsThisWeek,
      topRegionOfDemand: topRegionOfDemand,
      revenueThisMonth: double.parse(revenueThisMonth.toStringAsFixed(2)),
      fastMovingMedicineCount: fastMovingMedicineCount,
      repeatBuyers30Days: repeatBuyers30Days,
      deliveryCompletionRate: double.parse(deliveryCompletionRate.toStringAsFixed(1)),
    );
  }

  // Get orders based on time filter
  static Future<List<MedicineOrderModel>> getOrders(String timeFilter) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate API delay
    return _filterOrdersByTime(_mockOrders, timeFilter);
  }

  // Get return requests based on time filter
  static Future<List<MedicineReturnRequestModel>> getReturnRequests(String timeFilter) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate API delay
    return _filterReturnsByTime(_mockReturnRequests, timeFilter);
  }

  // Charts and graphs mock data for dashboard
  static Future<MedicalStoreDashboardChartsModel> getDashboardCharts(String timeFilter) async {
    await Future.delayed(Duration(milliseconds: 400));

    // Basic mock: last 7 days labels
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<int> dailyOrders = [12, 18, 15, 22, 25, 14, 19];
    final List<double> dailyRevenue = [2200, 3100, 2800, 3600, 3900, 2500, 3300];

    // Status counts based on filtered orders
    final orders = _filterOrdersByTime(_mockOrders, timeFilter);
    final Map<String, int> statusCounts = {
      'Pending': orders.where((o) => o.orderStatus == 'Pending').length,
      'Accepted': orders.where((o) => o.orderStatus == 'Accepted').length,
      'OutForDelivery': orders.where((o) => o.orderStatus == 'OutForDelivery').length,
      'Delivered': orders.where((o) => o.orderStatus == 'Delivered').length,
      'Cancelled': orders.where((o) => o.orderStatus == 'Cancelled').length,
    };

    final regionDemand = [
      {'city': 'Andheri East', 'percentage': 32},
      {'city': 'Powai', 'percentage': 24},
      {'city': 'Bandra', 'percentage': 18},
      {'city': 'Ghatkopar', 'percentage': 14},
      {'city': 'Chembur', 'percentage': 12},
    ];

    final topMedicines = [
      {'name': 'Paracetamol 500mg', 'orders': 124},
      {'name': 'Azithromycin 250mg', 'orders': 96},
      {'name': 'Vitamin C 1000mg', 'orders': 84},
      {'name': 'Cetirizine 10mg', 'orders': 69},
      {'name': 'Pantoprazole 40mg', 'orders': 58},
    ];

    final double deliveryCompletionRate = orders.isEmpty
        ? 0
        : (orders.where((o) => o.deliveryStatus == 'Delivered').length / orders.length) * 100.0;

    return MedicalStoreDashboardChartsModel(
      dailyOrders: dailyOrders,
      dailyRevenue: dailyRevenue,
      days: days,
      orderStatusCounts: statusCounts,
      regionDemand: regionDemand,
      topMedicines: topMedicines,
      deliveryCompletionRate: double.parse(deliveryCompletionRate.toStringAsFixed(1)),
    );
  }

  // Filter orders by time period
  static List<MedicineOrderModel> _filterOrdersByTime(List<MedicineOrderModel> orders, String timeFilter) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (timeFilter.toLowerCase()) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return orders; // Return all orders if no filter
    }

    return orders.where((order) => order.createdAt.isAfter(startDate)).toList();
  }

  // Filter return requests by time period
  static List<MedicineReturnRequestModel> _filterReturnsByTime(List<MedicineReturnRequestModel> returns, String timeFilter) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (timeFilter.toLowerCase()) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return returns; // Return all requests if no filter
    }

    return returns.where((request) => request.createdAt.isAfter(startDate)).toList();
  }
}
