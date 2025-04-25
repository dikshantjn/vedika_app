import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/DashboardCard.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/BookingList.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/BookingChart.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/DiagnosticCenterProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DiagnosticCenterProfileViewModel>(context);
    final profile = viewModel.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(profile),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildTodayBookings(),
          const SizedBox(height: 24),
          _buildUpcomingBookings(),
          const SizedBox(height: 24),
          _buildBookingHistory(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(DiagnosticCenter? profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LabTestColorPalette.primaryBlue,
            LabTestColorPalette.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
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
                child: profile?.centerPhotosUrl != null && profile!.centerPhotosUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(profile.centerPhotosUrl),
                    )
                  : CircleAvatar(
                      radius: 22,
                      backgroundColor: LabTestColorPalette.backgroundCard,
                      child: Text(
                        profile?.name.isNotEmpty == true 
                            ? profile!.name[0].toUpperCase() 
                            : 'L',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: LabTestColorPalette.primaryBlue,
                        ),
                      ),
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
                      profile?.name ?? 'Lab Center',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.address ?? 'Address not set',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
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
                      color: _isActive 
                          ? LabTestColorPalette.successGreen
                          : LabTestColorPalette.errorRed,
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isActive = !_isActive;
                        });
                      },
                      child: Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
                    'You have ${profile?.testTypes.length ?? 0} test types available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to test types page
                    Navigator.pushNamed(context, '/lab/test-types');
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
                      color: LabTestColorPalette.primaryBlue,
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

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: const [
        DashboardCard(
          title: 'Total Bookings',
          value: '156',
          icon: Icons.calendar_today,
          color: LabTestColorPalette.primaryBlue,
        ),
        DashboardCard(
          title: 'Today\'s Bookings',
          value: '12',
          icon: Icons.event_available,
          color: LabTestColorPalette.secondaryTeal,
        ),
        DashboardCard(
          title: 'Pending Reports',
          value: '8',
          icon: Icons.description_outlined,
          color: LabTestColorPalette.warningYellow,
        ),
        DashboardCard(
          title: 'Total Revenue',
          value: '₹45,678',
          icon: Icons.attach_money,
          color: LabTestColorPalette.successGreen,
        ),
      ],
    );
  }

  Widget _buildTodayBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: const BookingList(
            type: 'today',
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: const BookingList(
            type: 'upcoming',
          ),
        ),
      ],
    );
  }

  Widget _buildBookingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: const BookingChart(),
        ),
      ],
    );
  }
} 