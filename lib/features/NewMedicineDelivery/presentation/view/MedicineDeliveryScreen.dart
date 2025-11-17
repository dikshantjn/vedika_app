import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/viewmodel/MedicineDeliveryViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';

import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/widgets/MedicineDeliverySearchBar.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/widgets/MedicineDeliveryUploadPrescription.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart' show MainScreenNavigator;

import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicineDeliveryScreen extends StatefulWidget {
  const MedicineDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<MedicineDeliveryScreen> createState() => _MedicineDeliveryScreenState();
}

class _MedicineDeliveryScreenState extends State<MedicineDeliveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  Set<String> _expandedStoreIds = {}; // Track expanded stores

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineDeliveryViewModel>().initialize();
    });
  }

  void _onScroll() {
    final bool showTitle = _scrollController.hasClients && _scrollController.offset > 80;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),

    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: ColorPalette.primaryColor,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: const Text(
          'Medicine Delivery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        onPressed: () {
          if (MainScreenNavigator.instance.canGoBack) {
            MainScreenNavigator.instance.goBack();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorPalette.primaryColor,
                ColorPalette.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Medicine Delivery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find nearby medical stores & order medicines',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildSearchAndFilters(),
              _buildStoresList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          MedicineDeliverySearchBar(),
          SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.track_changes_rounded,
            label: 'Track Your Order',
            color: ColorPalette.primaryColor,
            onPressed: () => _navigateToTrackOrder(),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history_rounded,
            label: 'Order History',
            color: Colors.blue[600]!,
            onPressed: () => _navigateToOrderHistory(),
          ),
        ),
      ],
    );
  }




  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorPalette.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : ColorPalette.primaryColor,
              ),
              SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : ColorPalette.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(VendorMedicalStoreProfile store) {
    final storeId = store.vendorId ?? store.generatedId ?? '';
    final isExpanded = _expandedStoreIds.contains(storeId);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Header Section
          Padding(
            padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                    // Store Photo/Icon
                _buildStorePhoto(store),
                SizedBox(width: 16),
                    // Store Name and Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            store.name,
                        style: TextStyle(
                              fontSize: 18,
                          fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                              letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                      Text(
                        'Medical Store',
                        style: TextStyle(
                                  fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse Icon
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedStoreIds.remove(storeId);
                          } else {
                            _expandedStoreIds.add(storeId);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
                // Action Buttons Row
            Row(
              children: [
                Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_rounded,
                    label: 'Call',
                    color: Colors.green[600]!,
                    onPressed: () => _handleCall(store),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                      child: _buildActionButton(
                    icon: Icons.upload_file_rounded,
                        label: 'Upload',
                    color: Colors.orange[600]!,
                    onPressed: () => _showUploadPrescription(context, store),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
          
          // Expanded Details Section
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: isWideScreen
                        ? _buildHorizontalLayout(store)
                        : _buildVerticalLayout(store),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHorizontalLayout(VendorMedicalStoreProfile store) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.address.isNotEmpty)
                _buildDetailItem(Icons.location_on_rounded, 'Address', store.address),
              if (store.landmark.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDetailItem(Icons.place_rounded, 'Landmark', store.landmark),
              ],
              if (store.city.isNotEmpty || store.state.isNotEmpty || store.pincode.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDetailItem(
                  Icons.location_city_rounded,
                  'Location',
                  '${store.city.isNotEmpty ? store.city : ''}${store.city.isNotEmpty && store.state.isNotEmpty ? ', ' : ''}${store.state.isNotEmpty ? store.state : ''}${store.pincode.isNotEmpty ? ' ${store.pincode}' : ''}'.trim(),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 24),
        // Right Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.emailId.isNotEmpty)
                _buildDetailItem(Icons.email_rounded, 'Email', store.emailId),
              if (store.storeTiming.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDetailItem(Icons.access_time_rounded, 'Store Timing', store.storeTiming),
              ],
              if (store.storeDays.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDetailItem(Icons.calendar_today_rounded, 'Store Days', store.storeDays),
              ],
              if (store.medicineType.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildDetailItem(Icons.medication_liquid_rounded, 'Medicine Type', store.medicineType),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(VendorMedicalStoreProfile store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (store.address.isNotEmpty)
          _buildDetailItem(Icons.location_on_rounded, 'Address', store.address),
        if (store.landmark.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(Icons.place_rounded, 'Landmark', store.landmark),
        ],
        if (store.city.isNotEmpty || store.state.isNotEmpty || store.pincode.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(
            Icons.location_city_rounded,
            'Location',
            '${store.city.isNotEmpty ? store.city : ''}${store.city.isNotEmpty && store.state.isNotEmpty ? ', ' : ''}${store.state.isNotEmpty ? store.state : ''}${store.pincode.isNotEmpty ? ' ${store.pincode}' : ''}'.trim(),
          ),
        ],
        if (store.emailId.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(Icons.email_rounded, 'Email', store.emailId),
        ],
        if (store.storeTiming.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(Icons.access_time_rounded, 'Store Timing', store.storeTiming),
        ],
        if (store.storeDays.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(Icons.calendar_today_rounded, 'Store Days', store.storeDays),
        ],
        if (store.medicineType.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildDetailItem(Icons.medication_liquid_rounded, 'Medicine Type', store.medicineType),
        ],
      ],
    );
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: ColorPalette.primaryColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStorePhoto(VendorMedicalStoreProfile store) {
    // Get the first photo URL if available
    String? photoUrl;
    if (store.photos.isNotEmpty) {
      photoUrl = store.photos.first;
      // Ensure it's a valid URL
      if (photoUrl != null && 
          !photoUrl.startsWith('http://') && 
          !photoUrl.startsWith('https://')) {
        photoUrl = null;
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor.withOpacity(0.15),
            ColorPalette.primaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                photoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Show icon if image fails to load
                  return Icon(
                    Icons.local_pharmacy_rounded,
                    color: ColorPalette.primaryColor,
                    size: 28,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  // Show loading indicator while image loads
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : Icon(
              Icons.local_pharmacy_rounded,
              color: ColorPalette.primaryColor,
              size: 28,
            ),
    );
  }


  Widget _buildStoresList() {
    return Consumer<MedicineDeliveryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return _buildLoadingShimmer();
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorWidget(viewModel.errorMessage!);
        }

        if (viewModel.medicalStores.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: viewModel.medicalStores.length,
          itemBuilder: (context, index) {
            final store = viewModel.medicalStores[index];
            return _buildStoreCard(store);
          },
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            height: 160,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: EdgeInsets.all(32),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<MedicineDeliveryViewModel>().refresh(),
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(32),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No medical stores found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),

        ],
      ),
    );
  }



  void _showStoreDetails(BuildContext context, VendorMedicalStoreProfile store) {
    // Navigate to store details page
    // You can implement this based on your navigation structure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Store details for ${store.name}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showUploadPrescription(BuildContext context, VendorMedicalStoreProfile store) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicineDeliveryUploadPrescription(store: store),
    );
  }

  void _handleCall(VendorMedicalStoreProfile store) {
    final String phone = store.contactNumber;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No contact number available'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    final Uri uri = Uri(scheme: 'tel', path: phone);
    launchUrl(uri);
  }

  void _navigateToTrackOrder() {
    Navigator.pushNamed(context, '/trackOrder');
  }

  void _navigateToOrderHistory() {
    Navigator.pushNamed(context, '/orderHistory');
  }

}
