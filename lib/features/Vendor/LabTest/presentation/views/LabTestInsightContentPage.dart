import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/LabTestAnalyticsViewModel.dart';

class LabTestInsightContentPage extends StatefulWidget {
  const LabTestInsightContentPage({super.key});

  @override
  State<LabTestInsightContentPage> createState() => _InsightsContentState();
}

class _InsightsContentState extends State<LabTestInsightContentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LabTestAnalyticsViewModel>(
      create: (_) => LabTestAnalyticsViewModel()..initialize(),
      child: Consumer<LabTestAnalyticsViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildTimeRangeSelector(vm),
                const SizedBox(height: 16),
                if (vm.isLoading) _buildLoading() else ...[
                  _buildCustomerInsights(vm),
                  const SizedBox(height: 24),
                  _buildDemandAnalysis(vm),
                  const SizedBox(height: 24),
                  _buildOperationalEfficiency(vm),
                  const SizedBox(height: 24),
                  _buildServicePreferences(vm),
                  const SizedBox(height: 24),
                  _buildRevenueAndVolume(vm),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Insights & Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: LabTestColorPalette.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(LabTestAnalyticsViewModel vm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: LabTestColorPalette.primaryBlue,
        unselectedLabelColor: LabTestColorPalette.textSecondary,
        indicatorColor: LabTestColorPalette.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
          Tab(text: 'Year'),
        ],
        onTap: (index) {
          setState(() {
            _selectedTimeRange = ['Day', 'Week', 'Month', 'Year'][index];
          });
          final mapping = {
            'Day': 'Today',
            'Week': 'This Week',
            'Month': 'This Month',
            'Year': 'This Year',
          };
          vm.setPeriod(mapping[_selectedTimeRange] ?? 'Today');
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading analytics...', style: TextStyle(color: LabTestColorPalette.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: LabTestColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: LabTestColorPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredTimes() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preferred Booking Times',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  // TODO: Show info tooltip
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: LabTestColorPalette.textSecondary,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = '9 AM';
                            break;
                          case 1:
                            text = '11 AM';
                            break;
                          case 2:
                            text = '1 PM';
                            break;
                          case 3:
                            text = '3 PM';
                            break;
                          case 4:
                            text = '5 PM';
                            break;
                          default:
                            text = '';
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: LabTestColorPalette.textSecondary,
                          fontSize: 12,
                        );
                        return Text(value.toInt().toString(), style: style);
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: LabTestColorPalette.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 12,
                        color: LabTestColorPalette.primaryBlue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 18,
                        color: LabTestColorPalette.primaryBlue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 8,
                        color: LabTestColorPalette.primaryBlue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 15,
                        color: LabTestColorPalette.primaryBlue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 10,
                        color: LabTestColorPalette.primaryBlue,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTrends() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  // TODO: Show info tooltip
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: LabTestColorPalette.borderLight,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: LabTestColorPalette.borderLight,
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
                        const style = TextStyle(
                          color: LabTestColorPalette.textSecondary,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Mon';
                            break;
                          case 1:
                            text = 'Tue';
                            break;
                          case 2:
                            text = 'Wed';
                            break;
                          case 3:
                            text = 'Thu';
                            break;
                          case 4:
                            text = 'Fri';
                            break;
                          case 5:
                            text = 'Sat';
                            break;
                          case 6:
                            text = 'Sun';
                            break;
                          default:
                            text = '';
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: LabTestColorPalette.textSecondary,
                          fontSize: 12,
                        );
                        return Text(value.toInt().toString(), style: style);
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: LabTestColorPalette.borderLight,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 2),
                      FlSpot(3, 5),
                      FlSpot(4, 3),
                      FlSpot(5, 4),
                      FlSpot(6, 3),
                    ],
                    isCurved: true,
                    color: LabTestColorPalette.primaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: LabTestColorPalette.primaryBlue,
                          strokeWidth: 2,
                          strokeColor: LabTestColorPalette.backgroundPrimary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: LabTestColorPalette.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTests() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Requested Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  // TODO: Show info tooltip
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTestItem('Blood Test', 120, 0.8),
          _buildTestItem('MRI Scan', 85, 0.6),
          _buildTestItem('CT Scan', 65, 0.5),
          _buildTestItem('X-Ray', 45, 0.4),
          _buildTestItem('Ultrasound', 35, 0.3),
        ],
      ),
    );
  }

  Widget _buildTestItem(String name, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: LabTestColorPalette.textPrimary,
                ),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: LabTestColorPalette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: LabTestColorPalette.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                LabTestColorPalette.primaryBlue,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ========================= New Analytics Sections =========================

  Widget _sectionContainer({required String title, required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // A. Customer Insights
  Widget _buildCustomerInsights(LabTestAnalyticsViewModel vm) {
    final data = (vm.analytics['customerInsights'] as Map<String, dynamic>?) ?? {};
    final nvr = (data['newVsReturningByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rebooking = (data['rebookingTrends'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final topCustomers = (data['topCustomersByTestCount'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionContainer(
          title: 'New vs Returning Customers (Monthly)',
          child: SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: _monthTitles(),
                barGroups: [
                  for (int i = 0; i < nvr.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 6,
                      barRods: [
                        BarChartRodData(
                          toY: ((nvr[i]['new'] ?? 0) as num).toDouble(),
                          color: LabTestColorPalette.primaryBlue,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: ((nvr[i]['returning'] ?? 0) as num).toDouble(),
                          color: LabTestColorPalette.successGreen,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Rebooking Trends (Thyroid, Monthly)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < rebooking.length; i++) FlSpot(i.toDouble(), ((rebooking[i]['thyroidRepeats'] ?? 0) as num).toDouble())],
                    isCurved: true,
                    color: LabTestColorPalette.warningYellow,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Top Customers by Test Count',
          child: Column(
            children: topCustomers
                .map((c) => _barListRow(
                      label: (c['customer'] ?? '').toString(),
                      value: (c['tests'] ?? 0) as int,
                      maxValue: topCustomers.map((e) => (e['tests'] ?? 0) as int).fold<int>(0, (p, v) => v > p ? v : p),
                      color: LabTestColorPalette.primaryBlue,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // B. Demand Analysis
  Widget _buildDemandAnalysis(LabTestAnalyticsViewModel vm) {
    final data = (vm.analytics['demandAnalysis'] as Map<String, dynamic>?) ?? {};
    final geo = (data['geoDemandByArea'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final seasonal = (data['seasonalTestDemand'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final most = (data['mostRequestedLast30Days'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final low = (data['lowDemandLast30Days'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionContainer(
          title: 'Geographical Demand (Heat-style)',
          child: Column(
            children: geo
                .map((g) => _barListRow(
                      label: (g['area'] ?? '').toString(),
                      value: (g['bookings'] ?? 0) as int,
                      maxValue: geo.map((e) => (e['bookings'] ?? 0) as int).fold<int>(0, (p, v) => v > p ? v : p),
                      color: LabTestColorPalette.secondaryTeal,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Seasonal Test Demand (Dengue/Malaria)',
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < seasonal.length; i++) FlSpot(i.toDouble(), ((seasonal[i]['dengue'] ?? 0) as num).toDouble())],
                    isCurved: true,
                    color: LabTestColorPalette.errorRed,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: [for (int i = 0; i < seasonal.length; i++) FlSpot(i.toDouble(), ((seasonal[i]['malaria'] ?? 0) as num).toDouble())],
                    isCurved: true,
                    color: LabTestColorPalette.successGreen,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Most Requested Test Types (Last 30 days)',
          child: Column(
            children: most
                .map((t) => _barListRow(
                      label: (t['test'] ?? '').toString(),
                      value: (t['count'] ?? 0) as int,
                      maxValue: most.map((e) => (e['count'] ?? 0) as int).fold<int>(0, (p, v) => v > p ? v : p),
                      color: LabTestColorPalette.primaryBlue,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Low Demand Test Types (Last 30 days)',
          child: Column(
            children: low
                .map((t) => _barListRow(
                      label: (t['test'] ?? '').toString(),
                      value: (t['count'] ?? 0) as int,
                      maxValue: (low.isEmpty)
                          ? 1
                          : low.map((e) => (e['count'] ?? 0) as int).reduce((a, b) => a > b ? a : b),
                      color: LabTestColorPalette.textSecondary,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // C. Operational Efficiency
  Widget _buildOperationalEfficiency(LabTestAnalyticsViewModel vm) {
    final data = (vm.analytics['operationalEfficiency'] as Map<String, dynamic>?) ?? {};
    final toAppt = (data['avgTimeToAppointmentDaysByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final toConfirm = (data['avgTimeToConfirmCollectionMinsByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final tat = (data['reportTurnaroundHoursByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Boxes
        _sectionContainer(
          title: 'Operational KPI Overview',
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Avg Time to Appointment',
                  value: toAppt.isEmpty ? '-' : '${((toAppt.last['days'] ?? 0.0) as num).toStringAsFixed(1)} d',
                  icon: Icons.event_available,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Time to Confirm',
                  value: toConfirm.isEmpty ? '-' : '${((toConfirm.last['mins'] ?? 0) as num).toInt()} m',
                  icon: Icons.task_alt,
                  color: LabTestColorPalette.secondaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Report TAT',
                  value: tat.isEmpty ? '-' : '${((tat.last['hours'] ?? 0) as num).toInt()} h',
                  icon: Icons.timer,
                  color: LabTestColorPalette.warningYellow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Avg Time to Appointment (days)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < toAppt.length; i++) FlSpot(i.toDouble(), ((toAppt[i]['days'] ?? 0.0) as num).toDouble())],
                    isCurved: true,
                    color: LabTestColorPalette.primaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Avg Time to Confirm Collection (mins)',
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < toConfirm.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ((toConfirm[i]['mins'] ?? 0) as num).toDouble(),
                          color: LabTestColorPalette.secondaryTeal,
                          width: 12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Report Turnaround Time (hours)',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < tat.length; i++) FlSpot(i.toDouble(), ((tat[i]['hours'] ?? 0) as num).toDouble())],
                    isCurved: true,
                    color: LabTestColorPalette.warningYellow,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // D. Service Preferences
  Widget _buildServicePreferences(LabTestAnalyticsViewModel vm) {
    final data = (vm.analytics['servicePreferences'] as Map<String, dynamic>?) ?? {};
    final homeTrend = (data['homeCollectionTrendByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final dist = (data['collectionTypeDistributionByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionContainer(
          title: 'Home Sample Collection Trend',
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < homeTrend.length; i++) FlSpot(i.toDouble(), (((homeTrend[i]['ratio'] ?? 0.0) as num).toDouble()) * 100)],
                    isCurved: true,
                    color: LabTestColorPalette.primaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Distribution by Collection Type (Monthly %)',
          child: SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                maxY: 100,
                barGroups: [
                  for (int i = 0; i < dist.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: 100,
                          rodStackItems: [
                            BarChartRodStackItem(0, (((dist[i]['home'] ?? 0.0) as num).toDouble()) * 100, LabTestColorPalette.secondaryTeal),
                            BarChartRodStackItem((((dist[i]['home'] ?? 0.0) as num).toDouble()) * 100, 100, LabTestColorPalette.successGreen),
                          ],
                          width: 14,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // E. Revenue & Volume
  Widget _buildRevenueAndVolume(LabTestAnalyticsViewModel vm) {
    final data = (vm.analytics['revenueAndVolume'] as Map<String, dynamic>?) ?? {};
    final monthlyRevenue = (data['monthlyRevenue'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final revenueByType = (data['revenueByTestType'] as Map?)?.cast<String, double>() ?? {};
    final bookingVolume = (data['bookingVolumeByMonth'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionContainer(
          title: 'Monthly Revenue Trends',
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (int i = 0; i < monthlyRevenue.length; i++) FlSpot(i.toDouble(), (((monthlyRevenue[i]['revenue'] ?? 0.0) as num).toDouble()) / 1000.0)],
                    isCurved: true,
                    color: LabTestColorPalette.primaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Revenue by Test Type',
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _pieSectionsFromMap(revenueByType),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionContainer(
          title: 'Booking Volume Trends (Monthly)',
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: LabTestColorPalette.borderLight, strokeWidth: 1)),
                titlesData: _monthTitles(),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < bookingVolume.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ((bookingVolume[i]['bookings'] ?? 0) as num).toDouble(),
                          color: LabTestColorPalette.successGreen,
                          width: 12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _monthTitles() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= months.length) return const SizedBox.shrink();
            final show = i % 2 == 0; // reduce clutter
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(show ? months[i] : '', style: const TextStyle(color: LabTestColorPalette.textSecondary, fontSize: 11)),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: LabTestColorPalette.textSecondary, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _barListRow({required String label, required int value, required int maxValue, required Color color}) {
    final double ratio = maxValue == 0 ? 0 : value / maxValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: LabTestColorPalette.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text('$value', style: const TextStyle(fontSize: 12, color: LabTestColorPalette.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _pieSectionsFromMap(Map<String, double> data) {
    if (data.isEmpty) return [];
    final colors = [
      LabTestColorPalette.primaryBlue,
      LabTestColorPalette.secondaryTeal,
      LabTestColorPalette.warningYellow,
      LabTestColorPalette.successGreen,
      LabTestColorPalette.errorRed,
    ];
    final total = data.values.fold<double>(0.0, (p, v) => p + v);
    int i = 0;
    return data.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      final percent = total == 0 ? 0 : (e.value / total) * 100.0;
      return PieChartSectionData(
        color: color,
        value: e.value,
        radius: 60,
        title: '${e.key} ${percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();
  }
} 