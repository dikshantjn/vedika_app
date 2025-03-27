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
          shrinkWrap: true, // important
          physics: const NeverScrollableScrollPhysics(), // prevent nested scroll conflict
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
          // --- Prescription ID & Menu ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prescription ID: ${request.prescriptionId}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Remark: Prescription uploaded",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (!request.requestAcceptedStatus)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "accept_prescription") {
                      viewModel.acceptPrescription(request.prescriptionId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "accept_prescription",
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green),
                          SizedBox(width: 8),
                          Text("Accept Prescription"),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  elevation: 5,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // --- Customer Name ---
          Text(
            "Customer: ${request.user?.name ?? "Unknown"}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),

          // --- View Prescription Button ---
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("View Prescription", style: TextStyle(fontSize: 13, color: Colors.blueAccent)),
            ),
          ),
          const SizedBox(height: 6),

          // --- Created Date & Status ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Created: ${DateFormat.yMMMd().format(request.createdAt)}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: request.requestAcceptedStatus ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  request.requestAcceptedStatus ? "Accepted" : "Pending",
                  style: TextStyle(
                    color: request.requestAcceptedStatus ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
