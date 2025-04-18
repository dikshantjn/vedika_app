import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/AddressSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/BasicInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/CertificationSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/FacilitiesSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/LocationSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/MedicalInfoSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/Sections/PhotoSection.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/HospitalDashboardScreen.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({Key? key}) : super(key: key);

  @override
  _HospitalRegistrationScreenState createState() => _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState extends State<HospitalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  int _currentSection = 0;
  bool _isValidating = false;

  final List<Widget> _sections = [
    const BasicInfoSection(),
    const AddressSection(),
    const MedicalInfoSection(),
    const CertificationSection(),
    const FacilitiesSection(),
    const LocationSection(),
    const PhotoSection(),
  ];

  final List<String> _sectionTitles = [
    'Basic Information',
    'Address Information',
    'Medical Information',
    'Certifications',
    'Facilities',
    'Location',
    'Photos',
  ];

  void _showSubmissionDialog(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: HospitalVendorColorPalette.successGreen,
              size: 32,
            ),
            const SizedBox(width: 16),
            const Text(
              'Registration Submitted',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your hospital registration request has been submitted successfully. Our admin team will review your profile and verify the details.',
              style: TextStyle(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HospitalVendorColorPalette.neutralGrey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: HospitalVendorColorPalette.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Login Credentials:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCredentialRow('Email', email),
                  const SizedBox(height: 8),
                  _buildCredentialRow('Password', password),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please keep these credentials safe. You will need them to login once your profile is verified.',
              style: TextStyle(
                color: HospitalVendorColorPalette.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: HospitalVendorColorPalette.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _nextSection() {
    if (_currentSection < _sections.length - 1) {
      setState(() {
        _isValidating = true;
      });
      
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentSection++;
          _isValidating = false;
        });
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<HospitalRegistrationViewModel>(context, listen: false);
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Submitting Registration...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we upload your files and register your hospital.',
                    style: TextStyle(
                      color: HospitalVendorColorPalette.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final success = await viewModel.registerHospital();
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (success && mounted) {
        _showSubmissionDialog(
          viewModel.email ?? '',
          viewModel.password ?? '',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${viewModel.error}'),
            backgroundColor: HospitalVendorColorPalette.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HospitalVendorColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'Hospital Registration',
          style: TextStyle(
            color: HospitalVendorColorPalette.textInverse,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: HospitalVendorColorPalette.primaryBlue,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalDashboardScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: HospitalVendorColorPalette.textInverse,
            ),
            child: const Text(
              'Go to Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: HospitalVendorColorPalette.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: HospitalVendorColorPalette.shadowMedium,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentSection + 1} of ${_sections.length}',
                        style: const TextStyle(
                          color: HospitalVendorColorPalette.textInverse,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${((_currentSection + 1) / _sections.length * 100).round()}%',
                        style: const TextStyle(
                          color: HospitalVendorColorPalette.textInverse,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentSection + 1) / _sections.length,
                      backgroundColor: HospitalVendorColorPalette.neutralGrey200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        HospitalVendorColorPalette.neutralWhite,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sectionTitles[_currentSection],
                    style: const TextStyle(
                      color: HospitalVendorColorPalette.textInverse,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HospitalVendorColorPalette.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: HospitalVendorColorPalette.shadowLight,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _sections[_currentSection],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: HospitalVendorColorPalette.backgroundPrimary,
                boxShadow: [
                  BoxShadow(
                    color: HospitalVendorColorPalette.shadowLight,
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentSection > 0)
                    ElevatedButton(
                      onPressed: _previousSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HospitalVendorColorPalette.neutralGrey100,
                        foregroundColor: HospitalVendorColorPalette.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 100),
                  if (_currentSection < _sections.length - 1)
                    ElevatedButton(
                      onPressed: _isValidating ? null : _nextSection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HospitalVendorColorPalette.primaryBlue,
                        foregroundColor: HospitalVendorColorPalette.textInverse,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isValidating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  HospitalVendorColorPalette.textInverse,
                                ),
                              ),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HospitalVendorColorPalette.successGreen,
                        foregroundColor: HospitalVendorColorPalette.textInverse,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 