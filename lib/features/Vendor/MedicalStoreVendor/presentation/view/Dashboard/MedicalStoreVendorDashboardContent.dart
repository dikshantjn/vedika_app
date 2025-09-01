import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/widgets/OrdersRevenueChart.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicalStoreAnalyticsModel.dart';
import 'package:shimmer/shimmer.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<void> _fetchDataFuture;
  bool _isLoading = true;
  bool _showAiSuggestion = true;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Widget _buildAiSuggestionCard(MedicalStoreVendorDashboardViewModel viewModel) {
    // VedikaAI-styled gradient and subtle neon glow
    final Color primary = const Color(0xFF6C5CE7); // VedikaAI purple
    final Color secondary = const Color(0xFF00D1FF); // Cyan
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.15),
            secondary.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.psychology_alt_rounded,
              color: primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VedikaAI Suggestion',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primary,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _showAiSuggestion = false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  // Dummy AI message tailored to store operations
                  'Demand spike predicted 5–7 PM for fever and cold medicines. Consider pre-packing top 3 SKUs and enabling express delivery to reduce fulfillment time by ~18%.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    final viewModel = Provider.of<MedicalStoreVendorDashboardViewModel>(context, listen: false);
    await viewModel.fetchOrdersAndRequests();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerEffect();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        return Consumer<MedicalStoreVendorDashboardViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(viewModel),
                  const SizedBox(height: 16),
                  _buildTimeFilterSection(viewModel),
                  if (_showAiSuggestion) ...[
                    const SizedBox(height: 16),
                    _buildAiSuggestionCard(viewModel),
                  ],
                  const SizedBox(height: 24),
                  _buildCombinedInsightsSection(viewModel),
                  const SizedBox(height: 24),
                  _buildChartsSection(viewModel),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeCard(MedicalStoreVendorDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MedicalStoreVendorColorPalette.primaryColor,
            MedicalStoreVendorColorPalette.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MedicalStoreVendorColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.local_pharmacy,
                  color: MedicalStoreVendorColorPalette.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                      viewModel.storeName ?? 'Medical Store',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: viewModel.isActive 
                          ? MedicalStoreVendorColorPalette.successColor
                          : MedicalStoreVendorColorPalette.errorColor,
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
            ],
          ),
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
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You have ${viewModel.analytics.totalOrders} orders to process',
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
                      color: MedicalStoreVendorColorPalette.primaryColor,
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

  Widget _buildTimeFilterSection(MedicalStoreVendorDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MedicalStoreVendorColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: viewModel.timeFilterOptions.map((filter) {
              bool isSelected = viewModel.selectedTimeFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await viewModel.updateTimeFilter(filter);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? MedicalStoreVendorColorPalette.primaryColor 
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? MedicalStoreVendorColorPalette.primaryColor 
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? Colors.white 
                            : MedicalStoreVendorColorPalette.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedInsightsSection(MedicalStoreVendorDashboardViewModel viewModel) {
    final insights = viewModel.insights;
    final analytics = viewModel.analytics;
    if (insights == null) return const SizedBox.shrink();

    // Build a unified list of cards while removing duplicates
    // Duplicates mapping:
    // - Total Orders (analytics.totalOrders) vs Total Orders Received (insights.totalOrdersReceived) -> show once as "Total Orders"
    // Other items remain unique.

    final List<_InsightItem> items = [];

    // Total Orders (merged)
    items.add(_InsightItem(
      icon: Icons.shopping_cart,
      label: 'Total Orders',
      value: (analytics.totalOrders > 0
              ? analytics.totalOrders
              : insights.totalOrdersReceived)
          .toString(),
    ));

    // Average Order Value
    items.add(_InsightItem(
      icon: Icons.monetization_on,
      label: 'Average Order Value',
      value: '₹${analytics.averageOrderValue}',
    ));

    // Orders Today
    items.add(_InsightItem(
      icon: Icons.today,
      label: 'Orders Today',
      value: analytics.ordersToday.toString(),
    ));

    // Returns This Week
    items.add(_InsightItem(
      icon: Icons.refresh,
      label: 'Returns This Week',
      value: analytics.returnsThisWeek.toString(),
    ));

    // Orders Confirmed
    items.add(_InsightItem(
      icon: Icons.verified_rounded,
      label: 'Orders Confirmed',
      value: insights.ordersConfirmed.toString(),
    ));

    // Avg Time to Fulfill Prescription
    items.add(_InsightItem(
      icon: Icons.schedule_rounded,
      label: 'Avg Time to Fulfill Prescription',
      value: insights.avgTimeToFulfillPrescription,
    ));

    // Most Ordered Medicine
    items.add(_InsightItem(
      icon: Icons.medication_rounded,
      label: 'Most Ordered Medicine',
      value: insights.mostOrderedMedicine,
    ));

    // Unavailable Requests This Week
    items.add(_InsightItem(
      icon: Icons.remove_shopping_cart_rounded,
      label: 'Unavailable Requests This Week',
      value: insights.unavailableRequestsThisWeek.toString(),
    ));

    // Revenue This Month
    items.add(_InsightItem(
      icon: Icons.payments_rounded,
      label: 'Revenue This Month',
      value: '₹${insights.revenueThisMonth.toStringAsFixed(2)}',
    ));

    // Fast-Moving Medicine Count
    items.add(_InsightItem(
      icon: Icons.local_hospital_rounded,
      label: 'Fast-Moving Medicine Count',
      value: insights.fastMovingMedicineCount.toString(),
    ));

    // Repeat Buyers (30 Days)
    items.add(_InsightItem(
      icon: Icons.repeat_rounded,
      label: 'Repeat Buyers (30 Days)',
      value: insights.repeatBuyers30Days.toString(),
    ));

    // Delivery Completion Rate
    items.add(_InsightItem(
      icon: Icons.delivery_dining_rounded,
      label: 'Delivery Completion Rate',
      value: '${insights.deliveryCompletionRate.toStringAsFixed(1)}%',
    ));

    final isTablet = MediaQuery.of(context).size.width >= 600;
    final crossAxisCount = 2; // Always 2 columns per your requirement
    final double aspectRatio = isTablet ? 2.6 : 1.2; // Increase tile height further to avoid overflow

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Analytics & Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MedicalStoreVendorColorPalette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _InsightCard(item: item);
            },
          ),
        ],
      ),
    );
  }

  // Removed old insights builder (merged into combined section)

  // Charts Section
  Widget _buildChartsSection(MedicalStoreVendorDashboardViewModel viewModel) {
    final charts = viewModel.charts;
    if (charts == null) return const SizedBox.shrink();

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orders & Revenue trends
        _buildSectionTitle('Orders & Revenue Trends'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLegendItem(color: Colors.blueGrey, label: 'Orders'),
                  const SizedBox(width: 16),
                  _buildLegendItem(color: Colors.green.shade600, label: 'Revenue'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: OrdersRevenueChart(
                  days: charts.days,
                  dailyOrders: charts.dailyOrders,
                  dailyRevenue: charts.dailyRevenue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Status distribution and completion rate
        if (isTablet)
          Row(
            children: [
              Expanded(child: _buildStatusDistribution(charts)),
              const SizedBox(width: 12),
              Expanded(child: _buildCompletionRate(charts.deliveryCompletionRate)),
            ],
          )
        else ...[
          _buildStatusDistribution(charts),
          const SizedBox(height: 12),
          _buildCompletionRate(charts.deliveryCompletionRate),
        ],

        const SizedBox(height: 24),

        // Top medicines (Region demand removed per request)
        _buildSectionTitle('Top Medicines'),
        const SizedBox(height: 12),
        _buildTopMedicines(charts.topMedicines),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution(charts) {
    final data = charts.orderStatusCounts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Order Status Distribution'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.entries.map<Widget>((e) {
              return Column(
                children: [
                  Container(
                    width: 16,
                    height: (e.value.clamp(0, 20)) * 6.0 + 10,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.7 - (0.05 * (e.key.hashCode % 5))),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e.key,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  Text(
                    e.value.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRate(double percentage) {
    final color = Colors.green.shade600;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Delivery Completion Rate'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0, 1),
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMedicines(List<Map<String, dynamic>> topMedicines) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: topMedicines.map((m) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_rounded, size: 18, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m['name'],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${m['orders']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionDemand(List<Map<String, dynamic>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Region Demand'),
          const SizedBox(height: 12),
          Column(
            children: data.map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        c['city'],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (c['percentage'] as num).toDouble() / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${c['percentage']}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Simple dual-series line/area chart using CustomPainter

  Widget _buildAnalyticsCard(MedicalStoreAnalyticsModel analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnalyticsHeader(),
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

  Widget _buildAnalyticsHeader() {
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
            onPressed: () {
              // Navigate to detailed analytics
            },
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: MedicalStoreVendorColorPalette.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MedicalStoreVendorColorPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _fetchDataFuture = _fetchData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      period: const Duration(milliseconds: 1500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card Shimmer
            _buildWelcomeCardShimmer(),
            const SizedBox(height: 16),

            // Time Filter Section Shimmer
            _buildTimeFilterShimmer(),
            const SizedBox(height: 16),

            // AI Suggestion Card Shimmer (conditionally shown)
            if (_showAiSuggestion) ...[
              _buildAiSuggestionShimmer(),
              const SizedBox(height: 16),
            ],

            // Analytics & Insights Section Shimmer
            _buildAnalyticsInsightsShimmer(),
            const SizedBox(height: 24),

            // Charts Section Shimmer
            _buildChartsSectionShimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar shimmer
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome text
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Store name
                    Container(
                      height: 18,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 12,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bottom info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 12,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
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

  Widget _buildTimeFilterShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            height: 16,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Filter buttons
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.grey[400] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: 12,
                      width: index == 0 ? 50 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionShimmer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    // Close button
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description text (multiple lines)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(2, (index) => Container(
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: index == 0 ? 1.0 : 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsInsightsShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Container(
            height: 18,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 16),

          // Grid of insight cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: 12, // Approximate number of insights
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and label row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Value
                              Container(
                                height: 18,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Sparkline indicator
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const Expanded(flex: 4, child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSectionShimmer() {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Charts title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 18,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        const SizedBox(height: 12),

        // Orders & Revenue Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend
              Row(
                children: [
                  _buildLegendShimmerItem(),
                  const SizedBox(width: 16),
                  _buildLegendShimmerItem(),
                ],
              ),
              const SizedBox(height: 12),
              // Chart area
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 60.0,
                      top: 20 + (index % 3) * 40.0,
                      child: Container(
                        width: 40,
                        height: 80 + (index % 2) * 40.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Status distribution and completion rate
        if (isTablet)
          Row(
            children: [
              Expanded(child: _buildStatusDistributionShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildCompletionRateShimmer()),
            ],
          )
        else ...[
          _buildStatusDistributionShimmer(),
          const SizedBox(height: 12),
          _buildCompletionRateShimmer(),
        ],

        const SizedBox(height: 24),

        // Top medicines
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Container(
                height: 18,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              const SizedBox(height: 12),
              // Medicine items
              Column(
                children: List.generate(5, (index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6.5),
                            ),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendShimmerItem() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 12,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDistributionShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            height: 18,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 12),
          // Chart bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return Column(
                children: [
                  Container(
                    width: 16,
                    height: 40 + (index % 3) * 20.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 25,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 10,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Container(
            height: 18,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 14,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightItem {
  final IconData icon;
  final String label;
  final String value;

  const _InsightItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InsightCard extends StatelessWidget {
  final _InsightItem item;
  const _InsightCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 110),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              item.icon,
              color: Colors.grey.shade800,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
                    Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // Mock sparkline / indicator
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const Expanded(flex: 35, child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
