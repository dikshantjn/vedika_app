import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/VendorBloodBankDashBoardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/widgets/Sparkline.dart';

class VendorBloodBankDashBoardScreen extends StatelessWidget {
  const VendorBloodBankDashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendorBloodBankDashBoardViewModel()..initializeDashboard(),
      child: Consumer<VendorBloodBankDashBoardViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildShimmerLoading();
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refreshDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshDashboard(),
            child: Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildWelcomeHeader(context, viewModel),
                    const SizedBox(height: 12),
                    _buildAiSuggestionCard(viewModel),
                    const SizedBox(height: 12),
                    _buildTimeFilter(context, viewModel),
                              const SizedBox(height: 16),
                    _buildAnalytics(context, viewModel),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 16, width: 220, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 180, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // AI suggestion shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            // Time filter pills shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // KPI grid shimmer (6 tiles)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(6, (i) => i)
                    .map((_) => Container(
                          width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 16 * 2 - 12) / 2,
                          height: 72,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Metric card: Top demand
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 160, color: Colors.white),
                    const SizedBox(height: 10),
                    ...List.generate(3, (i) => i).map((_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.white)),
                              const SizedBox(width: 8),
                              Expanded(flex: 5, child: Container(height: 6, color: Colors.white)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Metric card: Region-wise
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 180, color: Colors.white),
                    const SizedBox(height: 10),
                    ...List.generate(4, (i) => i).map((_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.white)),
                              const SizedBox(width: 8),
                              Expanded(flex: 5, child: Container(height: 6, color: Colors.white)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Metric card: Stock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 160, color: Colors.white),
                    const SizedBox(height: 10),
                    ...List.generate(5, (i) => i).map((_) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Container(height: 10, color: Colors.white)),
                              const SizedBox(width: 8),
                              Expanded(flex: 5, child: Container(height: 6, color: Colors.white)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, VendorBloodBankDashBoardViewModel vm) {
    final name = vm.agencyDetails?.agencyName ?? 'Blood Bank Vendor';
    final email = vm.agencyDetails?.email ?? 'vendor@email.com';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
                    Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionCard(VendorBloodBankDashBoardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.15),
              Colors.cyan.withOpacity(0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.purple.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(color: Colors.cyan.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.psychology_alt_rounded, color: Colors.purple, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('VedikaAI Suggestion', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.purple)),
                      Icon(Icons.close, size: 16, color: Colors.black54),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Demand spike predicted this weekend for O+ and B+. Pre-allocate additional units in Hinjewadi and Kharadi; enable express delivery for critical orders. Consider outreach for O- donors to reduce shortage risk.',
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter(BuildContext context, VendorBloodBankDashBoardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: vm.timeFilters.map((filter) {
            final bool selected = vm.selectedTimeFilter == filter;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => vm.setTimeFilter(filter),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, VendorBloodBankDashBoardViewModel vm) {
    final data = vm.analytics;
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analytics Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isWide = width >= 600;
            final bool isVeryWide = width >= 900;
            final int crossAxisCount = isVeryWide ? 3 : 2;
            // Increase ratio (shorter tiles) now that labels are full; dynamic by width
            final double ratio = isVeryWide ? 3.0 : (isWide ? 2.4 : 1.8);
            final pickupMap = Map<String, dynamic>.from(data['pickupVsDelivery'] ?? {});
            final double pickupPct = (pickupMap['pickup'] is num) ? (pickupMap['pickup'] as num).toDouble() : 0.0;
            final double deliveryPct = (pickupMap['delivery'] is num) ? (pickupMap['delivery'] as num).toDouble() : 0.0;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
              children: [
                _kpiCard('Total Requests', (data['totalRequests'] ?? 0).toString(), Icons.all_inbox),
                _kpiCard('Confirmed / Declined', '${data['confirmed'] ?? 0}/${data['declined'] ?? 0}', Icons.verified),
                _kpiCard('Avg Confirm Time', '${data['avgTimeToConfirmMin'] ?? 0} min', Icons.timer),
                _kpiCard('Avg Fulfillment Time', '${data['avgTimeToFulfillmentMin'] ?? 0} min', Icons.timelapse),
                _kpiCard('Pickup vs Delivery', '${pickupPct.toStringAsFixed(0)}% / ${deliveryPct.toStringAsFixed(0)}%', Icons.local_shipping),
                _kpiCard('Self-pick Wait', '${data['selfPickAvgWaitMin'] ?? 0} min', Icons.person_pin_circle),
                _kpiCard('Delivery Avg Time', '${data['homeDeliveryAvgMin'] ?? 0} min', Icons.delivery_dining),
                _kpiCard('Repeat Buyers (30/60/90)', '${data['repeatBuyers']?['30d'] ?? 0}/${data['repeatBuyers']?['60d'] ?? 0}/${data['repeatBuyers']?['90d'] ?? 0}', Icons.repeat),
              ],
            );
          }),
          const SizedBox(height: 16),
          _card(
            context,
            title: 'Top 3 Blood Types in Demand',
            icon: Icons.trending_up,
            child: Column(
              children: (data['topDemand'] as List).map<Widget>((e) {
                return _progressRow(label: e['type'], value: e['count'], max: 250, color: Colors.redAccent);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Least Requested Blood Types',
            icon: Icons.trending_down,
            child: Column(
              children: (data['leastDemand'] as List).map<Widget>((e) {
                return _progressRow(label: e['type'], value: e['count'], max: 40, color: Colors.orangeAccent);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Region-wise Requests',
            icon: Icons.location_on,
            child: Column(
              children: (data['regionRequests'] as List).map<Widget>((e) {
                return _progressRow(label: e['region'], value: e['requests'], max: 120, color: Colors.blueAccent);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Excess Demand Alerts',
            icon: Icons.warning_amber,
            child: Column(
              children: (data['excessDemandAlerts'] as List).map<Widget>((e) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e['type'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('+${e['gap']} req', style: const TextStyle(color: Colors.redAccent)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Current Stock by Blood Type',
            icon: Icons.inventory,
            child: Column(
              children: (data['stockByType'] as List).map<Widget>((e) {
                final bool low = (e['units'] as int) <= data['lowStockThreshold'];
                return _progressRow(
                  label: e['type'],
                  value: e['units'],
                  max: 50,
                  color: low ? Colors.redAccent : Colors.green,
                  trailing: low ? const Text('Low', style: TextStyle(color: Colors.red)) : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Fast-Moving Blood Types',
            icon: Icons.speed,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data['fastMovingTypes'] as List).map<Widget>((t) => Chip(label: Text(t))).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Oversupply Warnings',
            icon: Icons.inventory_2,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data['oversupplyWarnings'] as List).map<Widget>((t) => Chip(label: Text(t))).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Monthly Trends by Blood Type',
            icon: Icons.stacked_line_chart,
            child: Column(
              children: (data['monthlyTrendsByType'] as List).map<Widget>((series) {
                final List<int> values = List<int>.from(series['monthly']);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(series['type'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _miniSparkline(values, Colors.redAccent),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            title: 'Seasonal Demand Trends',
            icon: Icons.trending_up,
            child: _miniSparkline(List<int>.from(data['seasonalTrends'].map((e) => e['incidents'] as int)), Colors.orangeAccent),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.redAccent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _progressRow({required String label, required int value, required int max, Color? color, Widget? trailing}) {
    final double ratio = value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blueAccent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value', style: const TextStyle(fontSize: 12)),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _miniSparkline(List<int> values, Color color) {
    return SizedBox(
      height: 80,
      child: Sparkline(values: values, color: color),
    );
  }

  Widget _buildRecentRequests(BuildContext context, VendorBloodBankDashBoardViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Requests',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all requests
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.recentRequests.length,
            itemBuilder: (context, index) {
              final request = viewModel.recentRequests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bloodtype, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blood Request #${request.user.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    request.bloodType,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${request.units} units',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _getTimeAgo(request.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request.status,
                                    style: TextStyle(
                                      color: _getStatusColor(request.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 