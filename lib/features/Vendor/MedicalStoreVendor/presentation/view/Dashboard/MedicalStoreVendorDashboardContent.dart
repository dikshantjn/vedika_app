import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Dashboard/MedicalStoreAnalyticsCard.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Dashboard/MedicineOrderCard.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Dashboard/MedicineReturnRequestCard.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final viewModel = Provider.of<MedicalStoreVendorDashboardViewModel>(context, listen: false);
    await viewModel.fetchOrdersAndRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading Indicator
        } else if (snapshot.hasError) {
          return Center(child: Text("Error fetching data: ${snapshot.error}"));
        }

        return Consumer<MedicalStoreVendorDashboardViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _buildCardContainer(
                    child: AnalyticsCard(
                      analytics: viewModel.analytics,
                      onViewAll: () {
                        print("View All Analytics clicked!");
                        // Navigate to detailed analytics page here
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildCardContainer(
                    child: Column(
                      children: viewModel.orders.isNotEmpty
                          ? [
                        OrderCard(
                          orders: viewModel.orders.take(5).toList(), // First 5 orders
                          viewModel:  Provider.of<MedicineOrderViewModel>(context, listen: false),
                          onViewAll: () {
                            print("View All Orders clicked");
                          },
                        ),
                      ]
                          : [_buildEmptyState("No Incoming Orders")],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildCardContainer(
                    child: SizedBox(
                      child: viewModel.returnRequests.isNotEmpty
                          ? ReturnRequestCard(
                        returnRequests: viewModel.returnRequests,
                        onViewAll: () {
                          print("View All Return Requests clicked");
                        },
                        onTap: (request) {
                          print("Tapped on return request: ${request.orderId}");
                          return () {}; // ✅ Explicitly returning a VoidCallback
                        },
                      )
                          : _buildEmptyState("No Return Requests"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
