import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/ProcessBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Dashboard/AmbulanceAgencyAnalyticsInsightsChart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/widgets/SeasonalLineChart.dart';

class AmbulanceAgencyDashboardScreen extends StatefulWidget {
  @override
  State<AmbulanceAgencyDashboardScreen> createState() => _AmbulanceAgencyDashboardScreenState();
}

class _AmbulanceAgencyDashboardScreenState extends State<AmbulanceAgencyDashboardScreen> {
  bool _showAiSuggestion = true;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AgencyDashboardViewModel, AmbulanceMainViewModel>(
      builder: (context, viewModel, mainViewModel, child) {
        return Scaffold(
          backgroundColor: AmbulanceAgencyColorPalette.backgroundWhite,
          body: RefreshIndicator(
            onRefresh: () async {
              await viewModel.refreshDashboardData();
              await mainViewModel.fetchVendorStatus();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, viewModel, mainViewModel),
                  const SizedBox(height: 16),
                  if (_showAiSuggestion)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAiSuggestionCard(viewModel),
                    ),
                  if (_showAiSuggestion) const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildAnalyticsSection(viewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AgencyDashboardViewModel viewModel, AmbulanceMainViewModel mainViewModel) {
    final topPadding = MediaQuery.of(context).padding.top + 16;
    return Container(
      padding: EdgeInsets.only(top: topPadding, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AmbulanceAgencyColorPalette.accentCyan,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message at top
          Text(
            'Welcome back',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Profile Picture with error fallback
              Builder(builder: (context) {
                String? url;
                final photos = viewModel.agencyProfile?.officePhotos;
                if (photos != null && photos.isNotEmpty) {
                  final first = photos.first;
                  if (first is Map) {
                    final dynamic candidate = first['url'];
                    if (candidate is String && candidate.isNotEmpty) {
                      url = candidate;
                    }
                  }
                }
                return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  ),
                  child: ClipOval(
                    child: (url != null && url!.isNotEmpty)
                        ? Image.network(
                            url!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.15),
                                child: const Icon(Icons.person, color: Colors.white, size: 28),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.15),
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                  ),
                );
              }),
              const SizedBox(width: 16),
              // Agency Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.agencyProfile?.agencyName ?? 'Agency Name',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            viewModel.agencyProfile?.email ?? 'agency@email.com',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Toggle
              GestureDetector(
                onTap: () async {
                  if (!mainViewModel.isLoading) {
                    try {
                      final newStatus = await mainViewModel.toggleVendorStatus();
                      Fluttertoast.showToast(
                        msg: "You are now ${newStatus ? 'Active' : 'Inactive'}",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: newStatus ? Colors.green : Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                        timeInSecForIosWeb: 2,
                        webPosition: "center",
                        webBgColor: "linear-gradient(to right, ${newStatus ? '#00b09b' : '#ff0000'}, ${newStatus ? '#96c93d' : '#ff4b2b'})",
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Failed to update status. Please try again.",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                        timeInSecForIosWeb: 2,
                        webPosition: "center",
                        webBgColor: "linear-gradient(to right, #ff0000, #ff4b2b)",
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: mainViewModel.isActive
                          ? AmbulanceAgencyColorPalette.successGreen
                          : AmbulanceAgencyColorPalette.errorRed,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (mainViewModel.isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mainViewModel.isActive
                                  ? AmbulanceAgencyColorPalette.successGreen
                                  : AmbulanceAgencyColorPalette.errorRed,
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mainViewModel.isActive
                                ? AmbulanceAgencyColorPalette.successGreen
                                : AmbulanceAgencyColorPalette.errorRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        mainViewModel.isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // You can add additional brief subtext here if needed
        ],
      ),
    );
  }

  Widget _buildAiSuggestionCard(AgencyDashboardViewModel vm) {
    final Color primary = AmbulanceAgencyColorPalette.accentPurple; // AI purple
    final Color secondary = AmbulanceAgencyColorPalette.accentCyan; // Cyan

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.18),
            secondary.withOpacity(0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.18),
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
              color: Colors.white.withOpacity(0.9),
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
                      'AI Suggestion',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
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
                          color: Colors.white.withOpacity(0.85),
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
                  'High-demand window predicted 5–7 PM in Andheri & Bandra. Pre-position 2 units there and enable auto-dispatch to cut acceptance time by ~15%. Powai shows slightly higher cancellations; consider quick callback verification.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AmbulanceAgencyColorPalette.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAnalyticsSection(AgencyDashboardViewModel vm) {
    final data = vm.analytics;
    if (data.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AmbulanceAgencyColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Top KPIs grid
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 600;
            final double ratio = isWide ? 2.4 : 1.9; // more height on narrow screens
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: ratio,
              children: [
                _kpiCard('Users Acquired', data['usersAcquired'].toString(), Icons.group),
                _kpiCard('DAU / MAU', '${data['dau']}/${data['mau']}', Icons.timeline),
                _kpiCard('Returning Customers', data['returningCustomers'].toString(), Icons.repeat),
                _kpiCard('Cancellation Rate', '${data['cancellationRate']}%', Icons.cancel_presentation),
                _kpiCard('Avg Time to Pickup', '${data['avgPickupTimeMin']} min', Icons.local_taxi),
                _kpiCard('Time to Accept', '${data['timeToAcceptSec']} sec', Icons.hourglass_top),
                _kpiCard('Trips Booked', data['tripsBooked'].toString(), Icons.local_hospital),
                _kpiCard('Revenue', '₹${(data['revenue'] as double).toStringAsFixed(0)}', Icons.payments),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Demand vs Scheduled
        _metricCard(
          title: 'Demand Trends',
          subtitle: 'Emergency vs Scheduled',
          icon: Icons.emergency_share,
          child: Builder(builder: (context) {
            final int emergency = (data['emergency'] as num).toInt();
            final int scheduled = (data['scheduled'] as num).toInt();
            final int total = emergency + scheduled;
            return Row(
              children: [
                Expanded(child: _progressTile('Emergency', emergency, total, Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _progressTile('Scheduled', scheduled, total, AmbulanceAgencyColorPalette.secondaryBlue)),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
        // Area demand and oversupply
        _metricCard(
          title: 'Area-based Requests',
          subtitle: 'High demand zones',
          icon: Icons.location_on,
          child: Column(
            children: (data['areaDemand'] as List).map<Widget>((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(e['area'], style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textPrimary)),
                    ),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (e['requests'] as num).toDouble() / 80,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AmbulanceAgencyColorPalette.secondaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e['requests']}', style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _metricCard(
          title: 'Oversupply Mapping',
          subtitle: 'Areas with excess supply',
          icon: Icons.map,
          child: Column(
            children: (data['oversupply'] as List).map<Widget>((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(e['area'], style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textPrimary)),
                    ),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (e['excess'] as num).toDouble() / 30,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AmbulanceAgencyColorPalette.secondaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e['excess']}', style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Seasonal trends (simple bar by month)
        _metricCard(
          title: 'Seasonal Trends',
          subtitle: 'Incident peaks by month',
          icon: Icons.trending_up,
          child: SizedBox(
            height: 180,
            child: SeasonalLineChart(data: List<Map<String, dynamic>>.from(data['seasonalTrends'] as List)),
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AmbulanceAgencyColorPalette.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
            child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AmbulanceAgencyColorPalette.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AmbulanceAgencyColorPalette.secondaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AmbulanceAgencyColorPalette.textPrimary)),
                const SizedBox(height: 2),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AmbulanceAgencyColorPalette.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(icon, color: AmbulanceAgencyColorPalette.secondaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AmbulanceAgencyColorPalette.textPrimary)),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _progressTile(String label, int value, int total, Color color) {
    final double ratio = total == 0 ? 0 : value / total;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AmbulanceAgencyColorPalette.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AmbulanceAgencyColorPalette.textPrimary)),
              Text('$value', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
  Widget _quickStatItem(IconData icon, String value, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.blue.shade700.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(AgencyDashboardViewModel vm) {
    final cards = <Widget>[
      _summaryBox("Total Bookings", "${vm.totalBookings}", Colors.blue),
      _summaryBox("Today's Bookings", "${vm.todaysBookings}", Colors.green),
      _summaryBox("Avg Response", "${vm.avgResponseTime} min", Colors.orange),
      _summaryBox("Operational KMs", "${vm.operationalKms} km", Colors.purple),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Overview",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final crossAxisCount = isWide ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 3.2 : 2.6,
                children: cards,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(Icons.analytics, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBookingRequests(AgencyDashboardViewModel vm, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Booking Requests",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${vm.pendingBookings.length} Active",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          vm.pendingBookings.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No ongoing bookings right now",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vm.pendingBookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final request = vm.pendingBookings[index];
                    return _buildBookingRequestCard(request, context);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBookingRequestCard(dynamic request, BuildContext context) {
    final customerName = request.user.name ?? "Unknown";
    final contact = request.user.phoneNumber ?? "";
    final pickup = request.pickupLocation;
    final drop = request.dropLocation;
    final status = request.status;
    final time = request.requiredDateTime;

    final isPending = status.toLowerCase() == "pending";
    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                radius: 24,
                child: const Icon(Icons.person, color: Color(0xFF1565C0), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            contact,
                            style: GoogleFonts.poppins(color: Colors.grey[600]!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.call, color: Colors.green, size: 18),
                label: const Text("Call"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => launchUrl(Uri.parse('tel:$contact')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pickup,
                        style: GoogleFonts.poppins(color: Colors.grey[800]!),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drop,
                        style: GoogleFonts.poppins(color: Colors.grey[800]!),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(time.toLocal()),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
