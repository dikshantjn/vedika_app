import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import '../models/MembershipPlan.dart';

class MembershipService {
  static final Dio _dio = Dio();
  
  // Mock user membership data (keeping this for now as it's not in the API response)
  static UserMembership? _currentUserMembership;

  /// Get all available membership plans from API
  static Future<List<MembershipPlan>> getAllPlans() async {
    try {
      final response = await _dio.get(ApiEndpoints.getMembershipPlans);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> plansData = response.data;
        return plansData.map((planJson) => MembershipPlan.fromJson(planJson)).toList();
      } else {
        throw Exception('Failed to fetch membership plans');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching membership plans: $e');
    }
  }

  /// Get a specific plan by ID
  static Future<MembershipPlan?> getPlanById(String planId) async {
    try {
      final plans = await getAllPlans();
      return plans.firstWhere((plan) => plan.membershipPlanId == planId);
    } catch (e) {
      return null;
    }
  }

  /// Get user's current membership
  /// Returns null if user has no active membership plan (404 response)
  /// Returns UserMembership object if user has an active plan
  static Future<UserMembership?> getCurrentUserMembership(String userId) async {
    try {
      final url = ApiEndpoints.userCurrentMembership(userId);
      // print('Current membership endpoint: $url');
      final response = await _dio.get(
        url,
        options: Options(
          // Accept 404 as valid response - it means user has no active membership plan
          validateStatus: (status) => status! < 500,
        ),
      );
      // Handle 404 - user has no active membership plan
      if (response.statusCode == 404) {
        // This is not an error - user simply has no active membership plan
        return null;
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['currentPlan'] != null) {
          final cp = data['currentPlan'];
          final planDetails = cp['planDetails'] ?? {};
          // Map backend shape into our UserMembership model
          _currentUserMembership = UserMembership(
            userMembershipId: 'current_${userId}',
            userId: userId,
            planId: (cp['planId'] ?? planDetails['membershipPlanId'] ?? '').toString(),
            planName: (cp['planName'] ?? planDetails['name'] ?? '').toString(),
            startDate: DateTime.tryParse(cp['startDate'] ?? '') ?? DateTime.now(),
            endDate: DateTime.tryParse(cp['endDate'] ?? '') ?? DateTime.now(),
            isActive: (cp['status'] ?? '').toString().toLowerCase() == 'paid',
            status: (cp['status'] ?? '').toString(),
            amountPaid: (cp['amountPaid'] is num) ? (cp['amountPaid'] as num).toDouble() : 0.0,
            paymentMethod: 'razorpay',
            lastPaymentDate: DateTime.tryParse(cp['endDate'] ?? ''),
            type: '',
          );
          return _currentUserMembership;
        }
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      // If it's a 404, it means no plan found (not an error)
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching current membership: $e');
    }
  }

  /// Check if user has active membership
  static Future<bool> hasActiveMembership(String userId) async {
    final membership = await getCurrentUserMembership(userId);
    return membership?.isActive == true && !membership!.isExpired;
  }

  /// Purchase a membership plan
  static Future<bool> purchasePlan(String userId, String planId, String paymentMethod) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate payment processing
    
    final plan = await getPlanById(planId);
    if (plan == null) return false;

    // Create new membership
    _currentUserMembership = UserMembership(
      userMembershipId: 'membership_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      planId: plan.membershipPlanId,
      planName: plan.name,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 365)), // 1 year
      isActive: true,
      status: 'active',
      amountPaid: plan.price,
      paymentMethod: paymentMethod,
      lastPaymentDate: DateTime.now(),
      type: plan.type,
    );

    return true;
  }

  /// Cancel membership
  static Future<bool> cancelMembership(String membershipId) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    if (_currentUserMembership?.userMembershipId == membershipId) {
      _currentUserMembership = UserMembership(
        userMembershipId: _currentUserMembership!.userMembershipId,
        userId: _currentUserMembership!.userId,
        planId: _currentUserMembership!.planId,
        planName: _currentUserMembership!.planName,
        startDate: _currentUserMembership!.startDate,
        endDate: _currentUserMembership!.endDate,
        isActive: false,
        status: 'cancelled',
        amountPaid: _currentUserMembership!.amountPaid,
        paymentMethod: _currentUserMembership!.paymentMethod,
        lastPaymentDate: _currentUserMembership!.lastPaymentDate,
        type: _currentUserMembership!.type
      );
      return true;
    }
    return false;
  }

  /// Get membership benefits for a specific plan
  static Future<List<MembershipFeature>> getPlanBenefits(String planId) async {
    await Future.delayed(Duration(milliseconds: 200));
    final plan = await getPlanById(planId);
    return plan?.features ?? [];
  }

  /// Check if user can use a specific benefit
  static Future<bool> canUseBenefit(String userId, String benefitId) async {
    final membership = await getCurrentUserMembership(userId);
    if (membership == null || !membership.isActive || membership.isExpired) {
      return false;
    }

    final plan = await getPlanById(membership.planId);
    if (plan == null) return false;

    return plan.features.any((feature) => feature.id == benefitId && feature.isIncluded);
  }

  /// Get comparison data for all plans
  static Future<Map<String, List<MembershipFeature>>> getComparisonData() async {
    try {
      final plans = await getAllPlans();
      Map<String, List<MembershipFeature>> comparison = {};
      for (var plan in plans) {
        comparison[plan.membershipPlanId] = plan.features;
      }
      return comparison;
    } catch (e) {
      throw Exception('Error fetching comparison data: $e');
    }
  }

  /// Get popular plan
  static Future<MembershipPlan?> getPopularPlan() async {
    try {
      final plans = await getAllPlans();
      return plans.firstWhere((plan) => plan.isPopular);
    } catch (e) {
      return null;
    }
  }

  /// Renew membership
  static Future<bool> renewMembership(String membershipId, String paymentMethod) async {
    await Future.delayed(Duration(seconds: 1));
    
    if (_currentUserMembership?.userMembershipId == membershipId) {
      final plan = await getPlanById(_currentUserMembership!.planId);
      if (plan == null) return false;

      _currentUserMembership = UserMembership(
        userMembershipId: _currentUserMembership!.userMembershipId,
        userId: _currentUserMembership!.userId,
        planId: _currentUserMembership!.planId,
        planName: _currentUserMembership!.planName,
        startDate: _currentUserMembership!.endDate,
        endDate: _currentUserMembership!.endDate.add(Duration(days: 365)),
        isActive: true,
        status: 'active',
        amountPaid: plan.price,
        paymentMethod: paymentMethod,
        lastPaymentDate: DateTime.now(),
        type: _currentUserMembership!.type
      );
      return true;
    }
    return false;
  }
}
