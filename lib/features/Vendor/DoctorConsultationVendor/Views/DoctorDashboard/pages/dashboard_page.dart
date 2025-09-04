import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Utils/AppointmentAdapter.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicProfileViewModel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    final profileViewModel = Provider.of<DoctorClinicProfileViewModel>(context);
    
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
                  _buildWelcomeHeader(viewModel, profileViewModel),
                  const SizedBox(height: 16),
                  _buildAiSuggestionCard(),
                  const SizedBox(height: 20),
                  _buildBookingsOverview(),
                  const SizedBox(height: 24),
                  _buildDoctorStats(viewModel),
                  const SizedBox(height: 24),
                  _buildVisitTrends(),
                  const SizedBox(height: 24),
                  _buildTimeFilterSelector(viewModel),
                  const SizedBox(height: 24),
                  _buildComprehensiveAnalytics(viewModel),
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

  Widget _buildWelcomeHeader(DashboardViewModel viewModel, DoctorClinicProfileViewModel profileViewModel) {
    final profile = profileViewModel.profile;
    
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
                child: profile != null && profile.profilePicture.isNotEmpty
                  ? CircleAvatar(
                      radius: 22,
                      backgroundColor: DoctorConsultationColorPalette.backgroundCard,
                      child: Image.network(
                        profile.profilePicture,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: DoctorConsultationColorPalette.primaryBlue,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: DoctorConsultationColorPalette.primaryBlue,
                            size: 20,
                          );
                        },
                      ),
                    )
                  : CircleAvatar(
                      radius: 22,
                      backgroundColor: DoctorConsultationColorPalette.backgroundCard,
                      child: Text(
                        profile != null && profile.doctorName.isNotEmpty
                            ? profile.doctorName[0].toUpperCase()
                            : 'D',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.primaryBlue,
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
                    profile != null && profile.doctorName.isNotEmpty
                        ? '${profile.doctorName}'
                        : 'Doctor',
                    style: const TextStyle(
                      color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                    'You have ${viewModel.upcomingAppointments.length} upcoming appointments',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to appointments page
                    Navigator.pushNamed(context, '/doctor/appointments');
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

  Widget _buildAiSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.psychology,
              color: DoctorConsultationColorPalette.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VedikaAI Suggestion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peak consultation time: 3-4 PM with 22 bookings. Consider adding more slots during this period.',
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Close the suggestion card
            },
            icon: Icon(
              Icons.close,
              size: 16,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsOverview() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        Text(
          'Bookings Overview',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.today,
                title: 'Today',
                count: 12,
                color: DoctorConsultationColorPalette.primaryBlue,
                bgColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.calendar_today,
                title: 'Upcoming',
                count: 28,
                color: DoctorConsultationColorPalette.secondaryTeal,
                bgColor: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBookingCard(
                context,
                icon: Icons.history,
                title: 'Past',
                count: 145,
                color: DoctorConsultationColorPalette.textSecondary,
                bgColor: DoctorConsultationColorPalette.textSecondary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
            padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
                  size: 24,
                ),
              ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              color: DoctorConsultationColorPalette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: DoctorConsultationColorPalette.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorStats(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: DoctorConsultationColorPalette.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'This Month',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.groups_outlined,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  value: viewModel.totalPatients.toString(),
                  label: 'Total Patients',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_note,
                  color: DoctorConsultationColorPalette.secondaryTeal,
                  value: viewModel.totalAppointments.toString(),
                  label: 'Appointments',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  color: DoctorConsultationColorPalette.warningYellow,
                  value: viewModel.rating.toString(),
                  label: 'Rating (${viewModel.reviewCount} reviews)',
                  showDecimal: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRateProgressItem(
                  title: 'Completion Rate',
                  percentage: viewModel.completionRate.toInt(),
                  color: DoctorConsultationColorPalette.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool showDecimal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            showDecimal ? "${value.substring(0, 1)}.${value.length > 1 ? value.substring(1, 2) : '0'}" : value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateProgressItem({
    required String title,
    required int percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
      ],
          ),
        ],
      ),
    );
  }



  Widget _buildVisitTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Trends',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Visits',
                    style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
          ),
                  ),
                  _buildChartLegend(),
                ],
        ),
        const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildLineChart(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                  _buildSummaryItem(
                    title: 'Highest',
                    value: '34',
                    subtitle: 'Mon, 15 Apr',
                    iconColor: DoctorConsultationColorPalette.successGreen,
                  ),
                  _buildSummaryItem(
                    title: 'Average',
                    value: '18',
                    subtitle: 'per day',
                    iconColor: DoctorConsultationColorPalette.primaryBlue,
                  ),
                  _buildSummaryItem(
                    title: 'Lowest',
                    value: '5',
                    subtitle: 'Sun, 21 Apr',
                    iconColor: DoctorConsultationColorPalette.errorRed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'This Week',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.secondaryTeal,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Last Week',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    // Mock data for the chart
    final List<double> thisWeekData = [15, 25, 18, 28, 22, 12, 18];
    final List<double> lastWeekData = [10, 18, 20, 15, 25, 10, 15];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(
        thisWeekData: thisWeekData,
        lastWeekData: lastWeekData,
        days: days,
        maxValue: 30,
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
          style: TextStyle(
                color: DoctorConsultationColorPalette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }



    Widget _buildTimeFilterSelector(DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Time Period',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: viewModel.timeFilters.map((filter) {
              final isSelected = viewModel.selectedTimeFilter == filter;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => viewModel.setTimeFilter(filter),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? DoctorConsultationColorPalette.primaryBlue 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? Colors.white 
                                : DoctorConsultationColorPalette.textPrimary,
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
      ],
    );
  }

  Widget _buildAnalytics(DashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
              ),
              if (viewModel.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DoctorConsultationColorPalette.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Patient and appointment trends',
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem(
                color: DoctorConsultationColorPalette.primaryBlue,
                label: 'Patients',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                color: DoctorConsultationColorPalette.secondaryTeal,
                label: 'Appointments',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: viewModel.analyticsData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  )
                : _buildBarChart(viewModel.analyticsData),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    // Find the maximum value to scale the bars properly
    double maxValue = 0;
    for (var item in data) {
      if ((item['patients'] as int) > maxValue) {
        maxValue = (item['patients'] as int).toDouble();
      }
      if ((item['appointments'] as int) > maxValue) {
        maxValue = (item['appointments'] as int).toDouble();
      }
    }
    
    // Add 10% padding to the maximum value
    maxValue *= 1.1;

    return Row(
      children: data.map((item) {
        final double patientBarHeight = 
            (item['patients'] as int) / maxValue * 130;
        final double appointmentBarHeight = 
            (item['appointments'] as int) / maxValue * 130;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Y-axis label for patients
                Text(
                  '${item['patients']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                // Bars container with fixed height to prevent overflow
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Place both bars side by side
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Patient bar
                          Container(
                            height: patientBarHeight,
                            width: 8,
                            decoration: BoxDecoration(
                              color: DoctorConsultationColorPalette.primaryBlue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Appointment bar
                          Container(
                            height: appointmentBarHeight,
                            width: 8,
                            decoration: BoxDecoration(
                              color: DoctorConsultationColorPalette.secondaryTeal,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // X-axis label (month)
                Text(
                  item['month'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComprehensiveAnalytics(DashboardViewModel viewModel) {
    final analytics = viewModel.comprehensiveAnalytics;
    if (analytics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              DoctorConsultationColorPalette.primaryBlue,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildNewVsReturningPatients(analytics),
        const SizedBox(height: 24),
        _buildTimeMetrics(analytics),
        const SizedBox(height: 24),
        _buildRebookingPatterns(analytics),
        const SizedBox(height: 24),
        _buildNoShowsCancellations(analytics),
        const SizedBox(height: 24),
        _buildPeakConsultationHours(analytics),
        const SizedBox(height: 24),
        _buildCityAreaDemand(analytics),
        const SizedBox(height: 24),
        _buildOnlineVsOffline(analytics),
        const SizedBox(height: 24),
        _buildSeasonalTrends(analytics),
        const SizedBox(height: 24),
        _buildSpecialities(analytics),
        const SizedBox(height: 24),
        _buildRatingVsAppointments(analytics),
        const SizedBox(height: 24),
        _buildAppointmentOutcomes(analytics),
        const SizedBox(height: 24),
        _buildRevenueInsights(analytics),
        const SizedBox(height: 24),
                          _buildFollowUpFunnel(analytics),
      ],
    );
  }

  Widget _buildNewVsReturningPatients(Map<String, dynamic> analytics) {
    final data = analytics['newVsReturningPatients'];
    return _buildAnalyticsCard(
      title: 'New vs Returning Patients',
      subtitle: 'Patient loyalty and retention insights',
      icon: Icons.people,
      child: Row(
        children: [
          Expanded(
            child: _buildPieChart(
              data['new'],
              data['returning'],
              ['New', 'Returning'],
              [DoctorConsultationColorPalette.primaryBlue, DoctorConsultationColorPalette.secondaryTeal],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildComprehensiveStatItem('New Patients', data['new'], DoctorConsultationColorPalette.primaryBlue),
                const SizedBox(height: 8),
                _buildComprehensiveStatItem('Returning Patients', data['returning'], DoctorConsultationColorPalette.secondaryTeal),
                const SizedBox(height: 8),
                _buildComprehensiveStatItem('Total Patients', data['total'], DoctorConsultationColorPalette.textPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMetrics(Map<String, dynamic> analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Avg Time to Appointment',
            subtitle: '${analytics['avgTimeToAppointment']} days',
            icon: Icons.schedule,
            child: Center(
              child: Text(
                '${analytics['avgTimeToAppointment']}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Avg Time to Confirm',
            subtitle: '${analytics['avgTimeToConfirm']} hours',
            icon: Icons.check_circle,
            child: Center(
              child: Text(
                '${analytics['avgTimeToConfirm']}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
            color: DoctorConsultationColorPalette.successGreen,
          ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRebookingPatterns(Map<String, dynamic> analytics) {
    final data = analytics['rebookingPatterns'];
    return _buildAnalyticsCard(
      title: 'Rebooking Patterns',
      subtitle: 'Patient return frequency analysis',
      icon: Icons.repeat,
      child: Column(
        children: [
                      Row(
              children: [
                Expanded(child: _buildComprehensiveStatItem('15 Days', data['15days'], DoctorConsultationColorPalette.primaryBlue)),
                Expanded(child: _buildComprehensiveStatItem('30 Days', data['30days'], DoctorConsultationColorPalette.secondaryTeal)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildComprehensiveStatItem('60 Days', data['60days'], DoctorConsultationColorPalette.warningYellow)),
                Expanded(child: _buildComprehensiveStatItem('90 Days', data['90days'], DoctorConsultationColorPalette.errorRed)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNoShowsCancellations(Map<String, dynamic> analytics) {
    final data = analytics['noShowsCancellations'];
    return _buildAnalyticsCard(
            title: 'No-shows & Cancellations',
      subtitle: '${data['percentage']}% of total appointments',
            icon: Icons.cancel,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildComprehensiveStatItem('No-shows', data['noShows'], DoctorConsultationColorPalette.errorRed)),
              Expanded(child: _buildComprehensiveStatItem('Cancellations', data['cancellations'], DoctorConsultationColorPalette.warningYellow)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: data['percentage'] / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(DoctorConsultationColorPalette.errorRed),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakConsultationHours(Map<String, dynamic> analytics) {
    final data = analytics['peakConsultationHours'];
    return _buildAnalyticsCard(
      title: 'Peak Consultation Hours',
      subtitle: 'Hour-wise booking distribution',
      icon: Icons.access_time,
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: data.map<Widget>((hourData) {
            final hour = hourData['hour'];
            final bookings = hourData['bookings'];
            final maxBookings = data.map((d) => d['bookings']).reduce((a, b) => a > b ? a : b);
            final height = (bookings / maxBookings) * 150;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$hour',
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
                Text(
                  '$bookings',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCityAreaDemand(Map<String, dynamic> analytics) {
    final data = analytics['cityAreaDemand'];
    return _buildAnalyticsCard(
      title: 'City/Area-wise Demand',
      subtitle: 'Geographic distribution of patients',
      icon: Icons.location_on,
      child: Column(
        children: data.map<Widget>((cityData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    cityData['city'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: cityData['percentage'] / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(DoctorConsultationColorPalette.primaryBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${cityData['percentage']}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOnlineVsOffline(Map<String, dynamic> analytics) {
    final data = analytics['onlineVsOffline'];
    return _buildAnalyticsCard(
      title: 'Online vs Offline Trends',
      subtitle: 'Consultation preference analysis',
            icon: Icons.computer,
      child: Row(
        children: [
          Expanded(
            child: _buildPieChart(
              data['online'],
              data['offline'],
              ['Online', 'Offline'],
              [DoctorConsultationColorPalette.primaryBlue, DoctorConsultationColorPalette.secondaryTeal],
            ),
          ),
          const SizedBox(width: 16),
                        Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComprehensiveStatItem('Online', data['online'], DoctorConsultationColorPalette.primaryBlue),
                    const SizedBox(height: 8),
                    _buildComprehensiveStatItem('Offline', data['offline'], DoctorConsultationColorPalette.secondaryTeal),
                    const SizedBox(height: 8),
                    _buildComprehensiveStatItem('Total', data['total'], DoctorConsultationColorPalette.textPrimary),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSeasonalTrends(Map<String, dynamic> analytics) {
    final data = analytics['seasonalTrends'];
    return _buildAnalyticsCard(
      title: 'Seasonal Illness Trends',
      subtitle: 'Monthly consultation type distribution',
      icon: Icons.trending_up,
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: data.map<Widget>((monthData) {
            final total = monthData['flu'] + monthData['allergy'] + monthData['general'];
            final fluHeight = (monthData['flu'] / total) * 150;
            final allergyHeight = (monthData['allergy'] / total) * 150;
            final generalHeight = (monthData['general'] / total) * 150;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 15,
                  height: fluHeight + allergyHeight + generalHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 15,
                        height: fluHeight,
                        color: DoctorConsultationColorPalette.errorRed,
                      ),
                      Container(
                        width: 15,
                        height: allergyHeight,
                        color: DoctorConsultationColorPalette.warningYellow,
                      ),
                      Container(
                        width: 15,
                        height: generalHeight,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  monthData['month'],
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSpecialities(Map<String, dynamic> analytics) {
    final data = analytics['specialities'];
    return _buildAnalyticsCard(
      title: 'Most Consulted Specialities',
      subtitle: 'Speciality-wise booking distribution',
            icon: Icons.medical_services,
      child: Column(
        children: data.map<Widget>((speciality) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    speciality['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: speciality['percentage'] / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(DoctorConsultationColorPalette.secondaryTeal),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${speciality['percentage']}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingVsAppointments(Map<String, dynamic> analytics) {
    final data = analytics['ratingVsAppointments'];
    return _buildAnalyticsCard(
      title: 'Rating vs Appointment Trends',
      subtitle: 'Correlation between ratings and bookings',
      icon: Icons.star,
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: data.map<Widget>((ratingData) {
            final maxAppointments = data.map((d) => d['appointments']).reduce((a, b) => a > b ? a : b);
            final height = (ratingData['appointments'] / maxAppointments) * 150;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.warningYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${ratingData['rating']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
                Text(
                  '${ratingData['appointments']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentOutcomes(Map<String, dynamic> analytics) {
    final data = analytics['appointmentOutcomes'];
    return _buildAnalyticsCard(
      title: 'Appointment Outcome Trends',
      subtitle: 'Completion and follow-up analysis',
            icon: Icons.assignment_turned_in,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildComprehensiveStatItem('Completed', data['completed'], DoctorConsultationColorPalette.successGreen)),
              Expanded(child: _buildComprehensiveStatItem('Rescheduled', data['rescheduled'], DoctorConsultationColorPalette.warningYellow)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildComprehensiveStatItem('Cancelled', data['cancelled'], DoctorConsultationColorPalette.errorRed)),
              Expanded(child: _buildComprehensiveStatItem('Prescriptions', data['prescriptions'], DoctorConsultationColorPalette.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          _buildComprehensiveStatItem('Follow-ups Recommended', data['followUps'], DoctorConsultationColorPalette.secondaryTeal),
        ],
      ),
    );
  }

  Widget _buildRevenueInsights(Map<String, dynamic> analytics) {
    final data = analytics['revenue'];
    return _buildAnalyticsCard(
      title: 'Revenue Insights',
      subtitle: 'Financial performance analysis',
      icon: Icons.monetization_on,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildComprehensiveStatItem(
                  'Total Revenue',
                  '₹${(data['total'] / 1000).toStringAsFixed(1)}K',
                  DoctorConsultationColorPalette.successGreen,
                ),
              ),
              Expanded(
                child: _buildComprehensiveStatItem(
                  'Avg per Consult',
                  '₹${data['avgPerConsult']}',
                  DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComprehensiveStatItem(
                  'Online Revenue',
                  '₹${(data['online'] / 1000).toStringAsFixed(1)}K',
                  DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
              Expanded(
                child: _buildComprehensiveStatItem(
                  'Offline Revenue',
                  '₹${(data['offline'] / 1000).toStringAsFixed(1)}K',
                  DoctorConsultationColorPalette.secondaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpFunnel(Map<String, dynamic> analytics) {
    final data = analytics['followUpFunnel'];
    return _buildAnalyticsCard(
      title: 'Follow-up Funnel',
      subtitle: 'Patient retention analysis',
      icon: Icons.filter_list,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildComprehensiveStatItem(
                  'First-time Patients',
                  data['firstTimePatients'],
                  DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
              Expanded(
                child: _buildComprehensiveStatItem(
                  'Booked Follow-up',
                  data['bookedFollowUp'],
                  DoctorConsultationColorPalette.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: data['conversionRate'] / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(DoctorConsultationColorPalette.successGreen),
          ),
          const SizedBox(height: 8),
          Text(
            '${data['conversionRate']}% Conversion Rate',
            style: TextStyle(
              fontSize: 12,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildAnalyticsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: DoctorConsultationColorPalette.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                        fontSize: 16,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildComprehensiveStatItem(String label, dynamic value, Color color) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
                    style: TextStyle(
            fontSize: 12,
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
        ),
      ],
    );
  }

  Widget _buildPieChart(int value1, int value2, List<String> labels, List<Color> colors) {
    final total = value1 + value2;
    final percentage1 = (value1 / total) * 100;
    final percentage2 = (value2 / total) * 100;
    
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: CustomPaint(
            painter: PieChartPainter(
              percentages: [percentage1, percentage2],
              colors: colors,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentage1.toStringAsFixed(1)}% ${labels[0]}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[1],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentage2.toStringAsFixed(1)}% ${labels[1]}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  
  PieChartPainter({
    required this.percentages,
    required this.colors,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = 0;
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = (percentages[i] / 100) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  final List<double> thisWeekData;
  final List<double> lastWeekData;
  final List<String> days;
  final double maxValue;
  
  LineChartPainter({
    required this.thisWeekData,
    required this.lastWeekData,
    required this.days,
    required this.maxValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double chartHeight = height - 30; // Reserve space for x-axis labels
    
    final double xStep = width / (thisWeekData.length - 1);
    
    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = DoctorConsultationColorPalette.borderLight
      ..strokeWidth = 1;
    
    // Draw horizontal grid lines
    for (int i = 1; i < 5; i++) {
      final double y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );
    }
    
    // Draw this week's line and points
    _drawLine(
      canvas,
      thisWeekData,
      xStep,
      chartHeight,
      DoctorConsultationColorPalette.primaryBlue,
      DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
    );
    
    // Draw last week's line and points
    _drawLine(
      canvas,
      lastWeekData,
      xStep,
      chartHeight,
      DoctorConsultationColorPalette.secondaryTeal,
      DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.2),
    );
    
    // Draw x-axis labels
    final TextStyle labelStyle = TextStyle(
      color: DoctorConsultationColorPalette.textSecondary,
      fontSize: 10,
    );
    
    for (int i = 0; i < days.length; i++) {
      final TextSpan span = TextSpan(
        text: days[i],
        style: labelStyle,
      );
      
      final TextPainter painter = TextPainter(
        text: span,
        textDirection: ui.TextDirection.ltr,
      );
      
      painter.layout();
      
      painter.paint(
        canvas,
        Offset(
          i * xStep - painter.width / 2,
          chartHeight + 10,
        ),
      );
    }
  }
  
  void _drawLine(
    Canvas canvas,
    List<double> data,
    double xStep,
    double chartHeight,
    Color lineColor,
    Color fillColor,
  ) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    final Path linePath = Path();
    final Path fillPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * data[i] / maxValue);
      
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Complete the fill path
    fillPath.lineTo((data.length - 1) * xStep, chartHeight);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Draw points
    final Paint pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final Paint pointStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double y = chartHeight - (chartHeight * data[i] / maxValue);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 4, pointStrokePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 