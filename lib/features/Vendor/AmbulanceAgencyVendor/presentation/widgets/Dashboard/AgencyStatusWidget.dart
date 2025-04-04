import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyViewModel.dart';

class AgencyStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final agencyViewModel = Provider.of<AgencyViewModel>(context);

    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Agency Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Current Status: ${agencyViewModel.agency.isLive ? 'Live' : 'Offline'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Switch(
              value: agencyViewModel.agency.isLive,
              onChanged: (_) => agencyViewModel.toggleAgencyStatus(),
            ),
            Text(
              agencyViewModel.agency.isLive
                  ? "Agency is live and can accept booking requests."
                  : "Agency is offline. No bookings can be accepted.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
