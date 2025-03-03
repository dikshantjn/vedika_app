import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';  // Add this import for image picking
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Profile/data/models/PersonalProfile.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';

class EditPersonalProfileScreen extends StatefulWidget {
  final UserProfileViewModel viewModel;

  EditPersonalProfileScreen({required this.viewModel});

  @override
  _EditPersonalProfileScreenState createState() => _EditPersonalProfileScreenState();
}

class _EditPersonalProfileScreenState extends State<EditPersonalProfileScreen> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controllers for the fields
    final nameController = TextEditingController(text: widget.viewModel.personalProfile.name);
    final emailController = TextEditingController(text: widget.viewModel.personalProfile.email);
    final contactController = TextEditingController(text: widget.viewModel.personalProfile.contactNumber);
    final abhaIdController = TextEditingController(text: widget.viewModel.personalProfile.abhaId);
    final locationController = TextEditingController(text: widget.viewModel.personalProfile.location);
    final emergencyContactController = TextEditingController(text: widget.viewModel.personalProfile.emergencyContactNumber);
    final heightController = TextEditingController(text: widget.viewModel.personalProfile.height?.toString());
    final weightController = TextEditingController(text: widget.viewModel.personalProfile.weight?.toString());

    DateTime? dateOfBirth = widget.viewModel.personalProfile.dateOfBirth;
    String? gender = widget.viewModel.personalProfile.gender;
    String? bloodGroup = widget.viewModel.personalProfile.bloodGroup;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Make the whole screen scrollable
          child: Form(
            key: _formKey,  // Attach the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Upload Section
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]) : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Name and Contact Number Fields (Required)
                _buildTextField(nameController, 'Name', isRequired: true),
                _buildTextField(contactController, 'Contact Number', isRequired: true),

                _buildTextField(emailController, 'Email'),
                _buildTextField(abhaIdController, 'ABHA ID'),
                _buildTextField(locationController, 'Location'),
                _buildTextField(emergencyContactController, 'Emergency Contact Number'),

                // Row for Height and Weight
                Row(
                  children: [
                    Expanded(
                      child: _buildNumericTextField(heightController, 'Height'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildNumericTextField(weightController, 'Weight'),
                    ),
                  ],
                ),

                // Date of Birth Field
                _buildDateOfBirthField(context, dateOfBirth, (selectedDate) {
                  setState(() {
                    dateOfBirth = selectedDate;
                  });
                }),

                // Row for Gender and Blood Group
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(gender, 'Gender', ['Male', 'Female', 'Other'], (value) {
                        setState(() {
                          gender = value;
                        });
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(bloodGroup, 'Blood Group', ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'], (value) {
                        setState(() {
                          bloodGroup = value;
                        });
                      }),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Create the updated profile
                        final updatedProfile = PersonalProfile(
                          name: nameController.text,
                          photoUrl: _profileImage?.path ?? widget.viewModel.personalProfile.photoUrl, // If new image is picked, use it
                          contactNumber: contactController.text,
                          abhaId: abhaIdController.text,
                          email: emailController.text,
                          dateOfBirth: dateOfBirth ?? DateTime.now(), // Use current date if null
                          gender: gender ?? widget.viewModel.personalProfile.gender, // Use current gender if null
                          bloodGroup: bloodGroup ?? widget.viewModel.personalProfile.bloodGroup, // Use current blood group if null
                          height: double.tryParse(heightController.text) ?? 0.0, // Default to 0.0 if height is null or invalid
                          weight: double.tryParse(weightController.text) ?? 0.0, // Default to 0.0 if weight is null or invalid
                          emergencyContactNumber: emergencyContactController.text,
                          location: locationController.text,
                        );

                        // Update the profile using the view model
                        widget.viewModel.updatePersonalProfile(updatedProfile);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: ColorPalette.primaryColor, // Attractive color for button
                    ),
                    child: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build regular text fields
  Widget _buildTextField(TextEditingController controller, String labelText, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return '$labelText is required';
          }
          return null;
        }
            : null,
      ),
    );
  }

  // Function to build numeric text fields
  Widget _buildNumericTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  // Function to build dropdown fields
  Widget _buildDropdownField(String? selectedValue, String labelText, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  // Method to build the Date of Birth Field
  Widget _buildDateOfBirthField(BuildContext context, DateTime? dateOfBirth, Function(DateTime?) onDateChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: dateOfBirth ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (selectedDate != null) {
            onDateChanged(selectedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Date of Birth',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            dateOfBirth != null
                ? DateFormat('dd/MM/yyyy').format(dateOfBirth)
                : 'Select a Date',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
