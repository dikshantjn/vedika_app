import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/AmbulanceBookingTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/BloodBankBookingTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/TrackingOrderCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/ProductOrderTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/NewMedicineOrderTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:flutter/rendering.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Only print once during actual initialization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize once when the widget is first accessed
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
          viewModel.initSocketConnection();
        }
      });
    }
  }

  Future<void> _refreshData() async {
    final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
    await Future.wait([
      viewModel.fetchOrdersAndCartItems(),
      viewModel.fetchActiveAmbulanceBookings(),
      viewModel.fetchBloodBankBookings(),
      viewModel.fetchProductOrders(),
      viewModel.fetchActiveMedicineDeliveryOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: ColorPalette.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          top: false,
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
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: ColorPalette.primaryColor,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () {
                      final scope = MainScreenScope.maybeOf(context);
                      if (scope != null) {
                        scope.setIndex(0);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
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
                          viewModel.bloodBankBookings.isEmpty &&
                          viewModel.productOrders.isEmpty &&
                          viewModel.activeMedicineDeliveryOrders.isEmpty) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: ColorPalette.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorPalette.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your order Tracking will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(TrackOrderViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.productOrders.isNotEmpty) ...[
            const Text(
              'Product Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ProductOrderTrackingCard(orders: viewModel.productOrders),
            const SizedBox(height: 20),
          ],
          if (viewModel.bloodBankBookings.isNotEmpty) ...[
            const Text(
              'Blood Bank Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            BloodBankBookingTrackingCard(
              bookings: viewModel.bloodBankBookings,
              onRefreshData: () => viewModel.fetchBloodBankBookings(),
            ),
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
            const SizedBox(height: 20),
          ],
          if (viewModel.activeMedicineDeliveryOrders.isNotEmpty) ...[
            const Text(
              'Active Medicine Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            NewMedicineOrderTrackingCard(viewModel: viewModel),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
