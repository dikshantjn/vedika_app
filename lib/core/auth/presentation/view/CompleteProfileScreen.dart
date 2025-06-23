import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/ProfileCompletionService.dart';
import 'package:vedika_healthcare/core/auth/data/services/UserService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:lottie/lottie.dart';

class CompleteProfileScreen extends StatefulWidget {
  final ServiceType serviceType;
  final String userId;
  final Function() onComplete;

  const CompleteProfileScreen({
    Key? key,
    required this.serviceType,
    required this.userId,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedBloodGroup;
  bool _isLoading = false;
  late UserModel _user;
  late AnimationController _animationController;
  int _currentStep = 0;
  List<String> _requiredFields = [];

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserData();
  }

  void _updateRequiredFields() {
    _requiredFields = [];
    if (_shouldShowField('name')) _requiredFields.add('name');
    if (_shouldShowField('location')) _requiredFields.add('location');
    if (_shouldShowField('emergencyContactNumber')) _requiredFields.add('emergencyContactNumber');
    if (_shouldShowField('dateOfBirth')) _requiredFields.add('dateOfBirth');
    if (_shouldShowField('bloodGroup')) _requiredFields.add('bloodGroup');
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userService = UserService();
      final user = await userService.getUserById(widget.userId);
      if (user != null) {
        _user = user;
        _nameController.text = user.name ?? '';
        _addressController.text = user.location ?? '';
        _emergencyContactController.text = user.emergencyContactNumber ?? '';
        _selectedDate = user.dateOfBirth;
        _selectedBloodGroup = user.bloodGroup;
        _updateRequiredFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userService = UserService();
      
      // Create updated user model
      final updatedUser = UserModel(
        userId: _user.userId,
        name: _shouldShowField('name') ? _nameController.text : _user.name,
        location: _shouldShowField('location') ? _addressController.text : _user.location,
        emergencyContactNumber: _shouldShowField('emergencyContactNumber') 
            ? _emergencyContactController.text 
            : _user.emergencyContactNumber,
        dateOfBirth: _shouldShowField('dateOfBirth') ? _selectedDate : _user.dateOfBirth,
        bloodGroup: _shouldShowField('bloodGroup') ? _selectedBloodGroup : _user.bloodGroup,
        // Preserve other fields from existing user
        photo: _user.photo,
        phoneNumber: _user.phoneNumber,
        abhaId: _user.abhaId,
        emailId: _user.emailId,
        gender: _user.gender,
        height: _user.height,
        weight: _user.weight,
        city: _user.city,
        createdAt: _user.createdAt,
        password: _user.password,
        status: _user.status,
        platform: _user.platform,
      );

      final success = await userService.updateUserProfile(widget.userId, updatedUser);
      
      if (mounted && success) {
        widget.onComplete();
      }
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _shouldShowField(String fieldName) {
    switch (widget.serviceType) {
      case ServiceType.ambulance:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true)) ||
               (fieldName == 'emergencyContactNumber' && (_user.emergencyContactNumber?.isEmpty ?? true));
      
      case ServiceType.hospital:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true)) ||
               (fieldName == 'dateOfBirth' && _user.dateOfBirth == null) ||
               (fieldName == 'bloodGroup' && (_user.bloodGroup?.isEmpty ?? true)) ||
               (fieldName == 'emergencyContactNumber' && (_user.emergencyContactNumber?.isEmpty ?? true));
      
      case ServiceType.bloodBank:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true)) ||
               (fieldName == 'dateOfBirth' && _user.dateOfBirth == null) ||
               (fieldName == 'bloodGroup' && (_user.bloodGroup?.isEmpty ?? true));
      
      case ServiceType.labTest:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true)) ||
               (fieldName == 'dateOfBirth' && _user.dateOfBirth == null);
      
      case ServiceType.medicineDelivery:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true));
      
      case ServiceType.clinic:
        return (fieldName == 'name' && (_user.name?.isEmpty ?? true)) ||
               (fieldName == 'location' && (_user.location?.isEmpty ?? true)) ||
               (fieldName == 'dateOfBirth' && _user.dateOfBirth == null) ||
               (fieldName == 'bloodGroup' && (_user.bloodGroup?.isEmpty ?? true));
      
      default:
        return false;
    }
  }

  Step _buildStep(String title, Widget content) {
    return Step(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: content,
      ),
      isActive: _requiredFields.indexOf(title.toLowerCase()) <= _currentStep,
      state: _requiredFields.indexOf(title.toLowerCase()) < _currentStep 
          ? StepState.complete 
          : StepState.indexed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<Step> steps = [];
    
    if (_shouldShowField('name')) {
      steps.add(_buildStep(
        'Personal Info',
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ));
    }

    if (_shouldShowField('location')) {
      steps.add(_buildStep(
        'Location',
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
      ));
    }

    if (_shouldShowField('emergencyContactNumber')) {
      steps.add(_buildStep(
        'Emergency Contact',
        _buildTextField(
          controller: _emergencyContactController,
          label: 'Emergency Contact Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter emergency contact';
            }
            return null;
          },
        ),
      ));
    }

    if (_shouldShowField('dateOfBirth')) {
      steps.add(_buildStep(
        'Date of Birth',
        _buildDatePicker(),
      ));
    }

    if (_shouldShowField('bloodGroup')) {
      steps.add(_buildStep(
        'Blood Group',
        _buildBloodGroupDropdown(),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      color: ColorPalette.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'for ${widget.serviceType.toString().split('.').last} services',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              minHeight: 2,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ColorPalette.primaryColor,
                    ),
                  ),
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep < steps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        _saveProfile();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    onStepTapped: (index) {
                      setState(() => _currentStep = index);
                    },
                    steps: steps,
                    controlsBuilder: (context, controls) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controls.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorPalette.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 45),
                                ),
                                child: Text(
                                  _currentStep == steps.length - 1 ? 'Submit' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: controls.onStepCancel,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(color: ColorPalette.primaryColor),
                                    minimumSize: const Size(double.infinity, 45),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: ColorPalette.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: ColorPalette.primaryColor, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.primaryColor, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: ColorPalette.primaryColor, size: 22),
        title: Text(
          _selectedDate == null
              ? 'Select Date of Birth'
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          style: TextStyle(
            color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: ColorPalette.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != _selectedDate) {
            setState(() => _selectedDate = picked);
          }
        },
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBloodGroup,
        decoration: InputDecoration(
          labelText: 'Blood Group',
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.bloodtype, color: ColorPalette.primaryColor, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.primaryColor, width: 1),
          ),
        ),
        items: _bloodGroups.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() => _selectedBloodGroup = newValue);
        },
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        icon: Icon(Icons.arrow_drop_down, color: ColorPalette.primaryColor),
        dropdownColor: Colors.white,
        isExpanded: true,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _animationController.dispose();
    super.dispose();
  }
} 