import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/OrderRequestsWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/OrdersWidget.dart';

class MedicineOrderPage extends StatefulWidget {
  const MedicineOrderPage({Key? key}) : super(key: key);

  @override
  _MedicineOrderPageState createState() => _MedicineOrderPageState();
}

class _MedicineOrderPageState extends State<MedicineOrderPage> {
  late MedicineOrderViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    await viewModel.fetchPrescriptionRequests();
    await viewModel.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
      body: Consumer<MedicineOrderViewModel>(
        builder: (context, viewModel, child) {
          final isLoadingAll = viewModel.isLoadingRequests || viewModel.isLoadingOrders;
          final hasRequests = viewModel.prescriptionRequests.isNotEmpty;
          final hasOrders = viewModel.orders.isNotEmpty;

          if (isLoadingAll) {
            // Show centered loader
            return Center(
              child: CircularProgressIndicator(
                color: MedicalStoreVendorColorPalette.primaryColor,
              ),
            );
          }

          return RefreshIndicator(
            color: MedicalStoreVendorColorPalette.primaryColor,
            backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
            onRefresh: _fetchAllData,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prescription Requests Section
                      if (viewModel.isLoadingRequests && !isLoadingAll)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (hasRequests)
                        OrderRequestsWidget(viewModel: viewModel),

                      // Divider only if both sections have content
                      if (hasRequests && hasOrders)
                        const Divider(),

                      // Orders Section
                      if (viewModel.isLoadingOrders && !isLoadingAll)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (hasOrders)
                        OrdersWidget(viewModel: viewModel),

                      // Empty state
                      if (!hasRequests && !hasOrders)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No prescription requests or orders found",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
