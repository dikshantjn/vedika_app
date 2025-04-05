import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyProfileViewModel.dart';

class AgencyServiceInfoSection extends StatelessWidget {
  final AmbulanceAgencyProfileViewModel viewModel;

  const AgencyServiceInfoSection({super.key, required this.viewModel});

  Widget _buildInfoBox(String label, String value, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agency = viewModel.agency;

    if (agency == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox("No. of Ambulances", agency.numOfAmbulances.toString()),
        _buildInfoBox("Types", agency.ambulanceTypes.join(", ")),
        _buildInfoBox("GPS Available", agency.gpsTrackingAvailable ? "Yes" : "No"),
        // _buildInfoBox("24x7 Service", agency.is24x7Available ? "Yes" : "No"),
        // _buildInfoBox("Distance Limit", "${agency.distanceLimit} km"),
        _buildInfoBox("Driver KYC", agency.driverKYC ? "Completed" : "Pending"),
        _buildInfoBox("Driver Trained", agency.driverTrained ? "Yes" : "No"),
      ],
    );
  }

}
