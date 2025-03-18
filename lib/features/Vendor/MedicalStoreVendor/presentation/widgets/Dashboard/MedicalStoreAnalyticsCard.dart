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
        const SizedBox(height: 10),
        GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5, // Balanced aspect ratio
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildAnalyticsBox(
              title: "Total Orders",
              value: analytics.totalOrders.toString(),
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            _buildAnalyticsBox(
              title: "Average Order Value",
              value: "₹${analytics.averageOrderValue}",
              icon: Icons.monetization_on,
              color: Colors.green,
            ),
            _buildAnalyticsBox(
              title: "Returns This Week",
              value: analytics.returnsThisWeek.toString(),
              icon: Icons.refresh,
              color: Colors.red,
            ),
            _buildAnalyticsBox(
              title: "Orders Today",
              value: analytics.ordersToday.toString(),
              icon: Icons.today,
              color: Colors.orange,
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
          const Text(
            "Analytics Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MedicalStoreVendorColorPalette.secondaryColor,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              "View All",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            offset: const Offset(0, 2), // Soft shadow effect
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
    );
  }
}
