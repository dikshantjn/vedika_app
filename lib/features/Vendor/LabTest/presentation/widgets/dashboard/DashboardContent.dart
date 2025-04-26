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
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
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