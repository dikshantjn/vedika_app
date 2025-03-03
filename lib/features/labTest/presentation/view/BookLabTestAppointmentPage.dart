import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/CollectionMethodWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/LabInfoWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/PrescriptionUploadWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/SubmitButtonWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/TestSelectionWidget.dart';
import 'package:vedika_healthcare/features/labTest/presentation/widgets/BookAppointmentWidgets/TimePickerWidget.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BookLabTestAppointmentPage extends StatelessWidget {
  final LabModel lab;

  const BookLabTestAppointmentPage({Key? key, required this.lab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LabTestAppointmentViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: ColorPalette.primaryColor,
        title: Text("Book Lab Appointment"),
      ),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: viewModel.formKey,  // Assigning formKey from ViewModel
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabInfoWidget(lab: lab),
                SizedBox(height: 20),
                TestSelectionWidget(lab: lab), // Ensure this contains validation
                SizedBox(height: 20),
                DatePickerWidget(), // Ensure this contains validation
                SizedBox(height: 20),
                TimePickerWidget(), // Ensure this contains validation
                SizedBox(height: 20),
                CollectionMethodWidget(), // Ensure this contains validation
                SizedBox(height: 20),
                PrescriptionUploadWidget(), // Ensure this contains validation
                SizedBox(height: 30),
                SubmitButtonWidget(viewModel: viewModel, lab: lab), // Updated Submit Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}

