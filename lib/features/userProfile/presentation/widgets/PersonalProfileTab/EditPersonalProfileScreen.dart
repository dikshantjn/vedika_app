import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/PersonalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:provider/provider.dart';

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
    emergencyContactController = TextEditingController(text: profile?.emergencyContactNumber ?? '');
    heightController = TextEditingController(text: profile?.height?.toString() ?? '');
    weightController = TextEditingController(text: profile?.weight?.toString() ?? '');
    dateOfBirth = profile?.dateOfBirth;
    dobController = TextEditingController(
        text: dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(dateOfBirth!) : '');
    gender = profile?.gender;
    bloodGroup = profile?.bloodGroup;
  }

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserPersonalProfileViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        ColorPalette.primaryColor,
                                        ColorPalette.primaryColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _profileImage != null
                                        ? Image.file(
                                            _profileImage!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : widget.viewModel.personalProfile?.photoUrl.isNotEmpty == true
                                            ? Image.network(
                                                widget.viewModel.personalProfile!.photoUrl,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.white,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: ColorPalette.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to change profile picture',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Personal Information'),
                            const SizedBox(height: 16),
                            _buildTextField(nameController, 'Full Name', Icons.person_outline, isRequired: true),
                            _buildTextField(contactController, 'Phone Number', Icons.phone_outlined, isRequired: true),
                            _buildTextField(emailController, 'Email Address', Icons.email_outlined),
                            _buildTextField(abhaIdController, 'ABHA ID', Icons.badge_outlined),
                            _buildTextField(locationController, 'Location', Icons.location_on_outlined),
                            
                            const SizedBox(height: 24),
                            _buildSectionTitle('Health Information'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(heightController, 'Height (cm)', Icons.height_outlined, keyboardType: TextInputType.number),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(weightController, 'Weight (kg)', Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    gender,
                                    'Gender',
                                    ['Male', 'Female', 'Other'],
                                    Icons.person_outline,
                                    (value) {
                                      setState(() => gender = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    bloodGroup,
                                    'Blood Group',
                                    ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'],
                                    Icons.bloodtype_outlined,
                                    (value) {
                                      setState(() => bloodGroup = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            _buildDateOfBirthField(),
                            
                            const SizedBox(height: 24),
                            _buildSectionTitle('Emergency Contact'),
                            const SizedBox(height: 16),
                            _buildTextField(emergencyContactController, 'Emergency Contact Number', Icons.emergency_outlined),
                            
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: viewModel.isUploading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          PersonalProfile updatedProfile = PersonalProfile(
                                            name: nameController.text,
                                            photoUrl: widget.viewModel.personalProfile?.photoUrl ?? '',
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

                                          bool success = await widget.viewModel.editUserProfile(
                                            updatedProfile,
                                            profileImage: _profileImage,
                                          );

                                          if (mounted) {
                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.check_circle_outline, color: Colors.white),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Profile ${widget.viewModel.isProfileUpdated ? 'Updated' : 'Saved'} Successfully',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.all(20),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.error_outline, color: Colors.white),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Failed to update profile. Please try again.',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.all(20),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPalette.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: viewModel.isUploading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Updating...',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.isUploading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: ColorPalette.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ColorPalette.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? '$labelText is required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String? value,
    String labelText,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: ColorPalette.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ColorPalette.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down, color: ColorPalette.primaryColor),
        dropdownColor: Colors.white,
        isExpanded: true,
        validator: (value) => value == null ? '$labelText is required' : null,
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: dateOfBirth ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: ColorPalette.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              dateOfBirth = picked;
              dobController.text = DateFormat('dd/MM/yyyy').format(picked);
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today_outlined, color: ColorPalette.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ColorPalette.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        validator: (value) => value == null || value.isEmpty ? 'Date of Birth is required' : null,
      ),
    );
  }
}