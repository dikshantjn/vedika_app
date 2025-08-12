import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestAnalyticsService.dart';

class LabTestAnalyticsViewModel extends ChangeNotifier {
  final LabTestAnalyticsService _service;

  LabTestAnalyticsViewModel({LabTestAnalyticsService? service})
      : _service = service ?? LabTestAnalyticsService();

  bool _isLoading = false;
  String _selectedPeriod = 'Today'; // Today, This Week
  Map<String, dynamic> _analytics = {};
  String? _error;

  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;
  Map<String, dynamic> get analytics => _analytics;
  String? get error => _error;

  List<String> get periods => const ['Today', 'This Week', 'This Month', 'This Year'];

  Future<void> initialize() async {
    await fetchAnalytics(period: _selectedPeriod);
  }

  Future<void> fetchAnalytics({required String period}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.getAnalytics(period: period);
      _analytics = result;
      _selectedPeriod = period;
    } catch (e) {
      _error = 'Failed to load analytics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    fetchAnalytics(period: period);
  }
}


