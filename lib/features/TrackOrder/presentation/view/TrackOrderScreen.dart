import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/AmbulanceBookingTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/BloodBankBookingTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/TrackingOrderCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:flutter/rendering.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
      viewModel.fetchOrdersAndCartItems();
      viewModel.fetchActiveAmbulanceBookings();
      viewModel.fetchBloodBankBookings();
    });
  }

  Future<void> _refreshData() async {
    final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
    await viewModel.fetchOrdersAndCartItems();
    await viewModel.fetchActiveAmbulanceBookings();
    await viewModel.fetchBloodBankBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: ColorPalette.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: ColorPalette.primaryColor,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: ColorPalette.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Track Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    background: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                ColorPalette.primaryColor,
                                ColorPalette.primaryColor.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Consumer<TrackOrderViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return _buildLoadingState();
                      }
                      if (viewModel.error != null) {
                        return _buildErrorState(viewModel.error!);
                      }
                      if (viewModel.orders.isEmpty && 
                          viewModel.ambulanceBookings.isEmpty && 
                          viewModel.bloodBankBookings.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildOrdersList(viewModel);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: ColorPalette.primaryColor));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        error,
        style: TextStyle(color: ColorPalette.textColor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No orders found.',
        style: TextStyle(color: ColorPalette.textColor),
      ),
    );
  }

  Widget _buildOrdersList(TrackOrderViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.bloodBankBookings.isNotEmpty) ...[
            const Text(
              'Blood Bank Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            BloodBankBookingTrackingCard(bookings: viewModel.bloodBankBookings),
            const SizedBox(height: 20),
          ],
          if (viewModel.ambulanceBookings.isNotEmpty) ...[
            const Text(
              'Ambulance Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AmbulanceBookingTrackingCard(bookings: viewModel.ambulanceBookings),
            const SizedBox(height: 20),
          ],
          if (viewModel.orders.isNotEmpty) ...[
            const Text(
              'Medicine Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TrackingOrderCard(viewModel: viewModel),
          ],
        ],
      ),
    );
  }
}
