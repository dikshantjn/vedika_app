import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/AppointmentScreen.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/HistoryScreen.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/ProfileScreen.dart';
import 'dart:math' as math;

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({Key? key}) : super(key: key);

  @override
  _HospitalDashboardScreenState createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const AppointmentScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: Consumer<HospitalDashboardViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back,',
                  style: TextStyle(
                    color: HospitalVendorColorPalette.textInverse.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  viewModel.hospitalProfile?.name ?? 'Hospital',
                  style: TextStyle(
                    color: HospitalVendorColorPalette.textInverse,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        elevation: 0,
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        centerTitle: false,
        actions: [
          Consumer<HospitalDashboardViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  Text(
                    viewModel.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textInverse,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: viewModel.isActive,
                    onChanged: (value) {
                      viewModel.toggleActiveStatus();
                    },
                    activeColor: HospitalVendorColorPalette.successGreen,
                    activeTrackColor: HospitalVendorColorPalette.successGreen.withOpacity(0.3),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
        selectedItemColor: HospitalVendorColorPalette.primaryBlue,
        unselectedItemColor: HospitalVendorColorPalette.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Appointments';
      case 2:
        return 'History';
      case 3:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: HospitalVendorColorPalette.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: HospitalVendorColorPalette.neutralWhite,
                  child: Icon(
                    Icons.local_hospital,
                    size: 30,
                    color: HospitalVendorColorPalette.primaryBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<HospitalDashboardViewModel>(
                  builder: (context, viewModel, child) {
                    return Text(
                      viewModel.hospitalProfile?.name ?? 'Hospital Name',
                      style: TextStyle(
                        color: HospitalVendorColorPalette.textInverse,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Consumer<HospitalDashboardViewModel>(
                  builder: (context, viewModel, child) {
                    return Text(
                      viewModel.hospitalProfile?.email ?? 'email@example.com',
                      style: TextStyle(
                        color: HospitalVendorColorPalette.textInverse.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('Dashboard'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('Appointments'),
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('History'),
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('Profile'),
            onTap: () {
              setState(() {
                _currentIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: HospitalVendorColorPalette.primaryBlue),
            title: const Text('Logout'),
            onTap: () {
              // TODO: Implement logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalDashboardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: HospitalVendorColorPalette.errorRed,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.error!,
                  style: TextStyle(
                    color: HospitalVendorColorPalette.errorRed,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.fetchDashboardData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HospitalVendorColorPalette.primaryBlue,
                    foregroundColor: HospitalVendorColorPalette.textInverse,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimePeriodSelector(context, viewModel),
              const SizedBox(height: 24),
              _buildStatsRow(context, viewModel),
              const SizedBox(height: 24),
              _buildAppointmentsSection(context, viewModel),
              const SizedBox(height: 24),
              _buildFootfallSection(context, viewModel),
              const SizedBox(height: 24),
              _buildDemographicsSection(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context, HospitalDashboardViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimePeriodButton(
            context,
            viewModel,
            'Day',
            'day',
            Icons.calendar_today,
          ),
          _buildTimePeriodButton(
            context,
            viewModel,
            'Week',
            'week',
            Icons.calendar_view_week,
          ),
          _buildTimePeriodButton(
            context,
            viewModel,
            'Month',
            'month',
            Icons.calendar_view_month,
          ),
          _buildTimePeriodButton(
            context,
            viewModel,
            'Year',
            'year',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButton(
    BuildContext context,
    HospitalDashboardViewModel viewModel,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = viewModel.selectedTimePeriod == value;
    return InkWell(
      onTap: () => viewModel.updateTimePeriod(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? HospitalVendorColorPalette.primaryBlue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? HospitalVendorColorPalette.textInverse
                  : HospitalVendorColorPalette.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? HospitalVendorColorPalette.textInverse
                    : HospitalVendorColorPalette.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, HospitalDashboardViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Patients',
            viewModel.totalPatients.toString(),
            Icons.people,
            HospitalVendorColorPalette.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Enquiries',
            viewModel.totalEnquiries.toString(),
            Icons.phone_in_talk,
            HospitalVendorColorPalette.secondaryTeal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Bookings',
            viewModel.totalBookings.toString(),
            Icons.event_available,
            HospitalVendorColorPalette.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HospitalVendorColorPalette.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: HospitalVendorColorPalette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: HospitalVendorColorPalette.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection(BuildContext context, HospitalDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HospitalVendorColorPalette.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to appointments screen
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: HospitalVendorColorPalette.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAppointmentList(
                context,
                'Today',
                viewModel.todayAppointments,
                HospitalVendorColorPalette.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAppointmentList(
                context,
                'Upcoming',
                viewModel.upcomingAppointments,
                HospitalVendorColorPalette.secondaryTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentList(
    BuildContext context,
    String title,
    List<Appointment> appointments,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HospitalVendorColorPalette.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: HospitalVendorColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (appointments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 32,
                    color: HospitalVendorColorPalette.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No appointments',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment.time} - ${appointment.date}',
                        style: TextStyle(
                          fontSize: 12,
                          color: HospitalVendorColorPalette.textSecondary,
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

  Widget _buildFootfallSection(BuildContext context, HospitalDashboardViewModel viewModel) {
    // Dummy data for daily footfall
    final dummyFootfall = {
      '9 AM': 15,
      '10 AM': 25,
      '11 AM': 30,
      '12 PM': 35,
      '1 PM': 40,
      '2 PM': 45,
      '3 PM': 50,
      '4 PM': 45,
      '5 PM': 40,
      '6 PM': 35,
      '7 PM': 30,
      '8 PM': 25,
    };

    final maxValue = dummyFootfall.values.reduce(math.max);
    final total = dummyFootfall.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Footfall Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HospitalVendorColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFootfallCard(
                context,
                'Peak Hour',
                '2 PM',
                Icons.access_time,
                HospitalVendorColorPalette.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFootfallCard(
                context,
                'Peak Day',
                'Monday',
                Icons.calendar_today,
                HospitalVendorColorPalette.secondaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HospitalVendorColorPalette.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: HospitalVendorColorPalette.shadowLight,
                blurRadius: 8,
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
                    'Daily Footfall',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: HospitalVendorColorPalette.textPrimary,
                    ),
                  ),
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      color: HospitalVendorColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyFootfall.length,
                  itemBuilder: (context, index) {
                    final entry = dummyFootfall.entries.elementAt(index);
                    final height = (entry.value / maxValue) * 150;
                    
                    return Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            width: 20,
                            decoration: BoxDecoration(
                              color: HospitalVendorColorPalette.primaryBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 10,
                              color: HospitalVendorColorPalette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: HospitalVendorColorPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: $total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: HospitalVendorColorPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFootfallCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HospitalVendorColorPalette.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: HospitalVendorColorPalette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: HospitalVendorColorPalette.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection(BuildContext context, HospitalDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demographics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HospitalVendorColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDemographicsCard(
                context,
                'Age Groups',
                viewModel.ageGroupDistribution,
                HospitalVendorColorPalette.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDemographicsCard(
                context,
                'Health Conditions',
                viewModel.healthConditions,
                HospitalVendorColorPalette.secondaryTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemographicsCard(
    BuildContext context,
    String title,
    Map<String, int> data,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HospitalVendorColorPalette.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: HospitalVendorColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: HospitalVendorColorPalette.textSecondary,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: HospitalVendorColorPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / data.values.reduce(math.max),
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
} 