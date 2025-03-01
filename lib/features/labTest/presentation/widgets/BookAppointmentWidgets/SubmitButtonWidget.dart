import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabAppointmentPaymentService.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';

class SubmitButtonWidget extends StatelessWidget {
  final LabTestAppointmentViewModel viewModel;
  final LabModel lab;

  const SubmitButtonWidget({
    Key? key,
    required this.viewModel,
    required this.lab,
  }) : super(key: key);

  // Function to display the appointment summary in a bottom sheet
  void _showAppointmentSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        double totalPrice = viewModel.selectedTests.fold(0.0, (sum, test) => sum + test.fee);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for the summary
              Center(
                child: Text(
                  "Appointment Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // List of selected tests
              ...viewModel.selectedTests.map((LabTestModel test) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(test.name, style: TextStyle(fontSize: 16)),
                      Text("₹${test.fee.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),

              Divider(),

              // Total Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 16),

              // Confirm Appointment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    // Call Razorpay service to initiate payment for lab appointment
                    final labPaymentService = LabAppointmentPaymentService();

                    labPaymentService.onPaymentSuccess = (PaymentSuccessResponse response) {
                      // Handle successful payment here
                      viewModel.confirmAppointment(context, lab);
                      print('Payment successful: ${response.paymentId}');
                    };

                    labPaymentService.onPaymentError = (PaymentFailureResponse response) {
                      // Handle payment failure here
                      print('Payment error: ${response.message}');
                    };

                    labPaymentService.onPaymentCancelled = (PaymentFailureResponse response) {
                      // Handle payment cancellation here
                      print('Payment cancelled: ${response.message}');
                    };

                    // Trigger the payment gateway
                    labPaymentService.openLabAppointmentPaymentGateway(
                      amount: totalPrice.toInt(),  // Send the amount as int (in INR)
                      key: ApiConstants.razorpayApiKey,    // Replace with your Razorpay key
                      patientName: 'John Doe',     // Replace with the patient's name
                      labName: lab.name,           // Pass the lab's name
                      appointmentDetails: 'Lab Test Appointment for ${viewModel.selectedTests.map((test) => test.name).join(', ')}', // Detailed description
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Confirm Appointment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showAppointmentSummary(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.symmetric(vertical: 14),
          elevation: 5,
        ),
        child: Text(
          "Book Appointment",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
