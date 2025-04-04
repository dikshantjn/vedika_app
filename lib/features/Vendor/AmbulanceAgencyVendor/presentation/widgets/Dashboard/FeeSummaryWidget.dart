import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/FeeViewModel.dart';

class FeeSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final feeViewModel = Provider.of<FeeViewModel>(context);

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fee Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Base Fee:"),
                Text("\$${feeViewModel.fee.baseFee.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("GST:"),
                Text("\$${feeViewModel.fee.gst.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Discount:"),
                Text("\$${feeViewModel.fee.discount.toStringAsFixed(2)}"),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${feeViewModel.fee.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
