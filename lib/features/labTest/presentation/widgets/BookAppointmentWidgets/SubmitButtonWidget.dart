import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabAppointmentPaymentService.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';

class SubmitButtonWidget extends StatefulWidget {
  final LabTestAppointmentViewModel viewModel;
  final LabModel lab;

  const SubmitButtonWidget({
    Key? key,
    required this.viewModel,
    required this.lab,
  }) : super(key: key);

  @override
  _SubmitButtonWidgetState createState() => _SubmitButtonWidgetState();
}

class _SubmitButtonWidgetState extends State<SubmitButtonWidget> {
  bool _isLoading = false;

  // Function to display the appointment summary in a bottom sheet
  void _showAppointmentSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        double totalPrice = widget.viewModel.selectedTests.fold(0.0, (sum, test) => sum + test.price);

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
              ...widget.viewModel.selectedTests.map((LabTestModel test) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(test.name, style: TextStyle(fontSize: 16)),
                      Text("₹${test.price.toStringAsFixed(2)}",
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
                  onPressed: () => _handleConfirmAppointment(context, totalPrice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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

  // Function to validate fields and proceed with payment
  void _handleConfirmAppointment(BuildContext context, double totalPrice) {
    if (widget.viewModel.formKey.currentState!.validate()) {
      if (widget.viewModel.selectedTests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one test")),
        );
        return;
      }

      if (widget.viewModel.selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a date")),
        );
        return;
      }

      if (widget.viewModel.selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a time")),
        );
        return;
      }

      Navigator.pop(context); // Close bottom sheet
      _startPayment(context, totalPrice);
    }
  }

  // Function to initiate payment using Razorpay
  void _startPayment(BuildContext context, double totalPrice) {
    setState(() => _isLoading = true);

    final labPaymentService = LabAppointmentPaymentService();

    labPaymentService.onPaymentSuccess = (PaymentSuccessResponse response) {
      setState(() => _isLoading = false);
      widget.viewModel.confirmAppointment(context, widget.lab);
      print('Payment successful: ${response.paymentId}');
    };

    labPaymentService.onPaymentError = (PaymentFailureResponse response) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: ${response.message}')),
      );
      print('Payment error: ${response.message}');
    };

    labPaymentService.onPaymentCancelled = (PaymentFailureResponse response) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment cancelled: ${response.message}')),
      );
      print('Payment cancelled: ${response.message}');
    };

    try {
      labPaymentService.openLabAppointmentPaymentGateway(
        amount: totalPrice.toInt(),
        key: ApiConstants.razorpayApiKey,
        patientName: 'John Doe', // Replace with actual patient name
        labName: widget.lab.name,
        appointmentDetails:
        'Lab Test Appointment for ${widget.viewModel.selectedTests.map((test) => test.name).join(', ')}',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting payment: $e')),
      );
      print('Error starting payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              widget.viewModel.validateFields();
              if (widget.viewModel.testError.value == null &&
                  widget.viewModel.dateError.value == null &&
                  widget.viewModel.timeError.value == null) {
                _showAppointmentSummary(context);
              }
            },
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
        ),
      ],
    );
  }
}
