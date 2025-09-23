import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/membership/presentation/utils/PlanVisuals.dart';
import '../../data/models/MembershipPlan.dart';

class PlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPurchase;
  final bool hasActiveMembership;
  final String? currentPlanId;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.onSelect,
    required this.onPurchase,
    required this.hasActiveMembership,
    this.currentPlanId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentPlan = currentPlanId == plan.membershipPlanId;
    final canPurchase = !hasActiveMembership || isCurrentPlan;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlanVisuals.gradientStart(plan.type),
                  PlanVisuals.gradientEnd(plan.type),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: PlanVisuals.primaryColor(plan.type).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: ColorPalette.primaryColor, width: 3)
                    : null,
              ),
              margin: EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildPricing(),
                  _buildDescription(),
                  _buildFeatures(),
                  _buildActionButton(canPurchase, isCurrentPlan),
                ],
              ),
            ),
          ),
          // soft shine overlay
          Positioned(
            top: -20,
            left: -20,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (plan.isPopular && plan.popularBadge != null)
            _buildPopularBadge(),
          if (isCurrentPlan)
            _buildCurrentPlanBadge(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PlanVisuals.gradientStart(plan.type),
                  PlanVisuals.gradientEnd(plan.type),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              PlanVisuals.emoji(plan.type),
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PlanVisuals.primaryColor(plan.type),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricing() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${plan.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: PlanVisuals.primaryColor(plan.type),
            ),
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              '/${plan.duration}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PlanVisuals.gradientStart(plan.type),
                  PlanVisuals.gradientEnd(plan.type),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Yearly Plan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Text(
        plan.description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s included:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          ...plan.highlights.map((highlight) => _buildFeatureItem(highlight)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool canPurchase, bool isCurrentPlan) {
    final bool enabled = canPurchase && !isCurrentPlan;
    return Padding(
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: enabled ? onPurchase : null,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 150),
            opacity: enabled ? 1.0 : 0.6,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isCurrentPlan
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          PlanVisuals.gradientStart(plan.type),
                          PlanVisuals.gradientEnd(plan.type),
                        ],
                      ),
                color: isCurrentPlan ? Colors.grey[400] : null,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text(
                isCurrentPlan
                    ? 'Current Plan'
                    : (hasActiveMembership ? 'Upgrade Required' : 'Choose Plan'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              plan.popularBadge!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
