import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/AmbulanceBookingTrackingCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/Widgets/TrackingOrderCard.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

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
      viewModel.fetchActiveAmbulanceBookings(); // ✅ Added this line
    });
  }

  Future<void> _refreshData() async {
    final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
    await viewModel.fetchOrdersAndCartItems();
    await viewModel.fetchActiveAmbulanceBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
        title: const Text('Track Your Order'),
        centerTitle: true,
      ),
      drawer: DrawerMenu(),
      body: RefreshIndicator(
        onRefresh: _refreshData, // This triggers the refresh logic
        color: ColorPalette.primaryColor, // Set color of the refresh indicator
        child: Consumer<TrackOrderViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator(color: ColorPalette.primaryColor));
            }
            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: ColorPalette.textColor),
                ),
              );
            }

            if (viewModel.orders.isEmpty) {
              return Center(
                child: Text(
                  'No orders found.',
                  style: TextStyle(color: ColorPalette.textColor),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.ambulanceBookings.isNotEmpty) ...[
                    const Text(
                      'Ambulance Bookings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    AmbulanceBookingTrackingCard(bookings: viewModel.ambulanceBookings),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Medicine Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TrackingOrderCard(viewModel: viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
