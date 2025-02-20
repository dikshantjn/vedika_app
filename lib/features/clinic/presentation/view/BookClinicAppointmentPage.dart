import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DoctorSelection.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/ClinicInfoCard.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/PatientDetailsForm.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/TimeSlotSelection.dart';
import 'package:vedika_healthcare/features/hospital/data/service/RazorpayService.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BookClinicAppointmentPage extends StatelessWidget {
  final Clinic clinic;

  const BookClinicAppointmentPage({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookClinicAppointmentViewModel>(context);
    final List<Doctor> doctors = clinic.doctors;

    // Initialize RazorpayClinicService
    final razorpayService = RazorpayService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Book Clinic Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Clinic Info Card
            ClinicInfoCard(clinic: clinic),
            SizedBox(height: 20),

            // Doctor Selection
            DoctorSelection(
              doctors: doctors,
              selectedDoctor: viewModel.selectedDoctor,
              onDoctorSelected: (doctor) => viewModel.selectDoctor(doctor),
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
            if (viewModel.selectedDoctor != null)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: TimeSlotSelection(
                  timeSlots: viewModel.selectedDoctor!.timeSlots,
                  selectedTimeSlot: viewModel.selectedTimeSlot,
                  onTimeSlotSelected: viewModel.selectTimeSlot,
                ),
              ),

            // Patient Details Selection
            Text("Patient Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: ["Self", "Other"].map((type) {
                return Expanded(
                  child: RadioListTile(
                    title: Text(type),
                    value: type,
                    groupValue: viewModel.selectedPatientType,
                    onChanged: (value) => viewModel.selectPatientType(value!),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10),

            // Show Patient Details Form if "Other" is selected
            if (viewModel.selectedPatientType == "Other") PatientDetailsForm(),

            // Fees Display
            if (viewModel.selectedDoctor != null) ...[
              Text("Consultation Fee", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("₹${viewModel.selectedDoctor!.fee}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 20),
            ],

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!viewModel.isFormComplete()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please complete all fields")));
                  } else {
                    // Trigger Razorpay payment gateway here
                    razorpayService.openPaymentGateway(
                        viewModel.selectedDoctor!.fee,
                        'rzp_test_uMMypIJ2X2bn1N', // Use your Razorpay Key
                        'Appointment Fee\nConsultation appointment at ${clinic.name} with ${viewModel.selectedDoctor!.name}',
                        'Consultation appointment at ${clinic.name} with ${viewModel.selectedDoctor!.name}'
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment Confirmed!")));
                  }
                },
                child: Text("Confirm Appointment", style: TextStyle(fontSize: 18, color: Colors.white)),
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
