import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DoctorSelection.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/ClinicInfoCard.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/PatientDetailsForm.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/TimeSlotSelection.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalBookingPaymentService.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BookClinicAppointmentPage extends StatelessWidget {
  final Clinic clinic;

  const BookClinicAppointmentPage({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookClinicAppointmentViewModel>(context);
    final List<Doctor> doctors = clinic.doctors;
    final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>(); // Form key for validation

    // final razorpayService = RazorpayService();

    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          "Book Clinic Appointment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: DoctorConsultationColorPalette.primaryBlue,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicInfoCard(clinic: clinic),
            SizedBox(height: 20),

            // Doctor Selection
            DoctorSelection(
              doctors: doctors,
              selectedDoctor: viewModel.selectedDoctor,
              onDoctorSelected: (doctor) => viewModel.selectDoctor(doctor),
            ),
            SizedBox(height: 20),

            Text(
              "Select Date",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            DatePickerWidget(
              selectedDate: viewModel.selectedDate,
              onDatePicked: viewModel.selectDate,
            ),
            SizedBox(height: 20),

            if (viewModel.selectedDoctor != null)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: TimeSlotSelection(
                  timeSlots: viewModel.selectedDoctor!.timeSlots,
                  selectedTimeSlot: viewModel.selectedTimeSlot,
                  onTimeSlotSelected: viewModel.selectTimeSlot,
                ),
              ),

            Text(
              "Patient Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            SizedBox(height: 10),

            // Patient Type Selection (Self / Other)
            Container(
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
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
                          color: viewModel.selectedPatientType == "Self"
                              ? DoctorConsultationColorPalette.primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Self",
                              style: TextStyle(
                                fontSize: 16,
                                color: viewModel.selectedPatientType == "Self"
                                    ? Colors.white
                                    : DoctorConsultationColorPalette.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showInfoPopup(context),
                              child: Icon(
                                Icons.info_outline,
                                color: viewModel.selectedPatientType == "Self"
                                    ? Colors.white
                                    : DoctorConsultationColorPalette.primaryBlue,
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
                          color: viewModel.selectedPatientType == "Other"
                              ? DoctorConsultationColorPalette.primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Other",
                            style: TextStyle(
                              fontSize: 16,
                              color: viewModel.selectedPatientType == "Other"
                                  ? Colors.white
                                  : DoctorConsultationColorPalette.primaryBlue,
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

            if (viewModel.selectedDoctor != null) ...[
              Text(
                "Consultation Fee",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "₹${viewModel.selectedDoctor!.fee}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.successGreen,
                ),
              ),
              SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (viewModel.selectedPatientType == "Other" && !_patientFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please complete the patient details form"),
                        backgroundColor: DoctorConsultationColorPalette.errorRed,
                      ),
                    );
                    return;
                  }

                  if (!viewModel.isFormComplete()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please complete all fields"),
                        backgroundColor: DoctorConsultationColorPalette.errorRed,
                      ),
                    );
                  } else {
                    // razorpayService.openPaymentGateway(
                    //   viewModel.selectedDoctor!.fee,
                    //   ApiConstants.razorpayApiKey,
                    //   'Appointment Fee\nConsultation appointment at ${clinic.name} with ${viewModel.selectedDoctor!.name}',
                    //   'Consultation appointment at ${clinic.name} with ${viewModel.selectedDoctor!.name}',
                    // );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Appointment Confirmed!"),
                        backgroundColor: DoctorConsultationColorPalette.successGreen,
                      ),
                    );
                  }
                },
                child: Text(
                  "Confirm Appointment",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              Icon(
                Icons.info_outline,
                color: DoctorConsultationColorPalette.primaryBlue,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "Information Shared with Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(color: DoctorConsultationColorPalette.borderLight),
              SizedBox(height: 10),
              _buildInfoItem("Full Name"),
              _buildInfoItem("Age & Gender"),
              _buildInfoItem("Phone Number"),
              _buildInfoItem("Address"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "Got It",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for popup items
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: DoctorConsultationColorPalette.primaryBlue,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
