import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
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
    // Call fetchOrders when the screen is initialized
    final viewModel = Provider.of<TrackOrderViewModel>(context, listen: false);
    viewModel.fetchOrders();
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
      body: Consumer<TrackOrderViewModel>(
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
              children: [
                // Loop through orders and display each one
                ...viewModel.orders.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TrackingOrderCard(order: order),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
