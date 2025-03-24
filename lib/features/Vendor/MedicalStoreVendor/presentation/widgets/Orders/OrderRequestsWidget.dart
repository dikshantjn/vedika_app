import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';

class OrderRequestsWidget extends StatelessWidget {
  final MedicineOrderViewModel viewModel;

  const OrderRequestsWidget({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Prescription Requests",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.prescriptionRequests.length,
            itemBuilder: (context, index) {
              final request = viewModel.prescriptionRequests[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name & Modern Popup Menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Customer: NA",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        if (!request.requestAcceptedStatus)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "accept_prescription") {
                                viewModel.acceptPrescription(request.prescriptionId);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
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
                    SizedBox(height: 8),

                    // Prescription ID & View Button in Same Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Prescription ID: ${request.prescriptionId}",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // Handle View Prescription Action
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("View Prescription", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // Created Date & Request Accepted Status in Same Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Created: ${DateFormat.yMMMd().format(request.createdAt)}",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            },
          ),
        ),
      ],
    );
  }
}
