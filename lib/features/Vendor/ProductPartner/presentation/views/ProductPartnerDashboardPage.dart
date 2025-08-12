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
                const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
                _buildAnalysisSections(context, viewModel),
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
                  child: viewModel.profilePicture.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            viewModel.profilePicture,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: ProductPartnerColorPalette.primary,
                              size: 24,
                            ),
                          ),
                        )
                      : Text(
                          viewModel.partnerName.isNotEmpty
                              ? viewModel.partnerName[0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ProductPartnerColorPalette.primary,
                          ),
                        ),
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

  Widget _buildAnalysisSections(BuildContext context, ProductPartnerDashboardViewModel viewModel) {
    final analysis = viewModel.analysisData;
    if (analysis == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _analysisCard(
          context,
          'Demand & Sales Trends',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Order volume trend (Weekly)'),
              const SizedBox(height: 8),
              SizedBox(height: 140, child: _lineChartFromIntList(analysis.demandSalesTrends.orderVolumeTrendWeekly)),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Product category performance'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _barChartFromDoubleMap(analysis.demandSalesTrends.productCategoryPerformance)),
              _subDivider(),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('First-time vs Repeat buyers'),
                  const SizedBox(height: 8),
                  _stackedRatioBar(
                    firstValue: analysis.demandSalesTrends.firstTimeToRepeatBuyerRatio,
                    secondValue: 1.0,
                    firstLabel: 'First-time',
                    secondLabel: 'Repeat',
                    colors: [ProductPartnerColorPalette.info, ProductPartnerColorPalette.success],
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('Bulk vs Single orders'),
                  const SizedBox(height: 8),
                  _stackedRatioBar(
                    firstValue: analysis.demandSalesTrends.bulkToSingleOrderRatio,
                    secondValue: 1 - analysis.demandSalesTrends.bulkToSingleOrderRatio,
                    firstLabel: 'Bulk',
                    secondLabel: 'Single',
                    colors: [ProductPartnerColorPalette.warning, ProductPartnerColorPalette.primary],
                  ),
                ],
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Fast vs Slow moving'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...analysis.demandSalesTrends.fastMovingProducts.map((p) => _chip(context, 'Fast: $p')),
                  ...analysis.demandSalesTrends.slowMovingProducts.map((p) => _chip(context, 'Slow: $p')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
        _analysisCard(
          context,
          'Inventory Insights',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Stock-out frequency'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _barChartFromIntMap(analysis.inventoryInsights.stockOutFrequencyPerProduct)),
              _subDivider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _metricTile('Inventory turnover', analysis.inventoryInsights.inventoryTurnoverRate.toStringAsFixed(1))),
                  const SizedBox(width: 12),
                  Expanded(child: _metricTile('Overstock items', analysis.inventoryInsights.overstockAlerts.length.toString())),
                ],
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Days of stock left'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _barChartFromIntMap(analysis.inventoryInsights.daysOfStockLeft)),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Overstock alerts'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.inventoryInsights.overstockAlerts.map((p) => _chip(context, p)).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
        _analysisCard(
          context,
          'Operational Efficiency',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _metricTile('Confirm time', '${analysis.operationalEfficiency.averageTimeToConfirmHours.toStringAsFixed(1)} h')),
                  const SizedBox(width: 12),
                  Expanded(child: _metricTile('Order → dispatch', '${analysis.operationalEfficiency.averageTimeOrderToDispatchHours.toStringAsFixed(1)} h')),
                ],
              ),
              _subDivider(),
              const SizedBox(height: 12),
               _sectionLabel('Return/Refund reasons'),
               const SizedBox(height: 8),
               _horizontalBarsFromIntMap(analysis.operationalEfficiency.returnRefundReasons),
               _subDivider(),
               const SizedBox(height: 12),
               _sectionLabel('Delivery success (1st attempt)'),
               const SizedBox(height: 8),
               _stackedRatioBar(
                 firstValue: analysis.operationalEfficiency.deliverySuccessRateFirstAttempt,
                 secondValue: 1 - analysis.operationalEfficiency.deliverySuccessRateFirstAttempt,
                 firstLabel: 'Success',
                 secondLabel: 'Fail',
                 colors: [ProductPartnerColorPalette.success, ProductPartnerColorPalette.error],
               ),
            ],
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
        _analysisCard(
          context,
          'Customer Behavior & Geography',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Top customers by order value'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _barChartFromDoubleMap({
                  for (final c in analysis.customerBehaviorGeography.topCustomersByOrderValue)
                    c['name'] as String: c['value'] as double
                }),
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('High-demand regions by product type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.customerBehaviorGeography.highDemandRegionsByProductType.entries
                    .expand((e) => e.value.map((r) => _chip(context, '${e.key}: $r')))
                    .toList(),
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Customer purchase patterns'),
              const SizedBox(height: 8),
              ...analysis.customerBehaviorGeography.purchasePatterns.map(_bulletText),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Geographic product preference'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.customerBehaviorGeography.geographicProductPreference.entries
                    .expand((e) => e.value.map((p) => _chip(context, '${e.key}: $p')))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
        _analysisCard(
          context,
          'Revenue & Profitability',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Revenue by product'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _barChartFromDoubleMap(analysis.revenueProfitability.revenueByProduct)),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Profit margins by item'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _barChartFromDoubleMap(analysis.revenueProfitability.profitMarginsByItem.map((k, v) => MapEntry(k, v * 100)))),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Revenue by category & region'),
              const SizedBox(height: 8),
              SizedBox(height: 160, child: _barChartFromDoubleMap(analysis.revenueProfitability.revenueByCategory)),
              const SizedBox(height: 8),
              SizedBox(height: 160, child: _barChartFromDoubleMap(analysis.revenueProfitability.revenueByRegion)),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Seasonal revenue shifts'),
              const SizedBox(height: 8),
              SizedBox(height: 140, child: _lineChartFromDoubleMap(analysis.revenueProfitability.seasonalRevenueShifts)),
            ],
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.largeSpacing),
        _analysisCard(
          context,
          'Predictive & Strategic Insights',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Impact of promotions (uplift)'),
              const SizedBox(height: 8),
              SizedBox(height: 160, child: _barChartFromDoubleMap(analysis.predictiveStrategicInsights.promotionsImpactUpliftPercent)),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Restock prediction alerts'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.predictiveStrategicInsights.restockPredictionAlerts.map((t) => _chip(context, t)).toList(),
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Cross-selling recommendations'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.predictiveStrategicInsights.crossSellingRecommendations.entries
                    .expand((e) => e.value.map((v) => _chip(context, '${e.key} → $v')))
                    .toList(),
              ),
              _subDivider(),
              const SizedBox(height: 12),
              _sectionLabel('Emerging product demand'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.predictiveStrategicInsights.emergingProductDemand
                    .map((p) => _chip(context, p))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analysisCard(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ProductPartnerColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: ProductPartnerColorPalette.spacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ProductPartnerColorPalette.spacing),
          decoration: BoxDecoration(
            color: ProductPartnerColorPalette.surface,
            borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
            border: Border.all(color: ProductPartnerColorPalette.border.withOpacity(0.8), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: ProductPartnerColorPalette.border.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _kvRow(String keyText, String valueText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              keyText,
              style: TextStyle(color: ProductPartnerColorPalette.textSecondary),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              color: ProductPartnerColorPalette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: ProductPartnerColorPalette.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ProductPartnerColorPalette.quickActionBg,
        border: Border.all(color: ProductPartnerColorPalette.quickActionBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ProductPartnerColorPalette.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: ProductPartnerColorPalette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // Charts and tiles helpers
  Widget _subDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Divider(color: ProductPartnerColorPalette.divider, height: 1),
    );
  }

  Widget _metricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ProductPartnerColorPalette.quickActionBg,
        borderRadius: BorderRadius.circular(ProductPartnerColorPalette.cardBorderRadius),
        border: Border.all(color: ProductPartnerColorPalette.quickActionBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: ProductPartnerColorPalette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: ProductPartnerColorPalette.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _lineChartFromIntList(List<int> values) {
    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i].toDouble())
    ];
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => Text('D${value.toInt() + 1}', style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: ProductPartnerColorPalette.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, color: ProductPartnerColorPalette.primary.withOpacity(0.15)),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _lineChartFromDoubleMap(Map<String, double> map) {
    final keys = map.keys.toList();
    final spots = [
      for (int i = 0; i < keys.length; i++) FlSpot(i.toDouble(), (map[keys[i]] ?? 0).toDouble())
    ];
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                return Text(keys[idx], style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: ProductPartnerColorPalette.info,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, color: ProductPartnerColorPalette.info.withOpacity(0.15)),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _barChartFromDoubleMap(Map<String, double> map) {
    final keys = map.keys.toList();
    final maxY = (map.values.isEmpty ? 0 : map.values.reduce((a, b) => a > b ? a : b)) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 1 : maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                final label = keys[idx];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label.length > 8 ? '${label.substring(0, 8)}…' : label,
                    style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: ProductPartnerColorPalette.textSecondary)),
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < keys.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (map[keys[i]] ?? 0).toDouble(),
                  color: ProductPartnerColorPalette.primary,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _barChartFromIntMap(Map<String, int> map) {
    final asDouble = map.map((k, v) => MapEntry(k, v.toDouble()));
    return _barChartFromDoubleMap(asDouble);
  }

  // Removed pie/donut usage per request. Replaced with ratio bars and horizontal bars.

  Widget _stackedRatioBar({
    required double firstValue,
    required double secondValue,
    required String firstLabel,
    required String secondLabel,
    required List<Color> colors,
  }) {
    final total = (firstValue + secondValue);
    final a = total == 0 ? 0.0 : firstValue / total;
    final b = total == 0 ? 0.0 : secondValue / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ProductPartnerColorPalette.quickActionBg,
            border: Border.all(color: ProductPartnerColorPalette.quickActionBorder),
          ),
          child: Row(
            children: [
              Expanded(
                flex: (a * 1000).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[0],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      bottomLeft: const Radius.circular(10),
                      topRight: Radius.circular(b == 0 ? 10 : 0),
                      bottomRight: Radius.circular(b == 0 ? 10 : 0),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (b * 1000).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[1],
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                      topLeft: Radius.circular(a == 0 ? 10 : 0),
                      bottomLeft: Radius.circular(a == 0 ? 10 : 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _legendDot(colors[0], '$firstLabel ${(a * 100).toStringAsFixed(0)}%'),
            _legendDot(colors[1], '$secondLabel ${(b * 100).toStringAsFixed(0)}%'),
          ],
        )
      ],
    );
  }

  Widget _horizontalBarsFromIntMap(Map<String, int> map) {
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.isEmpty ? 1 : entries.first.value;
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: TextStyle(color: ProductPartnerColorPalette.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: ProductPartnerColorPalette.quickActionBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ProductPartnerColorPalette.quickActionBorder),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (e.value / maxVal).clamp(0, 1).toDouble(),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: ProductPartnerColorPalette.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    e.value.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(color: ProductPartnerColorPalette.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: ProductPartnerColorPalette.textSecondary, fontSize: 12)),
      ],
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