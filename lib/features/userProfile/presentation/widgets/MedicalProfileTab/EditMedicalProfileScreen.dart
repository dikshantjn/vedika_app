import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/MedicalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';

class EditMedicalProfileScreen extends StatefulWidget {
  final UserMedicalProfileViewModel viewModel;

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
  bool _isDiabetic = false; // Local state for the checkbox
  double eyePower = 0.0;
  bool _isInitialized = false; // Flag to track initialization

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty text
    allergiesController = TextEditingController();
    currentMedController = TextEditingController();
    pastMedController = TextEditingController();
    chronicController = TextEditingController();
    injuriesController = TextEditingController();
    surgeriesController = TextEditingController();

    // Fetch medical profile asynchronously after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchMedicalProfile();
    });
  }

  void _saveProfile() async {
    final profile = widget.viewModel.medicalProfile;
    String? userId = await StorageService.getUserId();

    final updatedProfile = MedicalProfile(
      medicalProfileId: profile?.medicalProfileId ?? '',
      userId: profile?.userId ?? userId!,
      isDiabetic: _isDiabetic, // Use the local state
      allergies: allergiesController.text.isNotEmpty
          ? allergiesController.text.split(', ')
          : [],
      eyePower: eyePower,
      currentMedication: currentMedController.text.isNotEmpty
          ? currentMedController.text.split(', ')
          : [],
      pastMedication: pastMedController.text.isNotEmpty
          ? pastMedController.text.split(', ')
          : [],
      chronicConditions: chronicController.text.isNotEmpty
          ? chronicController.text.split(', ')
          : [],
      injuries: injuriesController.text.isNotEmpty
          ? injuriesController.text.split(', ')
          : [],
      surgeries: surgeriesController.text.isNotEmpty
          ? surgeriesController.text.split(', ')
          : [],
    );

    bool isUpdated = false;
    try {
      if (profile?.userId != null && profile!.userId.isNotEmpty) {
        await widget.viewModel.updateMedicalProfile(updatedProfile);
        isUpdated = true;
      } else {
        await widget.viewModel.createMedicalProfile(updatedProfile);
        isUpdated = true;
      }

      // Show a floating SnackBar with a close button
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isUpdated ? 'Profile Updated' : 'Profile Saved'),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // Close the SnackBar immediately
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,  // Make it floating
          margin: EdgeInsets.all(20),  // Optional: add margin to the floating SnackBar
        ),
      );



      // Navigate back to the previous screen with a result
      Navigator.pop(context, true); // Pass `true` to indicate success
    } catch (e) {
      // Show an error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Medical Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          final profile = widget.viewModel.medicalProfile;

          // Initialize local state only once
          if (profile != null && !_isInitialized) {
            allergiesController.text = profile.allergies.join(', ');
            currentMedController.text = profile.currentMedication.join(', ');
            pastMedController.text = profile.pastMedication.join(', ');
            chronicController.text = profile.chronicConditions.join(', ');
            injuriesController.text = profile.injuries.join(', ');
            surgeriesController.text = profile.surgeries.join(', ');
            _isDiabetic = profile.isDiabetic; // Initialize local state
            eyePower = profile.eyePower;
            _isInitialized = true; // Mark as initialized
          }

          // Debugging: Print the current value of _isDiabetic
          print('Current _isDiabetic value: $_isDiabetic');

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: widget.viewModel.isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        widget.viewModel.errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  _buildTextField(allergiesController, 'Allergies (comma-separated)'),
                  _buildTextField(currentMedController, 'Current Medication (comma-separated)'),
                  _buildTextField(pastMedController, 'Past Medication (comma-separated)'),
                  _buildTextField(chronicController, 'Chronic Conditions (comma-separated)'),
                  _buildTextField(injuriesController, 'Injuries (comma-separated)'),
                  _buildTextField(surgeriesController, 'Surgeries (comma-separated)'),
                  SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text(
                      'Diabetic',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    value: _isDiabetic,
                    onChanged: (bool? value) {
                      // Debugging: Print the new value
                      print('Checkbox value changed: $value');

                      // Update the local state
                      setState(() {
                        _isDiabetic = value ?? false;
                      });
                    },
                    activeColor: ColorPalette.primaryColor,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveProfile,
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
          );
        },
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
              offset: Offset(0, 3),
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