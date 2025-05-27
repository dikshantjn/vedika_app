import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Orders/PrescriptionPreviewScreen.dart';
import 'package:vedika_healthcare/shared/utils/FileOpenHelper.dart';

class OrderRequestsWidget extends StatefulWidget {
  final MedicineOrderViewModel viewModel;
  final Future<void> Function() onRequestAccepted;

  const OrderRequestsWidget({
    Key? key, 
    required this.viewModel,
    required this.onRequestAccepted,
  }) : super(key: key);

  @override
  State<OrderRequestsWidget> createState() => _OrderRequestsWidgetState();
}

class _OrderRequestsWidgetState extends State<OrderRequestsWidget> {
  String? _processingRequestId;

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Filter only pending requests
    final pendingRequests = widget.viewModel.prescriptionRequests
        .where((request) => request.prescriptionAcceptedStatus == "Pending")
        .toList();

    if (pendingRequests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                "No pending prescription requests",
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
            "Pending Prescription Requests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingRequests.length,
          padding: const EdgeInsets.only(bottom: 12),
          itemBuilder: (context, index) {
            final request = pendingRequests[index];
            return _buildRequestCard(context, request);
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, request) {
    final bool isProcessing = _processingRequestId == request.prescriptionId;

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
              Expanded(
                child: Text(
                  "Customer: ${request.user?.name ?? "Unknown"}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Prescription Status Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.prescriptionAcceptedStatus).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (request.prescriptionUrl != null && request.prescriptionUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrescriptionPreviewScreen(
                            prescriptionUrl: request.prescriptionUrl,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No prescription file available")),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "View Prescription",
                    style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Accept Prescription Button (only if status is "Pending")
              if (request.prescriptionAcceptedStatus == "Pending")
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : () async {
                      setState(() {
                        _processingRequestId = request.prescriptionId;
                      });
                      
                      try {
                        // Accept the prescription
                        await widget.viewModel.acceptPrescription(request.prescriptionId);
                        
                        // Refresh the parent page using the callback
                        await widget.onRequestAccepted();
                      } finally {
                        if (mounted) {
                          setState(() {
                            _processingRequestId = null;
                          });
                        }
                      }
                    },
                    icon: isProcessing 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    label: Text(
                      isProcessing ? "Accepting..." : "Accept",
                      style: TextStyle(
                        fontSize: 13,
                        color: isProcessing ? Colors.grey : Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      side: BorderSide(
                        color: isProcessing ? Colors.grey : Colors.green,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
      case "PrescriptionVerified":
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
      case "PrescriptionVerified":
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
