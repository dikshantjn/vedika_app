import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Ward.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/WardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/AddEditWardDetailsScreen.dart';

class WardDetailsScreen extends StatefulWidget {
  const WardDetailsScreen({Key? key}) : super(key: key);

  @override
  _WardDetailsScreenState createState() => _WardDetailsScreenState();
}

class _WardDetailsScreenState extends State<WardDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the build is complete before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWards();
    });
  }

  Future<void> _loadWards() async {
    final hospitalId = Provider.of<HospitalDashboardViewModel>(context, listen: false)
        .hospitalProfile?.vendorId;
    if (hospitalId != null) {
      await Provider.of<WardViewModel>(context, listen: false).fetchWards(hospitalId);
    }
  }

  void _navigateToAddEditWard([Ward? ward]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWardDetailsScreen(ward: ward),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<WardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWards,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.wards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bed_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No wards added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: viewModel.wards.length,
            itemBuilder: (context, index) {
              final ward = viewModel.wards[index];
              return _buildWardBox(ward);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditWard(),
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWardBox(Ward ward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Status Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ward.wardType,
                          style: TextStyle(
                            color: HospitalVendorColorPalette.primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _navigateToAddEditWard(ward),
                      color: HospitalVendorColorPalette.primaryBlue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showDeleteConfirmation(ward),
                      color: Colors.red[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStatBox(
                  'Total Beds',
                  ward.totalBeds.toString(),
                  Icons.bed_outlined,
                ),
                _buildStatBox(
                  'Available',
                  ward.availableBeds.toString(),
                  Icons.check_circle_outline,
                  isMiddle: true,
                ),
                _buildStatBox(
                  'Price/Day',
                  '₹${ward.pricePerDay}',
                  Icons.currency_rupee,
                ),
              ],
            ),
          ),

          // Features Section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (ward.isAC)
                      _buildFeatureChip('AC', Icons.ac_unit),
                    if (ward.hasAttachedBathroom)
                      _buildFeatureChip('Attached Bathroom', Icons.bathroom_outlined),
                    if (ward.isIsolation)
                      _buildFeatureChip('Isolation', Icons.shield_outlined),
                    ...ward.facilities.map((f) => _buildFeatureChip(f, Icons.check)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, {bool isMiddle = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            left: isMiddle ? const BorderSide(color: Colors.grey, width: 0.5) : BorderSide.none,
            right: isMiddle ? const BorderSide(color: Colors.grey, width: 0.5) : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: HospitalVendorColorPalette.primaryBlue, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: HospitalVendorColorPalette.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: HospitalVendorColorPalette.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Ward ward) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 32,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Delete Ward',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Ward Name
              Text(
                ward.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                'This action cannot be undone. All ward data will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text('Deleting ward...'),
                              ],
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        final success = await Provider.of<WardViewModel>(
                          context,
                          listen: false,
                        ).deleteWard(ward.wardId);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 16),
                                  const Text('Ward deleted successfully'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 