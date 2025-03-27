import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/PersonalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';

class EditPersonalProfileScreen extends StatefulWidget {
  final UserPersonalProfileViewModel viewModel;

  EditPersonalProfileScreen({required this.viewModel});

  @override
  _EditPersonalProfileScreenState createState() => _EditPersonalProfileScreenState();
}

class _EditPersonalProfileScreenState extends State<EditPersonalProfileScreen> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController contactController;
  late TextEditingController abhaIdController;
  late TextEditingController locationController;
  late TextEditingController emergencyContactController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController dobController;

  String? gender;
  String? bloodGroup;
  DateTime? dateOfBirth;

  @override
  void initState() {
    super.initState();
    final profile = widget.viewModel.personalProfile;
    nameController = TextEditingController(text: profile?.name ?? '');
    emailController = TextEditingController(text: profile?.email ?? '');
    contactController = TextEditingController(text: profile?.phoneNumber ?? '');
    abhaIdController = TextEditingController(text: profile?.abhaId ?? '');
    locationController = TextEditingController(text: profile?.location ?? '');
    emergencyContactController =
        TextEditingController(text: profile?.emergencyContactNumber ?? '');
    heightController =
        TextEditingController(text: profile?.height?.toString() ?? '');
    weightController =
        TextEditingController(text: profile?.weight?.toString() ?? '');
    dateOfBirth = profile?.dateOfBirth;
    dobController = TextEditingController(
        text: dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(
            dateOfBirth!) : '');
    gender = profile?.gender;
    bloodGroup = profile?.bloodGroup;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Edit Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null ? FileImage(
                          _profileImage!) : null,
                      child: _profileImage == null
                          ? Icon(
                          Icons.camera_alt, size: 40, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(nameController, 'Name', isRequired: true),
                _buildTextField(
                    contactController, 'Contact Number', isRequired: true),
                _buildTextField(emailController, 'Email'),
                _buildTextField(abhaIdController, 'ABHA ID'),
                _buildTextField(locationController, 'Location'),
                _buildTextField(
                    emergencyContactController, 'Emergency Contact Number'),
                Row(
                  children: [
                    Expanded(child: _buildNumericTextField(
                        heightController, 'Height')),
                    SizedBox(width: 16),
                    Expanded(child: _buildNumericTextField(
                        weightController, 'Weight')),
                  ],
                ),
                _buildDateOfBirthField(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                          gender, 'Gender', ['Male', 'Female', 'Other'], (
                          value) {
                        setState(() => gender = value);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(bloodGroup, 'Blood Group',
                          ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'], (
                              value) {
                            setState(() => bloodGroup = value);
                          }),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        PersonalProfile updatedProfile = PersonalProfile(
                          name: nameController.text,
                          photoUrl: _profileImage?.path ??
                              widget.viewModel.personalProfile!.photoUrl,
                          phoneNumber: contactController.text,
                          abhaId: abhaIdController.text,
                          email: emailController.text,
                          dateOfBirth: dateOfBirth ?? DateTime.now(),
                          gender: gender!,
                          bloodGroup: bloodGroup!,
                          height: double.tryParse(heightController.text) ?? 0.0,
                          weight: double.tryParse(weightController.text) ?? 0.0,
                          emergencyContactNumber: emergencyContactController.text,
                          location: locationController.text,
                        );

                        // Edit profile
                        widget.viewModel.editUserProfile(updatedProfile);

                        // Show a floating SnackBar after saving or updating the profile
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Profile ${widget.viewModel.isProfileUpdated ? 'Updated' : 'Saved'}'),
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
                        }


                        // Navigate back after saving the profile
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: ColorPalette.primaryColor,
                    ),
                    child: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isRequired = false}) {
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
        validator: isRequired ? (value) =>
        value == null || value.isEmpty
            ? '$labelText is required'
            : null : null,
      ),
    );
  }

  Widget _buildNumericTextField(TextEditingController controller,
      String labelText) {
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

  Widget _buildDropdownField(String? selectedValue, String labelText,
      List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue?.isNotEmpty == true ? selectedValue : null, // Null check
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: options.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: dobController,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(),
          ),
        ),
        readOnly: true, // To prevent manual editing
        onTap: () => _selectDate(),
        validator: (value) =>
        value == null || value.isEmpty ? 'Date of Birth is required' : null,
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dateOfBirth = pickedDate; // Update the dateOfBirth variable
        dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate); // Update the controller text
      });
    }
  }
}