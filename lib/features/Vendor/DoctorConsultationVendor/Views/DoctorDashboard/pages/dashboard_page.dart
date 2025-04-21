import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/analytics_chart_widget.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/booking_overview_card.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/clinic_notification_card.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/doctor_stats_card.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/upcoming_appointments_card.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/visit_trends_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: RefreshIndicator(
        color: DoctorConsultationColorPalette.primaryBlue,
        onRefresh: () async {
          await viewModel.fetchDashboardData();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(viewModel),
                  const SizedBox(height: 20),
                  _buildTimeFilterSelector(viewModel),
                  const SizedBox(height: 20),
                  _buildBookingsOverview(),
                  const SizedBox(height: 24),
                  _buildDoctorStats(viewModel),
                  const SizedBox(height: 24),
                  _buildClinicNotification(),
                  const SizedBox(height: 24),
                  _buildVisitTrends(),
                  const SizedBox(height: 24),
                  _buildUpcomingAppointments(),
                  const SizedBox(height: 24),
                  _buildAnalytics(viewModel),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (viewModel.isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DoctorConsultationColorPalette.primaryBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DoctorConsultationColorPalette.primaryBlue,
            DoctorConsultationColorPalette.primaryBlueDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
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
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: DoctorConsultationColorPalette.backgroundCard,
                  backgroundImage: const AssetImage('assets/images/doctor_profile.png'),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.grey,
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
                  const Text(
                    'Dr. John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
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
                      color: viewModel.isOnline 
                          ? DoctorConsultationColorPalette.successGreen
                          : DoctorConsultationColorPalette.errorRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      viewModel.isOnline ? 'Online' : 'Offline',
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
                    'You have ${viewModel.todayAppointments} new appointments today',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to appointments page
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
                      color: DoctorConsultationColorPalette.primaryBlue,
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

  Widget _buildTimeFilterSelector(DashboardViewModel viewModel) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: viewModel.timeFilters.map((filter) {
          final isSelected = filter == viewModel.selectedTimeFilter;
          return Expanded(
            child: InkWell(
              onTap: () {
                viewModel.setTimeFilter(filter);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? DoctorConsultationColorPalette.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : DoctorConsultationColorPalette.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingsOverview() {
    return const BookingOverviewCard();
  }

  Widget _buildDoctorStats(DashboardViewModel viewModel) {
    return DoctorStatsCard(
      totalPatients: viewModel.totalPatients,
      totalAppointments: viewModel.totalAppointments,
      rating: viewModel.rating,
      reviewCount: viewModel.reviewCount,
    );
  }

  Widget _buildClinicNotification() {
    return const ClinicNotificationCard();
  }

  Widget _buildVisitTrends() {
    return const VisitTrendsChart();
  }

  Widget _buildUpcomingAppointments() {
    return UpcomingAppointmentsCard(
      appointments: [],
      onViewDetails: (id) {
        // Handle view details
      },
    );
  }

  Widget _buildAnalytics(DashboardViewModel viewModel) {
    return AnalyticsChartWidget(
      data: viewModel.analyticsData,
      isLoading: viewModel.isLoading,
    );
  }
} 