import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/doctor_dashboard_screen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreLocationPicker.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class DoctorClinicRegistrationScreen extends StatefulWidget {
  const DoctorClinicRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorClinicRegistrationScreen> createState() => _DoctorClinicRegistrationScreenState();
}

class _DoctorClinicRegistrationScreenState extends State<DoctorClinicRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _consultationFeesRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _doctorNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _floorController.dispose();
    _pincodeController.dispose();
    _consultationFeesRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DoctorClinicRegistrationViewModel(),
      child: Scaffold(
        backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Doctor Clinic Registration'),
          elevation: 0,
          backgroundColor: DoctorConsultationColorPalette.primaryBlue,
          foregroundColor: DoctorConsultationColorPalette.textWhite,
        ),
        body: Consumer<DoctorClinicRegistrationViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildCurrentStep(viewModel),
                      ),
                    ),
                  ),
                ),
                _buildNavigationButtons(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? DoctorConsultationColorPalette.progressActive
                        : DoctorConsultationColorPalette.progressInactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Personal', 0),
              _buildStepLabel('Education', 1),
              _buildStepLabel('Consultation', 2),
              _buildStepLabel('Location', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? DoctorConsultationColorPalette.primaryBlue
                : isCompleted
                    ? DoctorConsultationColorPalette.successGreen
                    : DoctorConsultationColorPalette.progressInactive,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? DoctorConsultationColorPalette.primaryBlue
                : DoctorConsultationColorPalette.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(DoctorClinicRegistrationViewModel viewModel) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetailsStep(viewModel);
      case 1:
        return _buildEducationStep(viewModel);
      case 2:
        return _buildConsultationStep(viewModel);
      case 3:
        return _buildLocationStep(viewModel);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavigationButtons(DoctorClinicRegistrationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.isLoading ? null : () {
                  setState(() {
                    _currentStep--;
                    _animationController.reset();
                    _animationController.forward();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                  foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : () {
                if (_currentStep < 3) {
                  if (!_validateCurrentStep(viewModel)) {
                    return;
                  }
                  setState(() {
                    _currentStep++;
                    _animationController.reset();
                    _animationController.forward();
                  });
                } else {
                  _submitForm(viewModel);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: viewModel.isLoading 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Submitting...'),
                    ],
                  )
                : Text(_currentStep == 3 ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep(DoctorClinicRegistrationViewModel viewModel) {
    List<String> errors = [];
    
    switch (_currentStep) {
      case 0:
        if (_doctorNameController.text.isEmpty) {
          errors.add('Full Name is required');
        }
        if (_emailController.text.isEmpty) {
          errors.add('Email is required');
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
          errors.add('Please enter a valid email');
        }
        if (_passwordController.text.isEmpty) {
          errors.add('Password is required');
        } else if (_passwordController.text.length < 6) {
          errors.add('Password must be at least 6 characters');
        }
        if (_confirmPasswordController.text != _passwordController.text) {
          errors.add('Passwords do not match');
        }
        if (_phoneController.text.isEmpty) {
          errors.add('Contact Number is required');
        }
        if (_licenseNumberController.text.isEmpty) {
          errors.add('License Number is required');
        }
        if (viewModel.profilePictureFile == null) {
          errors.add('Profile Picture is required');
        }
        if (viewModel.medicalLicenseFile == null) {
          errors.add('Medical License is required');
        }
        break;
        
      case 1:
        if (viewModel.profile.educationalQualifications.isEmpty) {
          errors.add('At least one Educational Qualification is required');
        }
        if (viewModel.profile.specializations.isEmpty) {
          errors.add('At least one Specialization is required');
        }
        if (_experienceController.text.isEmpty || int.tryParse(_experienceController.text) == 0) {
          errors.add('Years of Experience is required');
        }
        break;
        
      case 2:
        if (!viewModel.validateProfile()) {
          if (viewModel.validationErrors['consultationFeesRange'] != null) {
            errors.add(viewModel.validationErrors['consultationFeesRange']!);
          }
          if (viewModel.validationErrors['consultationTypes'] != null) {
            errors.add(viewModel.validationErrors['consultationTypes']!);
          }
          if (viewModel.validationErrors['consultationDays'] != null) {
            errors.add(viewModel.validationErrors['consultationDays']!);
          }
          if (viewModel.validationErrors['consultationTimeSlots'] != null) {
            errors.add(viewModel.validationErrors['consultationTimeSlots']!);
          }
        }
        break;
        
      case 3:
        if (_addressController.text.isEmpty) {
          errors.add('Address is required');
        }
        if (viewModel.profile.state.isEmpty) {
          errors.add('State is required');
        }
        if (viewModel.profile.city.isEmpty) {
          errors.add('City is required');
        }
        if (_pincodeController.text.isEmpty) {
          errors.add('Pincode is required');
        } else if (_pincodeController.text.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(_pincodeController.text)) {
          errors.add('Please enter a valid 6-digit pincode');
        }
        if (_landmarkController.text.isEmpty) {
          errors.add('Nearby Landmark is required');
        }
        if (_floorController.text.isEmpty) {
          errors.add('Floor is required');
        }
        if (viewModel.profile.location.isEmpty) {
          errors.add('Location is required');
        }
        break;
    }
    
    if (errors.isNotEmpty) {
      _showValidationErrorsSnackbar(errors);
      return false;
    }
    
    return true;
  }

  void _showValidationErrorsSnackbar(List<String> errors) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final errorsText = errors.map((e) => '• $e').join('\n');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please fix the following errors:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorsText,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: DoctorConsultationColorPalette.errorRed,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep(DoctorClinicRegistrationViewModel viewModel) {
    if (_emailController.text.isEmpty && viewModel.profile.email.isNotEmpty) {
      _emailController.text = viewModel.profile.email;
    }
    if (_passwordController.text.isEmpty && viewModel.profile.password.isNotEmpty) {
      _passwordController.text = viewModel.profile.password;
    }
    if (_confirmPasswordController.text.isEmpty && viewModel.profile.confirmPassword.isNotEmpty) {
      _confirmPasswordController.text = viewModel.profile.confirmPassword;
    }
    if (_phoneController.text.isEmpty && viewModel.profile.phoneNumber.isNotEmpty) {
      _phoneController.text = viewModel.profile.phoneNumber;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Full Name',
          controller: _doctorNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
          prefixIcon: Icons.person,
          onChanged: (value) => viewModel.setDoctorName(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => viewModel.setEmail(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Password',
          controller: _passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          prefixIcon: Icons.lock,
          obscureText: true,
          onChanged: (value) => viewModel.setPassword(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          prefixIcon: Icons.lock,
          obscureText: true,
          onChanged: (value) => viewModel.setConfirmPassword(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Contact Number',
          controller: _phoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Contact number';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) => viewModel.setPhoneNumber(value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Gender',
          value: viewModel.profile.gender,
          items: ['Male', 'Female', 'Other'],
          prefixIcon: Icons.person_outline,
          onChanged: (value) {
            if (value != null) {
              viewModel.setGender(value);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'License Number',
          controller: _licenseNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter license number';
            }
            return null;
          },
          prefixIcon: Icons.badge,
          onChanged: (value) => viewModel.setLicenseNumber(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Years of Experience',
          controller: _experienceController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter years of experience';
            }
            return null;
          },
          prefixIcon: Icons.work,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final years = int.tryParse(value) ?? 0;
            viewModel.setExperienceYears(years);
          },
        ),
        const SizedBox(height: 16),
        UploadSectionWidget(
          label: 'Profile Picture',
          onFilesSelected: (files) {
            if (files.isNotEmpty) {
              final file = files.first;
              viewModel.setProfilePicture(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.profilePictureFile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DoctorConsultationColorPalette.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DoctorConsultationColorPalette.successGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${viewModel.profilePictureName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        UploadSectionWidget(
          label: 'Medical License',
          onFilesSelected: (files) {
            if (files.isNotEmpty) {
              final file = files.first;
              viewModel.setMedicalLicenseFile(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.medicalLicenseFile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DoctorConsultationColorPalette.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DoctorConsultationColorPalette.successGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${viewModel.medicalLicenseName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEducationStep(DoctorClinicRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Years of Experience',
          controller: _experienceController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter years of experience';
            }
            return null;
          },
          prefixIcon: Icons.work_history,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final years = int.tryParse(value) ?? 0;
            viewModel.setExperienceYears(years);
          },
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Educational Qualifications',
          items: ['MBBS', 'MD', 'MS', 'DM', 'MCh'],
          selectedItems: viewModel.profile.educationalQualifications,
          onChanged: (items) => viewModel.setEducationalQualifications(items),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Specializations',
          items: ['Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics', 'Dermatology'],
          selectedItems: viewModel.profile.specializations,
          onChanged: (items) => viewModel.setSpecializations(items),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Languages',
          items: ['English', 'Hindi', 'Marathi', 'Gujarati', 'Bengali'],
          selectedItems: viewModel.profile.languageProficiency,
          onChanged: (items) => viewModel.setLanguageProficiency(items),
        ),
      ],
    );
  }

  Widget _buildConsultationStep(DoctorClinicRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: const Text('Telemedicine Experience'),
          subtitle: const Text('Do you have experience with online consultations?'),
          value: viewModel.profile.hasTelemedicineExperience,
          onChanged: (value) => viewModel.setHasTelemedicineExperience(value),
          tileColor: DoctorConsultationColorPalette.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: DoctorConsultationColorPalette.borderLight),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Consultation Fees Range',
          controller: _consultationFeesRangeController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter consultation fees range';
            }
            return null;
          },
          prefixIcon: Icons.attach_money,
          onChanged: (value) => viewModel.setConsultationFeesRange(value),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Consultation Types',
          items: ['Online', 'Offline', 'Chat'],
          selectedItems: viewModel.profile.consultationTypes,
          onChanged: (items) => viewModel.setConsultationTypes(items),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Consultation Days',
          items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
          selectedItems: viewModel.profile.consultationDays,
          onChanged: (items) => viewModel.setConsultationDays(items),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: viewModel.timeSlots.isEmpty 
                ? DoctorConsultationColorPalette.errorRed.withOpacity(0.1)
                : DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: viewModel.timeSlots.isEmpty 
                  ? DoctorConsultationColorPalette.errorRed
                  : DoctorConsultationColorPalette.successGreen,
            ),
          ),
          child: Row(
            children: [
              Icon(
                viewModel.timeSlots.isEmpty ? Icons.warning_amber_rounded : Icons.check_circle,
                color: viewModel.timeSlots.isEmpty 
                    ? DoctorConsultationColorPalette.errorRed
                    : DoctorConsultationColorPalette.successGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  viewModel.timeSlots.isEmpty
                      ? 'Please add at least one time slot to continue!'
                      : 'Great! You have added ${viewModel.timeSlots.length} time slot(s).',
                  style: TextStyle(
                    color: viewModel.timeSlots.isEmpty 
                        ? DoctorConsultationColorPalette.errorRed
                        : DoctorConsultationColorPalette.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TimeSlotPicker(
          timeSlots: viewModel.timeSlots,
          onAddSlot: (startTime, endTime) => viewModel.addTimeSlot(startTime, endTime),
          onRemoveSlot: (index) => viewModel.removeTimeSlot(index),
        ),
      ],
    );
  }

  Widget _buildLocationStep(DoctorClinicRegistrationViewModel viewModel) {
    if (_pincodeController.text.isEmpty && viewModel.profile.pincode.isNotEmpty) {
      _pincodeController.text = viewModel.profile.pincode;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinic Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Address',
          controller: _addressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
          prefixIcon: Icons.location_on,
          maxLines: 3,
          onChanged: (value) => viewModel.setAddress(value),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'State',
          value: viewModel.profile.state.isEmpty ? 'Maharashtra' : viewModel.profile.state,
          items: viewModel.states.map((state) => state.name).toList(),
          prefixIcon: Icons.map,
          onChanged: (value) {
            if (value != null) {
              viewModel.setState(value);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'City',
          value: viewModel.profile.city.isEmpty && viewModel.availableCities.isNotEmpty 
              ? viewModel.availableCities.first 
              : viewModel.profile.city,
          items: viewModel.availableCities,
          prefixIcon: Icons.location_city,
          onChanged: (value) {
            if (value != null) {
              viewModel.setCity(value);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Pincode',
          controller: _pincodeController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter pincode';
            }
            if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Please enter a valid 6-digit pincode';
            }
            return null;
          },
          prefixIcon: Icons.pin_drop,
          keyboardType: TextInputType.number,
          onChanged: (value) => viewModel.setPincode(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nearby Landmark',
          controller: _landmarkController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter nearby landmark';
            }
            return null;
          },
          prefixIcon: Icons.place,
          onChanged: (value) => viewModel.setNearbyLandmark(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Floor',
          controller: _floorController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter floor number';
            }
            return null;
          },
          prefixIcon: Icons.home,
          onChanged: (value) => viewModel.setFloor(value),
        ),
        const SizedBox(height: 16),
        MedicalStoreLocationPicker(
          onLocationSelected: (location) => viewModel.setLocation(location),
        ),
        const SizedBox(height: 24),
        const Text(
          'Facilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.backgroundCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DoctorConsultationColorPalette.borderLight),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Lift Access'),
                value: viewModel.profile.hasLiftAccess,
                onChanged: (value) => viewModel.setHasLiftAccess(value),
                contentPadding: EdgeInsets.zero,
                activeColor: DoctorConsultationColorPalette.primaryBlue,
              ),
              SwitchListTile(
                title: const Text('Wheelchair Access'),
                value: viewModel.profile.hasWheelchairAccess,
                onChanged: (value) => viewModel.setHasWheelchairAccess(value),
                contentPadding: EdgeInsets.zero,
                activeColor: DoctorConsultationColorPalette.primaryBlue,
              ),
              SwitchListTile(
                title: const Text('Parking Available'),
                value: viewModel.profile.hasParking,
                onChanged: (value) => viewModel.setHasParking(value),
                contentPadding: EdgeInsets.zero,
                activeColor: DoctorConsultationColorPalette.primaryBlue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Other Facilities',
          items: ['WiFi', 'AC', 'Pharmacy', 'Lab', 'Cafeteria'],
          selectedItems: viewModel.profile.otherFacilities,
          onChanged: (items) => viewModel.setOtherFacilities(items),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Insurance Partners',
          items: ['ICICI Lombard', 'HDFC Ergo', 'Bajaj Allianz', 'Star Health'],
          selectedItems: viewModel.profile.insurancePartners,
          onChanged: (items) => viewModel.setInsurancePartners(items),
        ),
        const SizedBox(height: 16),
        UploadSectionWidget(
          label: 'Clinic Photos',
          onFilesSelected: (files) {
            for (var file in files) {
              viewModel.addClinicPhotoFile(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.clinicPhotoFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DoctorConsultationColorPalette.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Clinic Photos (${viewModel.clinicPhotoFiles.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: viewModel.clinicPhotoFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photoData = entry.value;
                    final String fileName = photoData['name'] as String;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.secondaryTealLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo,
                            size: 16,
                            color: DoctorConsultationColorPalette.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              fileName.length > 20 ? '${fileName.substring(0, 17)}...' : fileName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => viewModel.removeClinicPhotoFile(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: DoctorConsultationColorPalette.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLines = 1,
    Function(String)? onChanged,
  }) {
    final String? errorMessage = 
        controller == _emailController || 
        controller == _passwordController || 
        controller == _confirmPasswordController || 
        controller == _phoneController ||
        controller == _pincodeController
            ? null 
            : context.watch<DoctorClinicRegistrationViewModel>().validationErrors[label.toLowerCase().replaceAll(' ', '')];
    
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: DoctorConsultationColorPalette.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: errorMessage != null 
              ? DoctorConsultationColorPalette.errorRed 
              : DoctorConsultationColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: errorMessage != null 
              ? DoctorConsultationColorPalette.errorRed 
              : DoctorConsultationColorPalette.primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: DoctorConsultationColorPalette.backgroundPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorMessage != null 
                ? DoctorConsultationColorPalette.errorRed 
                : DoctorConsultationColorPalette.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorMessage != null 
                ? DoctorConsultationColorPalette.errorRed 
                : DoctorConsultationColorPalette.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: errorMessage != null 
                ? DoctorConsultationColorPalette.errorRed 
                : DoctorConsultationColorPalette.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.errorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.errorRed,
            width: 2,
          ),
        ),
        errorText: errorMessage,
        errorStyle: TextStyle(
          color: DoctorConsultationColorPalette.errorRed,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData prefixIcon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(
        color: DoctorConsultationColorPalette.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: DoctorConsultationColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: DoctorConsultationColorPalette.primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: DoctorConsultationColorPalette.backgroundPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.primaryBlue,
            width: 2,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: DoctorConsultationColorPalette.primaryBlue,
      ),
    );
  }

  void _submitForm(DoctorClinicRegistrationViewModel viewModel) async {
    // Validate the current step before submitting
    if (!_validateCurrentStep(viewModel)) {
      return;
    }
    
    try {
      final success = await viewModel.submitProfile();
      
      if (success) {
        _showSuccessDialog();
      } else if (viewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error!),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: DoctorConsultationColorPalette.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.check_circle,
                          color: DoctorConsultationColorPalette.successGreen,
                          size: 70,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      'Registration Successful!',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              
              // Message with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      'Your doctor profile has been successfully registered. You can now manage your clinic through the dashboard.',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              
              // Action button with animation
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Go to Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiSelectField extends StatelessWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const MultiSelectField({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                final newItems = List<String>.from(selectedItems);
                if (selected) {
                  newItems.add(item);
                } else {
                  newItems.remove(item);
                }
                onChanged(newItems);
              },
              backgroundColor: DoctorConsultationColorPalette.backgroundCard,
              selectedColor: DoctorConsultationColorPalette.secondaryTealLight,
              checkmarkColor: DoctorConsultationColorPalette.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected 
                    ? DoctorConsultationColorPalette.textPrimary 
                    : DoctorConsultationColorPalette.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected 
                      ? DoctorConsultationColorPalette.primaryBlue 
                      : DoctorConsultationColorPalette.borderLight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class TimeSlotPicker extends StatelessWidget {
  final List<Map<String, String>> timeSlots;
  final Function(String, String) onAddSlot;
  final Function(int) onRemoveSlot;

  const TimeSlotPicker({
    Key? key,
    required this.timeSlots,
    required this.onAddSlot,
    required this.onRemoveSlot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("🕒 TimeSlotPicker build: ${timeSlots.length} slots available");
    
    return Container(
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DoctorConsultationColorPalette.borderLight),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your available time slots',
                    style: TextStyle(
                      fontSize: 12,
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showTimePickerDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Slot'),
              ),
            ],
          ),
          if (timeSlots.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 48,
                    color: DoctorConsultationColorPalette.borderMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No time slots added yet',
                    style: TextStyle(
                      color: DoctorConsultationColorPalette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showTimePickerDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorConsultationColorPalette.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle, size: 20),
                    label: const Text('Add Your First Time Slot'),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: timeSlots.asMap().entries.map((entry) {
                final index = entry.key;
                final slot = entry.value;
                return TimeSlotChip(
                  startTime: slot['start'] ?? '',
                  endTime: slot['end'] ?? '',
                  onRemove: () {
                    print("🕒 Removing time slot at index $index");
                    onRemoveSlot(index);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context) async {
    print("🕒 Opening time picker dialog");
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DoctorConsultationColorPalette.primaryBlue,
              onPrimary: Colors.white,
              onSurface: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (startTime != null) {
      print("🕒 Start time selected: ${_formatTimeOfDay(startTime)}");
      // Calculate a default end time 1 hour after start time
      final defaultEndTime = TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      );
      
      final TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: defaultEndTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: DoctorConsultationColorPalette.primaryBlue,
                onPrimary: Colors.white,
                onSurface: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (endTime != null) {
        print("🕒 End time selected: ${_formatTimeOfDay(endTime)}");
        print("🕒 Adding time slot: ${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}");
        onAddSlot(
          _formatTimeOfDay(startTime),
          _formatTimeOfDay(endTime),
        );
        print("🕒 Time slot added, current time slots count: ${timeSlots.length}");
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class TimeSlotChip extends StatelessWidget {
  final String startTime;
  final String endTime;
  final VoidCallback onRemove;

  const TimeSlotChip({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.secondaryTealLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            '$startTime - $endTime',
            style: TextStyle(
              color: DoctorConsultationColorPalette.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.cancel,
                size: 18,
                color: DoctorConsultationColorPalette.errorRed.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 