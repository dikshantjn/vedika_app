import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';

class AnalyticsCard extends StatelessWidget {
  final MedicalStoreAnalyticsModel analytics;
  final VoidCallback onViewAll;

  const AnalyticsCard({
    Key? key,
    required this.analytics,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildAnalyticsBox(
              title: "Total Orders",
              value: analytics.totalOrders.toString(),
              icon: Icons.shopping_cart,
              color: MedicalStoreVendorColorPalette.primaryColor,
            ),
            _buildAnalyticsBox(
              title: "Average Order Value",
              value: "₹${analytics.averageOrderValue}",
              icon: Icons.monetization_on,
              color: MedicalStoreVendorColorPalette.successColor,
            ),
            _buildAnalyticsBox(
              title: "Returns This Week",
              value: analytics.returnsThisWeek.toString(),
              icon: Icons.refresh,
              color: MedicalStoreVendorColorPalette.errorColor,
            ),
            _buildAnalyticsBox(
              title: "Orders Today",
              value: analytics.ordersToday.toString(),
              icon: Icons.today,
              color: MedicalStoreVendorColorPalette.secondaryColor,
            ),
          ],
        ),
      ],
    );
  }

  /// 🔹 **Header with "View All" button**
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Analytics Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MedicalStoreVendorColorPalette.textPrimary,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: MedicalStoreVendorColorPalette.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "View All",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Optimized Analytics Box**
  Widget _buildAnalyticsBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MedicalStoreVendorColorPalette.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

