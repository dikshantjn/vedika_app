import 'package:flutter/foundation.dart';
import '../../data/models/MembershipPlan.dart';
import '../../data/services/MembershipService.dart';

class MembershipViewModel extends ChangeNotifier {
  List<MembershipPlan> _plans = [];
  UserMembership? _currentMembership;
  MembershipPlan? _selectedPlan;
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;
  Map<String, List<MembershipFeature>> _comparisonData = {};

  // Getters
  List<MembershipPlan> get plans => _plans;
  UserMembership? get currentMembership => _currentMembership;
  MembershipPlan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;
  Map<String, List<MembershipFeature>> get comparisonData => _comparisonData;
  
  bool get hasActiveMembership => 
      _currentMembership?.isActive == true && !_currentMembership!.isExpired;

  MembershipPlan? get popularPlan => 
      _plans.isNotEmpty ? _plans.firstWhere((plan) => plan.isPopular, orElse: () => _plans.first) : null;

  /// Load all membership plans
  Future<void> loadPlans() async {
    _setLoading(true);
    _clearError();
    
    try {
      _plans = await MembershipService.getAllPlans();
      
      // Sort plans in the correct sequence: Silver, Gold, Platinum
      _plans.sort((a, b) {
        final order = {'Silver': 1, 'Gold': 2, 'Platinum': 3};
        final aOrder = order[a.type] ?? 999;
        final bOrder = order[b.type] ?? 999;
        return aOrder.compareTo(bOrder);
      });
      
      await _loadComparisonData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load membership plans: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load comparison data for all plans
  Future<void> _loadComparisonData() async {
    try {
      _comparisonData = await MembershipService.getComparisonData();
    } catch (e) {
      debugPrint('Failed to load comparison data: $e');
    }
  }

  /// Load user's current membership
  Future<void> loadCurrentMembership(String userId) async {
    try {
      _currentMembership = await MembershipService.getCurrentUserMembership(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load current membership: $e');
    }
  }

  /// Select a plan
  void selectPlan(MembershipPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  /// Clear selected plan
  void clearSelectedPlan() {
    _selectedPlan = null;
    notifyListeners();
  }

  /// Purchase selected plan
  Future<bool> purchaseSelectedPlan(String userId, String paymentMethod) async {
    if (_selectedPlan == null) {
      _setError('No plan selected');
      return false;
    }

    _setPurchasing(true);
    _clearError();

    try {
      final success = await MembershipService.purchasePlan(
        userId, 
        _selectedPlan!.membershipPlanId, 
        paymentMethod
      );

      if (success) {
        await loadCurrentMembership(userId);
        clearSelectedPlan();
        return true;
      } else {
        _setError('Failed to purchase membership plan');
        return false;
      }
    } catch (e) {
      _setError('Purchase failed: ${e.toString()}');
      return false;
    } finally {
      _setPurchasing(false);
    }
  }

  /// Purchase a specific plan
  Future<bool> purchasePlan(String userId, String planId, String paymentMethod) async {
    final plan = _plans.firstWhere((p) => p.membershipPlanId == planId, orElse: () => _plans.first);
    selectPlan(plan);
    return await purchaseSelectedPlan(userId, paymentMethod);
  }

  /// Cancel current membership
  Future<bool> cancelMembership() async {
    if (_currentMembership == null) {
      _setError('No active membership to cancel');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final success = await MembershipService.cancelMembership(_currentMembership!.userMembershipId);
      
      if (success) {
        _currentMembership = _currentMembership!.copyWith(
          isActive: false,
          status: 'cancelled',
        );
        notifyListeners();
        return true;
      } else {
        _setError('Failed to cancel membership');
        return false;
      }
    } catch (e) {
      _setError('Cancellation failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Renew current membership
  Future<bool> renewMembership(String paymentMethod) async {
    if (_currentMembership == null) {
      _setError('No membership to renew');
      return false;
    }

    _setPurchasing(true);
    _clearError();

    try {
      final success = await MembershipService.renewMembership(
        _currentMembership!.userMembershipId, 
        paymentMethod
      );

      if (success) {
        await loadCurrentMembership(_currentMembership!.userId);
        return true;
      } else {
        _setError('Failed to renew membership');
        return false;
      }
    } catch (e) {
      _setError('Renewal failed: ${e.toString()}');
      return false;
    } finally {
      _setPurchasing(false);
    }
  }

  /// Check if user can use a specific benefit
  Future<bool> canUseBenefit(String userId, String benefitId) async {
    try {
      return await MembershipService.canUseBenefit(userId, benefitId);
    } catch (e) {
      debugPrint('Failed to check benefit availability: $e');
      return false;
    }
  }

  /// Get plan by ID
  MembershipPlan? getPlanById(String planId) {
    try {
      return _plans.firstWhere((plan) => plan.membershipPlanId == planId);
    } catch (e) {
      return null;
    }
  }

  /// Get features for comparison by category
  Map<String, List<MembershipFeature>> getFeaturesByCategory() {
    Map<String, List<MembershipFeature>> categorizedFeatures = {};
    
    if (_plans.isEmpty) return categorizedFeatures;

    // Get all unique categories
    Set<String> categories = {};
    for (var plan in _plans) {
      for (var feature in plan.features) {
        categories.add(feature.category);
      }
    }

    // Group features by category
    for (String category in categories) {
      categorizedFeatures[category] = [];
      
      // Get unique feature titles in this category
      Set<String> featureTitles = {};
      for (var plan in _plans) {
        for (var feature in plan.features) {
          if (feature.category == category) {
            featureTitles.add(feature.title);
          }
        }
      }

      // Add one instance of each feature title for this category
      for (String title in featureTitles) {
        var feature = _plans.first.features.firstWhere(
          (f) => f.title == title && f.category == category,
        );
        categorizedFeatures[category]!.add(feature);
      }
    }

    return categorizedFeatures;
  }

  /// Get feature value for a specific plan and feature
  String getFeatureValueForPlan(String planId, String featureTitle) {
    final plan = getPlanById(planId);
    if (plan == null) return 'N/A';

    try {
      final feature = plan.features.firstWhere((f) => f.title == featureTitle);
      return feature.isIncluded ? (feature.value ?? 'Included') : 'Not Included';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Check if feature is included in plan
  bool isFeatureIncludedInPlan(String planId, String featureTitle) {
    final plan = getPlanById(planId);
    if (plan == null) return false;

    try {
      final feature = plan.features.firstWhere((f) => f.title == featureTitle);
      return feature.isIncluded;
    } catch (e) {
      return false;
    }
  }

  /// Calculate savings compared to individual purchases
  double calculateSavings(MembershipPlan plan) {
    // Mock calculation - in real app, this would be based on actual service prices
    double individualCost = 0;
    
    switch (plan.membershipPlanId) {
      case 'silver':
        individualCost = 20000; // Estimated individual cost
        break;
      case 'gold':
        individualCost = 30000;
        break;
      case 'platinum':
        individualCost = 45000;
        break;
    }
    
    return individualCost - plan.price;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setPurchasing(bool purchasing) {
    _isPurchasing = purchasing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all data
  void clear() {
    _plans = [];
    _currentMembership = null;
    _selectedPlan = null;
    _isLoading = false;
    _isPurchasing = false;
    _error = null;
    _comparisonData = {};
    notifyListeners();
  }
}

/// Extension to create a copy of UserMembership with updated fields
extension UserMembershipCopy on UserMembership {
  UserMembership copyWith({
    String? userMembershipId,
    String? userId,
    String? planId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? status,
    double? amountPaid,
    String? paymentMethod,
    DateTime? lastPaymentDate,
  }) {
    return UserMembership(
      userMembershipId: userMembershipId ?? this.userMembershipId,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      type: type ?? this.type,
    );
  }
}
