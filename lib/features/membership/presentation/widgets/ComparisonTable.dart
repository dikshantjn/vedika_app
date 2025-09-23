import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import '../../data/models/MembershipPlan.dart';
import 'package:vedika_healthcare/features/membership/presentation/utils/PlanVisuals.dart';

class ComparisonTable extends StatelessWidget {
  final List<MembershipPlan> plans;
  final Map<String, List<MembershipFeature>> featuresByCategory;
  final String Function(String, String) getFeatureValueForPlan;
  final bool Function(String, String) isFeatureIncludedInPlan;
  final Function(MembershipPlan) onPlanSelect;
  final bool hasActiveMembership;
  final String? currentPlanId;

  const ComparisonTable({
    Key? key,
    required this.plans,
    required this.featuresByCategory,
    required this.getFeatureValueForPlan,
    required this.isFeatureIncludedInPlan,
    required this.onPlanSelect,
    required this.hasActiveMembership,
    this.currentPlanId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16),
        _buildPlansHeader(),
        SizedBox(height: 16),
        _buildComparisonSections(),
        SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare Plans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose the plan that best fits your healthcare needs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Feature column header
          Container(
            width: 180,
            padding: EdgeInsets.all(16),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Plan headers
          ...plans.map((plan) => _buildPlanHeader(plan)),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(MembershipPlan plan) {
    final isCurrentPlan = currentPlanId == plan.membershipPlanId;
    
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PlanVisuals.gradientStart(plan.type),
            PlanVisuals.gradientEnd(plan.type),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PlanVisuals.primaryColor(plan.type).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            PlanVisuals.emoji(plan.type),
            style: TextStyle(fontSize: 32),
          ),
          SizedBox(height: 8),
          Text(
            plan.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            '₹${plan.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '/${plan.duration}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (plan.isPopular && plan.popularBadge != null)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                plan.popularBadge!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          if (isCurrentPlan)
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonSections() {
    return Column(
      children: featuresByCategory.entries.map((entry) {
        return _buildCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(String category, List<MembershipFeature> features) {
    final categoryNames = {
      'consultation': 'Consultations',
      'lab': 'Lab Tests',
      'medicine': 'Medicines',
      'booking': 'Booking',
      'checkup': 'Health Checkups',
      'support': 'Support Services',
      'emergency': 'Emergency Services',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            categoryNames[category] ?? category.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorPalette.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        ...features.map((feature) => _buildFeatureRow(feature)),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureRow(MembershipFeature feature) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Feature name
          Container(
            width: 180,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                if (feature.description.isNotEmpty)
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          // Feature values for each plan
          ...plans.map((plan) => _buildFeatureCell(plan, feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureCell(MembershipPlan plan, MembershipFeature feature) {
    final isIncluded = isFeatureIncludedInPlan(plan.membershipPlanId, feature.title);
    final value = getFeatureValueForPlan(plan.membershipPlanId, feature.title);

    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isIncluded 
            ? PlanVisuals.primaryColor(plan.type).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isIncluded 
              ? PlanVisuals.primaryColor(plan.type).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              isIncluded ? Icons.check_circle : Icons.cancel,
              color: isIncluded 
                  ? PlanVisuals.primaryColor(plan.type)
                  : Colors.grey[400],
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isIncluded 
                    ? PlanVisuals.primaryColor(plan.type)
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: 180,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Plan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...plans.map((plan) => _buildActionButton(plan)),
        ],
      ),
    );
  }

  Widget _buildActionButton(MembershipPlan plan) {
    final isCurrentPlan = currentPlanId == plan.membershipPlanId;
    final canSelect = !hasActiveMembership || isCurrentPlan;

    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: canSelect && !isCurrentPlan ? () => onPlanSelect(plan) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentPlan 
              ? Colors.grey[400]
              : (canSelect 
                  ? PlanVisuals.primaryColor(plan.type)
                  : Colors.grey[300]),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isCurrentPlan 
              ? 'Current'
              : (hasActiveMembership 
                  ? 'Upgrade'
                  : 'Select'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
