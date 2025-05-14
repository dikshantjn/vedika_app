import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/colorpalette/ProductPartnerColorPalette.dart';
import '../viewmodels/ProductPartnerDashboardViewModel.dart';

class ProductPartnerDashboardPage extends StatelessWidget {
  final String vendorId;
  
  const ProductPartnerDashboardPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductPartnerDashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          color: ProductPartnerColorPalette.primary,
          onRefresh: () async {
            await viewModel.refreshDashboard(vendorId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(context, viewModel),
                const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
                _buildOverviewCards(context, viewModel),
                const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
                _buildQuickActions(context),
                const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
                _buildRecentActivity(context, viewModel),
                const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
                _buildPerformanceChart(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, ProductPartnerDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProductPartnerColorPalette.primary,
            ProductPartnerColorPalette.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.borderRadius),
        boxShadow: ProductPartnerColorPalette.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: ProductPartnerColorPalette.background,
                  backgroundImage: viewModel.profilePicture.isNotEmpty
                      ? NetworkImage(viewModel.profilePicture)
                      : null,
                  child: viewModel.profilePicture.isEmpty
                      ? Text(
                          viewModel.partnerName.isNotEmpty
                              ? viewModel.partnerName[0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ProductPartnerColorPalette.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.partnerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (viewModel.companyLegalName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      viewModel.companyLegalName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: viewModel.isStatusLoading ? null : () async {
                  final newStatus = await viewModel.toggleVendorStatus();
                  if (newStatus != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newStatus ? 'Vendor activated successfully' : 'Vendor deactivated successfully',
                        ),
                        backgroundColor: newStatus 
                            ? ProductPartnerColorPalette.success 
                            : ProductPartnerColorPalette.error,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (viewModel.isStatusLoading)
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: viewModel.isActive 
                              ? ProductPartnerColorPalette.success
                              : ProductPartnerColorPalette.error,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        viewModel.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.email.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You have ${viewModel.pendingOrders} pending orders to process',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to orders page
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(
                      color: ProductPartnerColorPalette.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, ProductPartnerDashboardViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: ProductPartnerColorPalette.spacing,
      crossAxisSpacing: ProductPartnerColorPalette.spacing,
      childAspectRatio: 1.5,
      children: [
        _buildStatBox(
          context,
          'Total Products',
          viewModel.totalProducts.toString(),
          Icons.inventory_2_outlined,
          ProductPartnerColorPalette.productsBox,
          ProductPartnerColorPalette.primary,
        ),
        _buildStatBox(
          context,
          "Today's Revenue",
          '\$${viewModel.todayRevenue.toStringAsFixed(2)}',
          Icons.attach_money,
          ProductPartnerColorPalette.revenueBox,
          ProductPartnerColorPalette.success,
        ),
        _buildStatBox(
          context,
          'Pending Orders',
          viewModel.pendingOrders.toString(),
          Icons.pending_actions,
          ProductPartnerColorPalette.ordersBox,
          ProductPartnerColorPalette.warning,
        ),
        _buildStatBox(
          context,
          'Low Stock Items',
          viewModel.lowStockItems.toString(),
          Icons.warning_amber_rounded,
          ProductPartnerColorPalette.inventoryBox,
          ProductPartnerColorPalette.error,
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String title, String value,
      IconData icon, Color backgroundColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
      ),
      padding: const EdgeInsets.all(ProductPartnerColorPalette.smallSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ProductPartnerColorPalette.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ProductPartnerColorPalette.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ProductPartnerColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.spacing),
        Container(
          padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
          decoration: BoxDecoration(
            color: ProductPartnerColorPalette.quickActionBg,
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
            border: Border.all(color: ProductPartnerColorPalette.quickActionBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                context,
                Icons.add_circle_outline,
                'Add Product',
                ProductPartnerColorPalette.primary,
              ),
              _buildQuickActionButton(
                context,
                Icons.inventory_2_outlined,
                'Inventory',
                ProductPartnerColorPalette.success,
              ),
              _buildQuickActionButton(
                context,
                Icons.shopping_cart_outlined,
                'Orders',
                ProductPartnerColorPalette.warning,
              ),
              _buildQuickActionButton(
                context,
                Icons.analytics_outlined,
                'Reports',
                ProductPartnerColorPalette.info,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        // Handle action
      },
      borderRadius: BorderRadius.circular(ProductPartnerColorPalette.buttonBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(ProductPartnerColorPalette.smallSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: ProductPartnerColorPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, ProductPartnerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all orders
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: ProductPartnerColorPalette.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ProductPartnerColorPalette.spacing),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.recentActivities.length,
          itemBuilder: (context, index) {
            final activity = viewModel.recentActivities[index];
            return Container(
              margin: const EdgeInsets.only(bottom: ProductPartnerColorPalette.smallSpacing),
              decoration: BoxDecoration(
                color: ProductPartnerColorPalette.surface,
                borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
                border: Border.all(color: ProductPartnerColorPalette.border),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(activity['status'] as String).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(activity['status'] as String),
                    color: _getStatusColor(activity['status'] as String),
                  ),
                ),
                title: Text(
                  activity['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ProductPartnerColorPalette.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      activity['description'] as String,
                      style: TextStyle(
                        color: ProductPartnerColorPalette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(activity['status'] as String).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity['status'] as String,
                            style: TextStyle(
                              color: _getStatusColor(activity['status'] as String),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: ProductPartnerColorPalette.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            color: ProductPartnerColorPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(BuildContext context, ProductPartnerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ProductPartnerColorPalette.textPrimary,
              ),
            ),
            DropdownButton<String>(
              value: 'Weekly',
              items: ['Daily', 'Weekly', 'Monthly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.updatePerformancePeriod(value);
                }
              },
              underline: const SizedBox(),
              style: TextStyle(
                color: ProductPartnerColorPalette.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: ProductPartnerColorPalette.spacing),
        Container(
          height: 250,
          padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
          decoration: BoxDecoration(
            color: ProductPartnerColorPalette.surface,
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
            border: Border.all(color: ProductPartnerColorPalette.border),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: ProductPartnerColorPalette.divider,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: ProductPartnerColorPalette.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: viewModel.performanceData,
                  isCurved: true,
                  color: ProductPartnerColorPalette.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: ProductPartnerColorPalette.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ProductPartnerColorPalette.primary.withOpacity(0.3),
                        ProductPartnerColorPalette.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return ProductPartnerColorPalette.success;
      case 'pending':
        return ProductPartnerColorPalette.warning;
      case 'cancelled':
        return ProductPartnerColorPalette.error;
      default:
        return ProductPartnerColorPalette.info;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending_actions;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
} 