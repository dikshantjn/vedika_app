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

class _MedicineOrderPageState extends State<MedicineOrderPage> with SingleTickerProviderStateMixin {
  late MedicineOrderViewModel viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MedicineOrderViewModel>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  Future<void> _fetchAllData() async {
    await viewModel.fetchPrescriptionRequests();
    await viewModel.fetchOrders();
  }

  // Public method to refresh data
  Future<void> refreshData() async {
    await _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: MedicalStoreVendorColorPalette.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: MedicalStoreVendorColorPalette.primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Requests",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Orders",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Consumer<MedicineOrderViewModel>(
              builder: (context, viewModel, child) {
                final isLoadingAll = viewModel.isLoadingRequests || viewModel.isLoadingOrders;

                if (isLoadingAll) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Prescription Requests Tab
                    RefreshIndicator(
                      color: MedicalStoreVendorColorPalette.primaryColor,
                      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
                      onRefresh: () async {
                        await viewModel.fetchPrescriptionRequests();
                      },
                      child: viewModel.prescriptionRequests.isEmpty
                          ? _buildEmptyState("No prescription requests found")
                          : SingleChildScrollView(
                              child: OrderRequestsWidget(
                                viewModel: viewModel,
                                onRequestAccepted: refreshData,
                              ),
                            ),
                    ),

                    // Orders Tab
                    RefreshIndicator(
                      color: MedicalStoreVendorColorPalette.primaryColor,
                      backgroundColor: MedicalStoreVendorColorPalette.backgroundColor,
                      onRefresh: () async {
                        await viewModel.fetchOrders();
                      },
                      child: viewModel.orders.isEmpty
                          ? _buildEmptyState("No orders found")
                          : SingleChildScrollView(
                              child: OrdersWidget(viewModel: viewModel),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
