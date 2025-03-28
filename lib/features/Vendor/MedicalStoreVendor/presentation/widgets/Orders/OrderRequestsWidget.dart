import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/shared/utils/FileOpenHelper.dart';

class OrderRequestsWidget extends StatelessWidget {
  final MedicineOrderViewModel viewModel;

  const OrderRequestsWidget({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.prescriptionRequests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                "No prescription requests found",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "Prescription Requests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.prescriptionRequests.length,
          padding: const EdgeInsets.only(bottom: 12),
          itemBuilder: (context, index) {
            final request = viewModel.prescriptionRequests[index];
            return _buildRequestCard(context, request);
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, request) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Customer Name & Status ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Customer Name
              Text(
                "Customer: ${request.user?.name ?? "Unknown"}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),

              // Prescription Status Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.prescriptionAcceptedStatus).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(request.prescriptionAcceptedStatus),
                      color: _getStatusColor(request.prescriptionAcceptedStatus),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      request.prescriptionAcceptedStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _getStatusColor(request.prescriptionAcceptedStatus),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- Date ---
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.blueAccent),
              const SizedBox(width: 6),
              Text(
                "Date: ${DateFormat("d MMMM yyyy, h:mm a").format(request.createdAt)}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- Buttons Row (View Prescription & Accept Prescription) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View Prescription Button
              OutlinedButton(
                onPressed: () {
                  if (request.prescriptionUrl != null && request.prescriptionUrl.isNotEmpty) {
                    FileOpenHelper.openFile(context, request.prescriptionUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No prescription file available")),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("View Prescription", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
              ),

              // Accept Prescription Button (only if status is "Pending")
              if (request.prescriptionAcceptedStatus == "Pending")
                OutlinedButton.icon(
                  onPressed: () => viewModel.acceptPrescription(request.prescriptionId),
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                  label: const Text("Accept Prescription", style: TextStyle(fontSize: 14, color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Verified":
        return Colors.blue;
      case "Completed":
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Accepted":
        return Icons.check_circle_outline;
      case "Verified":
        return Icons.verified;
      case "Completed":
        return Icons.done_all;
      default:
        return Icons.pending_actions;
    }
  }
}
