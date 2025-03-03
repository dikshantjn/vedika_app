import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';
import 'package:vedika_healthcare/features/Profile/data/models/MedicalProfile.dart';

class EditMedicalProfileScreen extends StatefulWidget {
  final UserProfileViewModel viewModel;

  EditMedicalProfileScreen({required this.viewModel});

  @override
  _EditMedicalProfileScreenState createState() =>
      _EditMedicalProfileScreenState();
}

class _EditMedicalProfileScreenState extends State<EditMedicalProfileScreen> {
  late TextEditingController allergiesController;
  late TextEditingController currentMedController;
  late TextEditingController pastMedController;
  late TextEditingController chronicController;
  late TextEditingController injuriesController;
  late TextEditingController surgeriesController;

  @override
  void initState() {
    super.initState();
    allergiesController = TextEditingController(
        text: widget.viewModel.medicalProfile.allergies.join(', '));
    currentMedController = TextEditingController(
        text: widget.viewModel.medicalProfile.currentMedication.join(', '));
    pastMedController = TextEditingController(
        text: widget.viewModel.medicalProfile.pastMedication.join(', '));
    chronicController = TextEditingController(
        text: widget.viewModel.medicalProfile.chronicConditions.join(', '));
    injuriesController = TextEditingController(
        text: widget.viewModel.medicalProfile.injuries.join(', '));
    surgeriesController = TextEditingController(
        text: widget.viewModel.medicalProfile.surgeries.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Medical Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(allergiesController, 'Allergies (comma-separated)'),
              _buildTextField(currentMedController, 'Current Medication (comma-separated)'),
              _buildTextField(pastMedController, 'Past Medication (comma-separated)'),
              _buildTextField(chronicController, 'Chronic Conditions (comma-separated)'),
              _buildTextField(injuriesController, 'Injuries (comma-separated)'),
              _buildTextField(surgeriesController, 'Surgeries (comma-separated)'),
              SizedBox(height: 20),
              CheckboxListTile(
                title: Text('Diabetic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                value: widget.viewModel.medicalProfile.isDiabetic,
                onChanged: (bool? value) {
                  setState(() {
                    widget.viewModel.updateMedicalProfile(MedicalProfile(
                      medicalProfileId: widget.viewModel.medicalProfile.medicalProfileId,
                      userProfileId: widget.viewModel.medicalProfile.userProfileId,
                      isDiabetic: value ?? false,
                      allergies: widget.viewModel.medicalProfile.allergies,
                      eyePower: widget.viewModel.medicalProfile.eyePower,
                      currentMedication: widget.viewModel.medicalProfile.currentMedication,
                      pastMedication: widget.viewModel.medicalProfile.pastMedication,
                      chronicConditions: widget.viewModel.medicalProfile.chronicConditions,
                      injuries: widget.viewModel.medicalProfile.injuries,
                      surgeries: widget.viewModel.medicalProfile.surgeries,
                    ));
                  });
                },
                activeColor: ColorPalette.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  widget.viewModel.updateMedicalProfile(MedicalProfile(
                    medicalProfileId: widget.viewModel.medicalProfile.medicalProfileId,
                    userProfileId: widget.viewModel.medicalProfile.userProfileId,
                    isDiabetic: widget.viewModel.medicalProfile.isDiabetic,
                    allergies: allergiesController.text.split(', '),
                    eyePower: widget.viewModel.medicalProfile.eyePower,
                    currentMedication: currentMedController.text.split(', '),
                    pastMedication: pastMedController.text.split(', '),
                    chronicConditions: chronicController.text.split(', '),
                    injuries: injuriesController.text.split(', '),
                    surgeries: surgeriesController.text.split(', '),
                  ));
                  Navigator.of(context).pop();
                },
                child: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black, fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

