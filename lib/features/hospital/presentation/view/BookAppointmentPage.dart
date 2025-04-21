import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalBookingPaymentService.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/HospitalInfoCard.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/PatientDetailsForm.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/TimeSlotSelection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BookAppointmentPage extends StatefulWidget {
  final HospitalProfile hospital;

  const BookAppointmentPage({Key? key, required this.hospital}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();
  final HospitalService _hospitalService = HospitalService();
  bool _isBookingPending = false;
  String? _bookingStatus;

  @override
  void initState() {
    super.initState();
    // Initialize hospital in viewModel after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<BookAppointmentViewModel>(context, listen: false);
      viewModel.selectHospital(widget.hospital);
    });
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.teal, size: 50),
              SizedBox(height: 10),
              Text(
                "Information Shared with Hospital",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 10),
              _buildInfoItem("Full Name"),
              _buildInfoItem("Age & Gender"),
              _buildInfoItem("Phone Number"),
              _buildInfoItem("Address"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("Got It", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.teal, size: 20),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Future<void> _handleBookingConfirmation(BuildContext context) async {
    final viewModel = Provider.of<BookAppointmentViewModel>(context, listen: false);
    
    if (viewModel.selectedPatientType == "Other" && !_patientFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all patient details")),
      );
      return;
    }

    if (!viewModel.isFormComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() {
      _isBookingPending = true;
    });

    try {
      String? userId = await StorageService.getUserId();
      final result = await _hospitalService.createBedBooking(
        vendorId: widget.hospital.vendorId ?? widget.hospital.generatedId ?? '',
        userId: userId!, // TODO: Replace with actual user ID
        hospitalId: widget.hospital.vendorId ?? widget.hospital.generatedId ?? '',
        bedType: viewModel.selectedBedType!.type,
        price: viewModel.selectedBedType!.price,
        paidAmount: 0.0,
        paymentStatus: 'pending',
        bookingDate: viewModel.selectedDate!,
        timeSlot: viewModel.selectedTimeSlot!,
        selectedDoctorId: viewModel.selectedDoctorId,
        status: 'pending',
      );

      setState(() {
        _isBookingPending = false;
        _bookingStatus = result['data']?['status'];
      });

      if (result['success'] == true) {
        _showBookingConfirmationDialog(context, result['message']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _isBookingPending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create booking: $e")),
      );
    }
  }

  void _showBookingConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Booking Request Sent",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Please wait for hospital approval. You will be notified once your booking is confirmed.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookAppointmentViewModel>(context);
    final razorpayService = HospitalBookingPaymentService();
    final bedTypes = BedType.getBedTypes();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Book Bed", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Info Card
            HospitalInfoCard(hospital: widget.hospital),
            SizedBox(height: 20),

            // Bed Type Selection
            Text("Select Bed Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<BedType>(
                    value: viewModel.selectedBedType,
                    isExpanded: true,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hint: Text('Select a bed type'),
                    items: bedTypes.map((bedType) {
                      return DropdownMenuItem<BedType>(
                        key: ValueKey(bedType.id),
                        value: bedType,
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bedType.type,
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "₹${bedType.price.toStringAsFixed(2)} - ${bedType.description}",
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (BedType? value) {
                      if (value != null) {
                        viewModel.selectBedType(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Appointment Date Picker
            Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DatePickerWidget(
              selectedDate: viewModel.selectedDate,
              onDatePicked: viewModel.selectDate,
            ),
            SizedBox(height: 20),

            // Time Slot Selection
            if (viewModel.selectedDate != null)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: TimeSlotSelection(
                  timeSlots: ["Morning", "Afternoon", "Evening", "Night"],
                  selectedTimeSlot: viewModel.selectedTimeSlot,
                  onTimeSlotSelected: viewModel.selectTimeSlot,
                ),
              ),

            // Patient Details Selection
            Text("Patient Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.selectPatientType("Self"),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: viewModel.selectedPatientType == "Self" ? Colors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Self",
                              style: TextStyle(
                                fontSize: 16,
                                color: viewModel.selectedPatientType == "Self" ? Colors.white : Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showInfoPopup(context),
                              child: Icon(
                                Icons.info_outline,
                                color: viewModel.selectedPatientType == "Self" ? Colors.white : Colors.teal,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.selectPatientType("Other"),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: viewModel.selectedPatientType == "Other" ? Colors.teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Other",
                            style: TextStyle(
                              fontSize: 16,
                              color: viewModel.selectedPatientType == "Other" ? Colors.white : Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Show Patient Details Form if "Other" is selected
            if (viewModel.selectedPatientType == "Other")
              PatientDetailsForm(formKey: _patientFormKey),

            // Price Display
            if (viewModel.selectedBedType != null) ...[
              Text("Bed Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(
                "₹${viewModel.selectedBedType!.price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 20),
            ],

            // Confirm Button or Make Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBookingPending
                    ? null
                    : () {
                        if (_bookingStatus == 'accepted') {
                          // Trigger Razorpay payment gateway
                          razorpayService.openPaymentGateway(
                            viewModel.selectedBedType!.price.toInt(),
                            ApiConstants.razorpayApiKey,
                            'Bed Booking\n${viewModel.selectedBedType!.type}',
                            'Bed booking for ${viewModel.selectedBedType!.type}',
                          );
                        } else {
                          _handleBookingConfirmation(context);
                        }
                      },
                child: Text(
                  _isBookingPending
                      ? "Processing..."
                      : _bookingStatus == 'accepted'
                          ? "Make Payment"
                          : "Confirm Booking",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
