import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/ProductPartnerProfileService.dart';
import '../../../Service/VendorService.dart';

class ProductPartnerDashboardViewModel extends ChangeNotifier {
  final ProductPartnerProfileService _service = ProductPartnerProfileService();
  final VendorService _vendorService = VendorService();
  bool _isLoading = false;
  bool _isStatusLoading = false;
  bool _isActive = true;
  String _partnerName = '';
  String _companyLegalName = '';
  String _email = '';
  String _profilePicture = '';
  int _totalProducts = 0;
  double _todayRevenue = 0.0;
  int _pendingOrders = 0;
  int _lowStockItems = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  List<FlSpot> _performanceData = [];
  String _currentPeriod = 'Weekly';
  String _vendorId = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isStatusLoading => _isStatusLoading;
  bool get isActive => _isActive;
  String get partnerName => _partnerName;
  String get companyLegalName => _companyLegalName;
  String get email => _email;
  String get profilePicture => _profilePicture;
  int get totalProducts => _totalProducts;
  double get todayRevenue => _todayRevenue;
  int get pendingOrders => _pendingOrders;
  int get lowStockItems => _lowStockItems;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<FlSpot> get performanceData => _performanceData;
  String get currentPeriod => _currentPeriod;

  Future<void> fetchDashboardData(String vendorId) async {
    _isLoading = true;
    _vendorId = vendorId;
    notifyListeners();

    try {
      // Fetch vendor status
      _isActive = await _vendorService.getVendorStatus(vendorId);

      // Fetch overview data
      final overviewData = await _service.getOverview(vendorId);
      _partnerName = overviewData['brandName'] ?? '';
      _companyLegalName = overviewData['companyLegalName'] ?? '';
      _email = overviewData['email'] ?? '';
      _profilePicture = overviewData['profilePicture'] ?? '';

      // TODO: Fetch other dashboard data (products, revenue, orders, etc.)
      // For now, using dummy data
      _totalProducts = 156;
      _todayRevenue = 1250.75;
      _pendingOrders = 8;
      _lowStockItems = 12;

      _recentActivities = [
        {
          'title': 'Order #12345',
          'description': 'New order received from Sarah Johnson',
          'status': 'Confirmed',
          'time': '2 hours ago',
        },
        {
          'title': 'Order #12344',
          'description': 'Order processed and shipped',
          'status': 'Pending',
          'time': '4 hours ago',
        },
        {
          'title': 'Order #12343',
          'description': 'Order cancelled by customer',
          'status': 'Cancelled',
          'time': '1 day ago',
        },
      ];

      _updatePerformanceData();
    } catch (e) {
      print('Error fetching dashboard data: $e');
      // Handle error appropriately
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool?> toggleVendorStatus() async {
    if (_isStatusLoading) return null;
    
    _isStatusLoading = true;
    notifyListeners();

    try {
      final newStatus = await _vendorService.toggleVendorStatus(_vendorId);
      if (newStatus != null) {
        _isActive = newStatus;
      }
      return newStatus;
    } catch (e) {
      print('Error toggling vendor status: $e');
      return null;
    } finally {
      _isStatusLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard(String vendorId) async {
    await fetchDashboardData(vendorId);
  }

  void updatePerformancePeriod(String period) {
    _currentPeriod = period;
    _updatePerformanceData();
    notifyListeners();
  }

  void _updatePerformanceData() {
    // Generate dummy data based on period
    _performanceData = List.generate(7, (index) {
      double value;
      switch (_currentPeriod) {
        case 'Daily':
          value = 20 + (index * 5) + (index % 3 * 10);
          break;
        case 'Weekly':
          value = 100 + (index * 20) + (index % 3 * 30);
          break;
        case 'Monthly':
          value = 500 + (index * 100) + (index % 3 * 200);
          break;
        default:
          value = 0;
      }
      return FlSpot(index.toDouble(), value);
    });
  }
} 