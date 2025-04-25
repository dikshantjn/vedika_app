import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/LabTestRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreLocationPicker.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class LabTestRegistrationScreen extends StatefulWidget {
  const LabTestRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LabTestRegistrationScreen> createState() => _LabTestRegistrationScreenState();
}

class _LabTestRegistrationScreenState extends State<LabTestRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _mainContactController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _businessTimingsController = TextEditingController();
  final TextEditingController _homeCollectionGeoLimitController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

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
    _centerNameController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mainContactController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _floorController.dispose();
    _businessTimingsController.dispose();
    _homeCollectionGeoLimitController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LabTestRegistrationViewModel(),
      child: Scaffold(
        backgroundColor: LabTestColorPalette.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Lab Test Center Registration'),
          elevation: 0,
          backgroundColor: LabTestColorPalette.primaryBlue,
          foregroundColor: LabTestColorPalette.textWhite,
        ),
        body: Consumer<LabTestRegistrationViewModel>(
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
        color: LabTestColorPalette.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
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
                        ? LabTestColorPalette.progressActive
                        : LabTestColorPalette.progressInactive,
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
              _buildStepLabel('Basic Info', 0),
              _buildStepLabel('Services', 1),
              _buildStepLabel('Location', 2),
              _buildStepLabel('Documents', 3),
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
                ? LabTestColorPalette.primaryBlue
                : isCompleted
                    ? LabTestColorPalette.successGreen
                    : LabTestColorPalette.progressInactive,
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
                ? LabTestColorPalette.primaryBlue
                : LabTestColorPalette.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(LabTestRegistrationViewModel viewModel) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep(viewModel);
      case 1:
        return _buildServicesStep(viewModel);
      case 2:
        return _buildLocationStep(viewModel);
      case 3:
        return _buildDocumentsStep(viewModel);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(LabTestRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Center Name',
          controller: _centerNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter center name';
            }
            return null;
          },
          prefixIcon: Icons.business,
          onChanged: (value) => viewModel.setCenterName(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'GST Number',
          controller: _gstNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter GST number';
            }
            return null;
          },
          prefixIcon: Icons.numbers,
          onChanged: (value) => viewModel.setGstNumber(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'PAN Number',
          controller: _panNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PAN number';
            }
            return null;
          },
          prefixIcon: Icons.numbers,
          onChanged: (value) => viewModel.setPanNumber(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Owner Name',
          controller: _ownerNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner name';
            }
            return null;
          },
          prefixIcon: Icons.person,
          onChanged: (value) => viewModel.setOwnerName(value),
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
          label: 'Main Contact Number',
          controller: _mainContactController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter main contact number';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) => viewModel.setMainContactNumber(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Emergency Contact Number',
          controller: _emergencyContactController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter emergency contact number';
            }
            return null;
          },
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) => viewModel.setEmergencyContactNumber(value),
        ),
      ],
    );
  }

  Widget _buildServicesStep(LabTestRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Facilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Business Timings',
          controller: _businessTimingsController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter business timings';
            }
            return null;
          },
          prefixIcon: Icons.access_time,
          onChanged: (value) => viewModel.setBusinessTimings(value),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Business Days',
          items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
          selectedItems: viewModel.profile.businessDays,
          onChanged: (items) => viewModel.setBusinessDays(items),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Sample Collection Method',
          value: viewModel.profile.sampleCollectionMethod,
          items: ['At Center', 'At Home', 'Both'],
          prefixIcon: Icons.science,
          onChanged: (value) {
            if (value != null) {
              viewModel.setSampleCollectionMethod(value);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Home Collection Geo Limit',
          controller: _homeCollectionGeoLimitController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter home collection geo limit';
            }
            return null;
          },
          prefixIcon: Icons.location_on,
          onChanged: (value) => viewModel.setHomeCollectionGeoLimit(value),
        ),
        const SizedBox(height: 16),
        MultiSelectField(
          title: 'Test Types',
          items: ['Blood Tests', 'Urine Tests', 'X-Ray', 'MRI', 'CT Scan', 'Ultrasound', 'ECG', 'Other'],
          selectedItems: viewModel.profile.testTypes,
          onChanged: (items) => viewModel.setTestTypes(items),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Emergency Handling Fast Track'),
          subtitle: const Text('Do you offer fast-track services for emergency cases?'),
          value: viewModel.profile.emergencyHandlingFastTrack,
          onChanged: (value) => viewModel.setEmergencyHandlingFastTrack(value),
          tileColor: LabTestColorPalette.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: LabTestColorPalette.borderLight),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep(LabTestRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Address',
          controller: _addressController,
          validator: (value) => viewModel.validationErrors['address'],
          prefixIcon: Icons.location_on,
          maxLines: 3,
          onChanged: viewModel.setAddress,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'State',
          value: viewModel.profile.state,
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
          value: viewModel.profile.city,
          items: viewModel.availableCities,
          prefixIcon: Icons.location_city,
          onChanged: (value) {
            if (value != null) {
              viewModel.setCity(value);
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pincodeController,
          decoration: InputDecoration(
            labelText: 'Pincode',
            hintText: 'Enter your 6-digit pincode',
            prefixIcon: Icon(
              Icons.pin_drop,
              color: LabTestColorPalette.primaryBlue,
              size: 20,
            ),
            filled: true,
            fillColor: LabTestColorPalette.backgroundPrimary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: LabTestColorPalette.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: LabTestColorPalette.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: LabTestColorPalette.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: LabTestColorPalette.errorRed,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: LabTestColorPalette.errorRed,
                width: 2,
              ),
            ),
            counterText: '',  // Hide the default counter
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: viewModel.setPincode,
          validator: (value) => viewModel.validationErrors['pincode'],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nearby Landmark',
          controller: _landmarkController,
          validator: (value) => viewModel.validationErrors['nearbyLandmark'],
          prefixIcon: Icons.place,
          onChanged: viewModel.setNearbyLandmark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Floor',
          controller: _floorController,
          validator: (value) => viewModel.validationErrors['floor'],
          prefixIcon: Icons.home,
          onChanged: viewModel.setFloor,
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
            color: LabTestColorPalette.backgroundCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LabTestColorPalette.borderLight),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Lift Access'),
                value: viewModel.profile.liftAccess,
                onChanged: (value) => viewModel.setLiftAccess(value),
                contentPadding: EdgeInsets.zero,
                activeColor: LabTestColorPalette.primaryBlue,
              ),
              SwitchListTile(
                title: const Text('Wheelchair Access'),
                value: viewModel.profile.wheelchairAccess,
                onChanged: (value) => viewModel.setWheelchairAccess(value),
                contentPadding: EdgeInsets.zero,
                activeColor: LabTestColorPalette.primaryBlue,
              ),
              SwitchListTile(
                title: const Text('Parking Available'),
                value: viewModel.profile.parkingAvailable,
                onChanged: (value) => viewModel.setParkingAvailable(value),
                contentPadding: EdgeInsets.zero,
                activeColor: LabTestColorPalette.primaryBlue,
              ),
              SwitchListTile(
                title: const Text('Ambulance Service'),
                value: viewModel.profile.ambulanceServiceAvailable,
                onChanged: (value) => viewModel.setAmbulanceServiceAvailable(value),
                contentPadding: EdgeInsets.zero,
                activeColor: LabTestColorPalette.primaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStep(LabTestRegistrationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        UploadSectionWidget(
          label: 'Regulatory Compliance Document',
          onFilesSelected: (files) {
            if (files.isNotEmpty) {
              final file = files.first;
              viewModel.setRegulatoryComplianceFile(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.regulatoryComplianceFile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LabTestColorPalette.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: LabTestColorPalette.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: LabTestColorPalette.successGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${viewModel.regulatoryComplianceFileName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: LabTestColorPalette.textPrimary,
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
          label: 'Quality Assurance Document',
          onFilesSelected: (files) {
            if (files.isNotEmpty) {
              final file = files.first;
              viewModel.setQualityAssuranceFile(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.qualityAssuranceFile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LabTestColorPalette.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: LabTestColorPalette.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: LabTestColorPalette.successGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${viewModel.qualityAssuranceFileName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: LabTestColorPalette.textPrimary,
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
          label: 'Center Photos',
          onFilesSelected: (files) {
            for (var file in files) {
              viewModel.addCenterPhotoFile(file['file'] as File, file['name'] as String);
            }
          },
        ),
        if (viewModel.centerPhotoFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LabTestColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: LabTestColorPalette.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Center Photos (${viewModel.centerPhotoFiles.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: LabTestColorPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: viewModel.centerPhotoFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photoData = entry.value;
                    final String fileName = photoData['name'] as String;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: LabTestColorPalette.secondaryTealLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: LabTestColorPalette.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo,
                            size: 16,
                            color: LabTestColorPalette.primaryBlue,
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
                            onTap: () => viewModel.removeCenterPhotoFile(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: LabTestColorPalette.errorRed,
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

  Widget _buildNavigationButtons(LabTestRegistrationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
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
                  side: BorderSide(color: LabTestColorPalette.primaryBlue),
                  foregroundColor: LabTestColorPalette.primaryBlue,
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
                backgroundColor: LabTestColorPalette.primaryBlue,
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

  bool _validateCurrentStep(LabTestRegistrationViewModel viewModel) {
    List<String> errors = [];
    
    switch (_currentStep) {
      case 0:
        if (_centerNameController.text.isEmpty) {
          errors.add('Center Name is required');
        }
        if (_gstNumberController.text.isEmpty) {
          errors.add('GST Number is required');
        }
        if (_panNumberController.text.isEmpty) {
          errors.add('PAN Number is required');
        }
        if (_ownerNameController.text.isEmpty) {
          errors.add('Owner Name is required');
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
        if (_mainContactController.text.isEmpty) {
          errors.add('Main Contact Number is required');
        }
        if (_emergencyContactController.text.isEmpty) {
          errors.add('Emergency Contact Number is required');
        }
        break;
        
      case 1:
        if (_businessTimingsController.text.isEmpty) {
          errors.add('Business Timings is required');
        }
        if (viewModel.profile.businessDays.isEmpty) {
          errors.add('At least one Business Day is required');
        }
        if (viewModel.profile.sampleCollectionMethod.isEmpty) {
          errors.add('Sample Collection Method is required');
        }
        if (_homeCollectionGeoLimitController.text.isEmpty) {
          errors.add('Home Collection Geo Limit is required');
        }
        if (viewModel.profile.testTypes.isEmpty) {
          errors.add('At least one Test Type is required');
        }
        break;
        
      case 2:
        if (_addressController.text.isEmpty) {
          errors.add('Address is required');
        }
        if (viewModel.profile.state.isEmpty) {
          errors.add('State is required');
        }
        if (viewModel.profile.city.isEmpty) {
          errors.add('City is required');
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
        
      case 3:
        if (viewModel.regulatoryComplianceFile == null) {
          errors.add('Regulatory Compliance Document is required');
        }
        if (viewModel.qualityAssuranceFile == null) {
          errors.add('Quality Assurance Document is required');
        }
        if (viewModel.centerPhotoFiles.isEmpty) {
          errors.add('At least one Center Photo is required');
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
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Please fix the following errors:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              errorsText,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: LabTestColorPalette.errorRed,
        duration: const Duration(seconds: 8),
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
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: LabTestColorPalette.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: LabTestColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: LabTestColorPalette.primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: LabTestColorPalette.backgroundPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.errorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.errorRed,
            width: 2,
          ),
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
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      style: TextStyle(
        color: LabTestColorPalette.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: LabTestColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: LabTestColorPalette.primaryBlue,
          size: 20,
        ),
        filled: true,
        fillColor: LabTestColorPalette.backgroundPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LabTestColorPalette.primaryBlue,
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

  void _submitForm(LabTestRegistrationViewModel viewModel) async {
    // Validate the current step before submitting
    if (!_validateCurrentStep(viewModel)) {
      return;
    }
    
    try {
      final success = await viewModel.submitProfile();
      
      if (success) {
        _showSuccessDialog();
      } else if (viewModel.error != null) {
        // Show validation errors in a more user-friendly way
        final errors = viewModel.error!.split('\n')
            .where((line) => line.trim().startsWith('•'))
            .map((line) => line.trim().substring(2))
            .toList();
        
        _showValidationErrorsSnackbar(errors);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: LabTestColorPalette.errorRed,
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
                color: LabTestColorPalette.shadowLight,
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
                  color: LabTestColorPalette.successGreen.withOpacity(0.1),
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
                          color: LabTestColorPalette.successGreen,
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
                        color: LabTestColorPalette.textPrimary,
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
                      'Your lab test center has been successfully registered. You can now manage your center through the dashboard.',
                      style: TextStyle(
                        color: LabTestColorPalette.textSecondary,
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
                          backgroundColor: LabTestColorPalette.primaryBlue,
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
              backgroundColor: LabTestColorPalette.backgroundCard,
              selectedColor: LabTestColorPalette.secondaryTealLight,
              checkmarkColor: LabTestColorPalette.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected 
                    ? LabTestColorPalette.textPrimary 
                    : LabTestColorPalette.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected 
                      ? LabTestColorPalette.primaryBlue 
                      : LabTestColorPalette.borderLight,
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