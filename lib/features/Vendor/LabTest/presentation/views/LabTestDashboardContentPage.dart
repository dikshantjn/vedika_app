import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/DashboardCard.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/BookingList.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/widgets/dashboard/BookingChart.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/DiagnosticCenterProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/LabTestAnalyticsViewModel.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

class LabTestDashboardContentPage extends StatefulWidget {
  const LabTestDashboardContentPage({Key? key}) : super(key: key);

  @override
  State<LabTestDashboardContentPage> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<LabTestDashboardContentPage> {
  bool _isActive = false;
  bool _isLoading = false;
  bool _isProfileLoading = false;
  final VendorService _vendorService = VendorService();
  final VendorLoginService _loginService = VendorLoginService();
  final LabTestService _labTestService = LabTestService();
  final Logger _logger = Logger();
  DiagnosticCenter? _profile;

  @override
  void initState() {
    super.initState();
    _loadVendorStatus();
    _loadLabProfile();
  }

  Future<void> _loadLabProfile() async {
    try {
      setState(() {
        _isProfileLoading = true;
      });
      
      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();
      
      if (vendorId != null) {
        // Get lab profile
        final profile = await _labTestService.getLabProfile(vendorId);
        
        if (mounted) {
        setState(() {
          _profile = profile;
          _isProfileLoading = false;
        });
        
        _logger.i('Lab profile loaded successfully: ${_profile?.name}');
        }
      } else {
        if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
        }
        _logger.e('Failed to load lab profile: Vendor ID not found');
      }
    } catch (e) {
      _logger.e('Error loading lab profile: $e');
      if (mounted) {
      setState(() {
        _isProfileLoading = false;
      });
      }
    }
  }

  Future<void> _loadVendorStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();
      
      if (vendorId != null) {
        // Get vendor status
        final bool status = await _vendorService.getVendorStatus(vendorId);
        
        if (mounted) {
        setState(() {
          _isActive = status;
          _isLoading = false;
        });
        }
      } else {
        if (mounted) {
        setState(() {
          _isLoading = false;
        });
        }
      }
    } catch (e) {
      print('Error loading vendor status: $e');
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
      }
    }
  }

  Future<void> _toggleVendorStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();
      
      if (vendorId != null) {
        // Toggle vendor status
        final bool newStatus = await _vendorService.toggleVendorStatus(vendorId);
        
        if (mounted) {
        setState(() {
          _isActive = newStatus;
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_isActive ? 'Active' : 'Inactive'}'),
            backgroundColor: _isActive ? Colors.green : Colors.red,
          ),
        );
        }
      } else {
        if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update status: Vendor ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        }
      }
    } catch (e) {
      print('Error toggling vendor status: $e');
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LabTestAnalyticsViewModel>(
      create: (_) => LabTestAnalyticsViewModel()..initialize(),
      child: Consumer<LabTestAnalyticsViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildPeriodSelector(vm),
                const SizedBox(height: 16),
                if (vm.isLoading) _buildAnalyticsLoading() else ...[
                  _buildOverview(vm),
                  const SizedBox(height: 16),
                  _buildPerformanceKpis(vm),
                  const SizedBox(height: 16),
                  _buildQuickTrends(vm),
                ],
                const SizedBox(height: 24),
                _buildTodayBookings(),
                const SizedBox(height: 24),
                _buildUpcomingBookings(),
                const SizedBox(height: 24),
                _buildBookingHistory(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
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
      child: _isProfileLoading 
          ? _buildShimmerEffect()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: _profile != null && (_profile!.centerPhotosUrl != null && _profile!.centerPhotosUrl.isNotEmpty)
                  ? CircleAvatar(
                      radius: 22,
                      backgroundColor: LabTestColorPalette.backgroundCard,
                      child: ClipOval(
                        child: Image.network(
                          _profile!.centerPhotosUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // If centerPhotosUrl fails, try filesAndImages
                            if (_profile?.filesAndImages != null && _profile!.filesAndImages.isNotEmpty) {
                              return ClipOval(
                                child: Image.network(
                                  _profile!.filesAndImages.first['url'] ?? '',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.science_outlined,
                                      size: 18,
                                      color: LabTestColorPalette.primaryBlue,
                                    );
                                  },
                                ),
                              );
                            }
                            return Icon(
                              Icons.science_outlined,
                              size: 18,
                              color: LabTestColorPalette.primaryBlue,
                            );
                          },
                        ),
                      ),
                    )
                  : _profile != null && _profile!.filesAndImages.isNotEmpty
                    ? CircleAvatar(
                        radius: 22,
                        backgroundColor: LabTestColorPalette.backgroundCard,
                        child: ClipOval(
                          child: Image.network(
                            _profile!.filesAndImages.first['url'] ?? '',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.science_outlined,
                                size: 18,
                                color: LabTestColorPalette.primaryBlue,
                              );
                            },
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 22,
                        backgroundColor: LabTestColorPalette.backgroundCard,
                        child: Icon(
                          Icons.science_outlined,
                          size: 18,
                          color: LabTestColorPalette.primaryBlue,
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
                      _profile?.name ?? 'Lab Center',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?.address ?? 'Address not set',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isLoading ? null : _toggleVendorStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _isLoading 
                          ? SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.circle,
                              size: 10,
                              color: _isActive 
                                  ? LabTestColorPalette.successGreen
                                  : LabTestColorPalette.errorRed,
                            ),
                      const SizedBox(width: 6),
                      Text(
                        _isActive ? 'Active' : 'Inactive',
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
                    'You have ${_profile?.testTypes.length ?? 0} test types available',
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
  
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar placeholder
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Status button placeholder
              Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info box placeholder
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(LabTestAnalyticsViewModel vm) {
    final overview = vm.analytics['overview'] as Map<String, dynamic>?;
    if (overview == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 260,
                child: _metricCardLarge(
                  title: vm.selectedPeriod == 'Today' ? 'Total Bookings (Today)' : 'Total Bookings (Week)',
                  value: '${overview['totalBookings'] ?? 0}',
                  icon: Icons.calendar_today,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: _metricCardLarge(
                  title: 'Pending Requests',
                  value: '${overview['pendingRequests'] ?? 0}',
                  icon: Icons.pending_actions,
                  color: LabTestColorPalette.warningYellow,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: _metricCardLarge(
                  title: 'Tests in Progress',
                  value: '${overview['testsInProgress'] ?? 0}',
                  icon: Icons.science,
                  color: LabTestColorPalette.secondaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: _metricCardLarge(
                  title: 'Completed Tests',
                  value: '${overview['completedTests'] ?? 0}',
                  icon: Icons.verified,
                  color: LabTestColorPalette.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 260,
                child: _metricCardLarge(
                  title: 'Revenue',
                  value: '₹${((overview['revenue'] ?? 0.0) as num).toDouble().toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: LabTestColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceKpis(LabTestAnalyticsViewModel vm) {
    final performance = vm.analytics['performance'] as Map<String, dynamic>?;
    if (performance == null) return const SizedBox.shrink();

    String formatMins(int mins) {
      if (mins >= 60) {
        final h = mins ~/ 60;
        final m = mins % 60;
        return '${h}h ${m}m';
      }
      return '${mins}m';
    }

    final avgConfirm = (performance['avgTimeToConfirmMins'] as int?) ?? 0;
    final avgUpload = (performance['avgTimeToUploadReportMins'] as int?) ?? 0;
    final cancelRate = ((performance['cancellationRate'] as double?) ?? 0.0) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance KPIs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return SizedBox(
                    width: 240,
                    child: _kpiCard(
                      title: 'Avg Time to Confirm',
                      value: formatMins(avgConfirm),
                      icon: Icons.schedule,
                      color: LabTestColorPalette.primaryBlue,
                    ),
                  );
                case 1:
                  return SizedBox(
                    width: 240,
                    child: _kpiCard(
                      title: 'Avg Time to Upload Report',
                      value: formatMins(avgUpload),
                      icon: Icons.file_upload_outlined,
                      color: LabTestColorPalette.secondaryTeal,
                    ),
                  );
                default:
                  return SizedBox(
                    width: 240,
                    child: _kpiCard(
                      title: 'Cancellation Rate',
                      value: '${cancelRate.toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      color: LabTestColorPalette.errorRed,
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: LabTestColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTrends(LabTestAnalyticsViewModel vm) {
    final trends = vm.analytics['trends'] as Map<String, dynamic>?;
    if (trends == null) return const SizedBox.shrink();

    final Map<String, int> topTests = (trends['topTestTypes'] as Map?)?.cast<String, int>() ?? {};
    final int maxCount = topTests.values.isEmpty ? 1 : topTests.values.reduce((a, b) => a > b ? a : b);
    final double homeRatio = (trends['homeCollectionRatio'] as double? ?? 0.0);
    final Map<String, int> nvr = (trends['newVsReturning'] as Map?)?.cast<String, int>() ?? {'new': 0, 'returning': 0};
    final int totalCust = (nvr['new'] ?? 0) + (nvr['returning'] ?? 0);
    final double newPct = totalCust == 0 ? 0 : (nvr['new']! / totalCust);
    final double retPct = totalCust == 0 ? 0 : (nvr['returning']! / totalCust);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Top Test Types card
              SizedBox(
                width: 280,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LabTestColorPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
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
                        children: const [
                          Icon(Icons.bar_chart, size: 18, color: LabTestColorPalette.primaryBlue),
                          SizedBox(width: 6),
                          Text(
                            'Top Test Types',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: LabTestColorPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...topTests.entries
                          .take(3)
                          .map((e) => _barRow(label: e.key, value: e.value, maxValue: maxCount))
                          .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Home Collection Ratio card
              SizedBox(
                width: 240,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LabTestColorPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
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
                        children: const [
                          Icon(Icons.home_outlined, size: 18, color: LabTestColorPalette.secondaryTeal),
                          SizedBox(width: 6),
                          Text(
                            'Home Sample Collection',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: LabTestColorPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(homeRatio * 100).toStringAsFixed(0)}% Home, ${(100 - homeRatio * 100).toStringAsFixed(0)}% Walk-in',
                        style: const TextStyle(color: LabTestColorPalette.textPrimary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: homeRatio.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          color: LabTestColorPalette.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // New vs Returning card
              SizedBox(
                width: 240,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LabTestColorPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
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
                        children: const [
                          Icon(Icons.pie_chart_outline, size: 18, color: LabTestColorPalette.primaryBlue),
                          SizedBox(width: 6),
                          Text(
                            'New vs Returning',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: LabTestColorPalette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: (newPct * 1000).round(),
                            child: Container(
                              height: 12,
                              decoration: const BoxDecoration(
                                color: LabTestColorPalette.primaryBlue,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: (retPct * 1000).round(),
                            child: Container(
                              height: 12,
                              decoration: const BoxDecoration(
                                color: LabTestColorPalette.successGreen,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('New ${(newPct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: LabTestColorPalette.textPrimary)),
                          Text('Returning ${(retPct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: LabTestColorPalette.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _barRow({required String label, required int value, required int maxValue}) {
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
                  style: const TextStyle(fontSize: 12, color: LabTestColorPalette.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Text('$value', style: const TextStyle(fontSize: 12, color: LabTestColorPalette.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: LabTestColorPalette.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCardLarge({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
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
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: LabTestColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(LabTestAnalyticsViewModel vm) {
    const options = ['Today', 'This Week'];
    return Row(
      children: options.map((p) {
        final bool selected = vm.selectedPeriod == p;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(p),
            selected: selected,
            onSelected: (_) => vm.setPeriod(p),
            selectedColor: LabTestColorPalette.primaryBlue.withOpacity(0.15),
            labelStyle: TextStyle(
              color: selected ? LabTestColorPalette.primaryBlue : LabTestColorPalette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview horizontal placeholders
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) => Padding(
                    padding: EdgeInsets.only(right: index == 4 ? 0 : 12),
                    child: Container(
                      width: 260,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 16),
          // Performance KPIs horizontal placeholders
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => Container(
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 3,
            ),
          ),
          const SizedBox(height: 16),
          // Quick Trends horizontal placeholders
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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