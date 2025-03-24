import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/OrderRequestsWidget.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/OrdersWidget.dart';

class MedicineOrderPage extends StatefulWidget {
  const MedicineOrderPage({Key? key}) : super(key: key);

  @override
  _MedicineOrderPageState createState() => _MedicineOrderPageState();
}

class _MedicineOrderPageState extends State<MedicineOrderPage> {
  @override
  void initState() {
    super.initState();
    // Fetch prescription requests when the screen loads
    Provider.of<MedicineOrderViewModel>(context, listen: false).fetchPrescriptionRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineOrderViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Expanded(
              child: OrderRequestsWidget(viewModel: viewModel), // Pass ViewModel directly
            ),
            Divider(),
            Expanded(
              child: OrdersWidget(viewModel: viewModel), // Pass ViewModel directly
            ),
          ],
        );
      },
    );
  }
}
