import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:path/path.dart' as path;

class DoctorClinicProfileScreen extends StatefulWidget {
  const DoctorClinicProfileScreen({Key? key}) : super(key: key);

  @override
  State<DoctorClinicProfileScreen> createState() => _DoctorClinicProfileScreenState();
}

class _DoctorClinicProfileScreenState extends State<DoctorClinicProfileScreen> {
  bool _mounted = true;
  bool _isServiceActive = false;
  bool _isLoadingStatus = false;
  String? _statusError;

  // Scroll controller for the main scroll view
  final ScrollController _scrollController = ScrollController();

  // Keys for different sections to scroll to
  final GlobalKey _basicInfoKey = GlobalKey();
  final GlobalKey _professionalDetailsKey = GlobalKey();
  final GlobalKey _consultationKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  final VendorService _statusService = VendorService();
  final VendorLoginService _loginService = VendorLoginService();
  final DoctorClinicStorageService _storageService = DoctorClinicStorageService();

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<DoctorClinicProfileViewModel>().loadProfile();
      }
    });
  }

  Future<void> _loadServiceStatus() async {
    if (!_mounted) return;
    
    setState(() {
      _isLoadingStatus = true;
      _statusError = null;
    });

    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      final status = await _statusService.getVendorStatus(vendorId);
      
      if (_mounted) {
        setState(() {
          _isServiceActive = status;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      if (_mounted) {
        setState(() {
          _statusError = e.toString();
          _isLoadingStatus = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _scrollController.dispose();
    super.dispose();
  }

  // Method to scroll to a specific section
  void _scrollToSection(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        position.dy - 100, // Offset to account for the header
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Method to handle text field changes
  void _handleTextFieldChange(String value, Function(String) onChanged) {
    onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: Consumer<DoctorClinicProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: TextStyle(color: DoctorConsultationColorPalette.errorRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = viewModel.profile;
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(profile, viewModel),
                    const SizedBox(height: 24),
                    Container(key: _basicInfoKey, child: _buildBasicInfoSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _professionalDetailsKey, child: _buildProfessionalDetailsSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _consultationKey, child: _buildConsultationSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _locationKey, child: _buildLocationSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _documentsKey, child: _buildDocumentsSection(profile, viewModel)),
                    
                    // Add the Update button at the bottom of the content
                    if (viewModel.isEditing) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () async {
                            final success = await viewModel.saveChanges();
                            if (success) {
                              _showSuccessSnackBar(context, 'Profile updated successfully');
                            } else {
                              _showErrorSnackBar(context, 'Failed to update profile');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: DoctorConsultationColorPalette.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: DoctorConsultationColorPalette.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: DoctorConsultationColorPalette.primaryBlueLight, width: 3),
                            image: profile.profilePicture.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profile.profilePicture),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profile.profilePicture.isEmpty
                              ? Center(
                                  child: Text(
                                    profile.doctorName.isNotEmpty ? profile.doctorName[0].toUpperCase() : 'D',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: DoctorConsultationColorPalette.primaryBlue,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (viewModel.isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                // Pick image
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                );

                                if (result != null && result.files.isNotEmpty) {
                                  File file = File(result.files.single.path!);
                                  try {
                                    final url = await _storageService.uploadFile(
                                      file,
                                      fileType: 'profile_pictures',
                                    );
                                    viewModel.updateProfilePicture(url);
                                    _showSuccessSnackBar(context, 'Profile picture uploaded successfully');
                                  } catch (e) {
                                    _showErrorSnackBar(context, 'Failed to upload profile picture: $e');
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DoctorConsultationColorPalette.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isServiceActive ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                _isServiceActive ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.doctorName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.specializations.isNotEmpty
                          ? profile.specializations.join(', ')
                          : 'Specialization not added',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Status indicator in top-left corner
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isServiceActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isServiceActive ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            _isServiceActive ? Icons.check_circle : Icons.cancel,
                            color: _isServiceActive ? Colors.green.shade700 : Colors.red.shade700,
                            size: 16,
                          ),
                          if (_isLoadingStatus)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isServiceActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isServiceActive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Edit button in top-right corner
              if (!viewModel.isEditing)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                      onPressed: () {
                        // Enter edit mode and scroll to basic info section
                        viewModel.toggleEditMode();
                        // Use a small delay to ensure the UI has updated before scrolling
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollToSection(_basicInfoKey);
                        });
                      },
                      tooltip: 'Edit Profile',
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email,
                ),
                const SizedBox(height: 16),
                _buildProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile.phoneNumber,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.city}, ${profile.state}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Doctor Name',
            value: profile.doctorName,
            icon: Icons.person,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(doctorName: value),
            controller: viewModel.doctorNameController,
          ),
          _buildDropdownTile(
            label: 'Gender',
            value: profile.gender,
            icon: Icons.person_outline,
            isEditing: viewModel.isEditing,
            items: ['Male', 'Female', 'Other'],
            onChanged: (value) {
              if (value != null) {
                viewModel.updateBasicInfo(gender: value);
              }
            },
          ),
          _buildInfoTile(
            label: 'Email',
            value: profile.email,
            icon: Icons.email,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(email: value),
            controller: viewModel.emailController,
          ),
          _buildInfoTile(
            label: 'Phone',
            value: profile.phoneNumber,
            icon: Icons.phone,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(phoneNumber: value),
            controller: viewModel.phoneNumberController,
          ),
          _buildInfoTile(
            label: 'License Number',
            value: profile.licenseNumber,
            icon: Icons.card_membership,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(licenseNumber: value),
            controller: viewModel.licenseNumberController,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: DoctorConsultationColorPalette.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required Function(String) onChanged,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: controller,
                    onChanged: (text) => _handleTextFieldChange(text, onChanged),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: DoctorConsultationColorPalette.primaryBlue),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          underline: Container(),
                          items: items.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsSection(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    return _buildSection(
      title: 'Professional Details',
      icon: Icons.work_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(
            label: 'Years of Experience',
            value: profile.experienceYears.toString(),
            icon: Icons.calendar_today,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateProfessionalDetails(
              experienceYears: int.tryParse(value) ?? profile.experienceYears,
            ),
            controller: viewModel.experienceYearsController,
          ),
          _buildSwitchTile(
            label: 'Telemedicine Experience',
            value: profile.hasTelemedicineExperience,
            icon: Icons.video_call,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateProfessionalDetails(hasTelemedicineExperience: value),
          ),
          _buildTagsSection(
            label: 'Educational Qualifications',
            tags: profile.educationalQualifications,
            icon: Icons.school,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateProfessionalDetails(educationalQualifications: tags),
            addHint: 'Add qualification (e.g., MBBS, MD)',
          ),
          const SizedBox(height: 16),
          _buildTagsSection(
            label: 'Specializations',
            tags: profile.specializations,
            icon: Icons.local_hospital,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateProfessionalDetails(specializations: tags),
            addHint: 'Add specialization (e.g., Cardiology)',
          ),
          const SizedBox(height: 16),
          _buildTagsSection(
            label: 'Language Proficiency',
            tags: profile.languageProficiency,
            icon: Icons.language,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateProfessionalDetails(languageProficiency: tags),
            addHint: 'Add language (e.g., English)',
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationSection(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    return _buildSection(
      title: 'Consultation Details',
      icon: Icons.event_note,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(
            label: 'Consultation Fees Range',
            value: profile.consultationFeesRange,
            icon: Icons.monetization_on,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateConsultationDetails(consultationFeesRange: value),
            controller: viewModel.consultationFeesRangeController,
          ),
          _buildTagsSection(
            label: 'Consultation Types',
            tags: profile.consultationTypes,
            icon: Icons.medical_services,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateConsultationDetails(consultationTypes: tags),
            addHint: 'Add type (e.g., Online, In-Person)',
          ),
          const SizedBox(height: 16),
          _buildTagsSection(
            label: 'Consultation Days',
            tags: profile.consultationDays,
            icon: Icons.calendar_month,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateConsultationDetails(consultationDays: tags),
            addHint: 'Add day (e.g., Monday)',
          ),
          const SizedBox(height: 16),
          _buildTagsSection(
            label: 'Insurance Partners',
            tags: profile.insurancePartners,
            icon: Icons.health_and_safety,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateConsultationDetails(insurancePartners: tags),
            addHint: 'Add insurance partner',
          ),
          if (viewModel.isEditing) ...[
            const SizedBox(height: 16),
            const Text(
              'Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildTimeSlots(profile, viewModel),
          ] else if (profile.consultationTimeSlots.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildTimeSlotsList(profile.consultationTimeSlots),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlots(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    // Create a copy of time slots that we can modify
    List<Map<String, String>> timeSlots = List.from(profile.consultationTimeSlots);
    
    return Column(
      children: [
        for (int i = 0; i < timeSlots.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                    ),
                    child: Text(
                      timeSlots[i]['day'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                    ),
                    child: Text(
                      timeSlots[i]['startTime'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                    ),
                    child: Text(
                      timeSlots[i]['endTime'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: DoctorConsultationColorPalette.errorRed,
                    size: 20,
                  ),
                  onPressed: () {
                    // Remove the time slot and update viewModel
                    timeSlots.removeAt(i);
                    viewModel.updateConsultationDetails(consultationTimeSlots: timeSlots);
                  },
                ),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            // Add new time slot with default values and update viewModel
            timeSlots.add({
              'day': 'Monday',
              'startTime': '09:00',
              'endTime': '17:00',
            });
            viewModel.updateConsultationDetails(consultationTimeSlots: timeSlots);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Time Slot'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsList(List<Map<String, String>> timeSlots) {
    return Column(
      children: [
        for (var slot in timeSlots)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DoctorConsultationColorPalette.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: DoctorConsultationColorPalette.primaryBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${slot['day'] ?? ''}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${slot['startTime'] ?? ''} to ${slot['endTime'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection({
    required String label,
    required List<String> tags,
    required IconData icon,
    required bool isEditing,
    required Function(List<String>) onTagsChanged,
    required String addHint,
  }) {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    final List<String> tempTags = List.from(tags);

    void _addTag(String tag) {
      if (tag.isEmpty) return;
      if (!tempTags.contains(tag)) {
        tempTags.add(tag.trim());
        controller.clear();
        onTagsChanged(tempTags);
      }
    }

    void _removeTag(String tag) {
      tempTags.remove(tag);
      onTagsChanged(tempTags);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditing) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: addHint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                    ),
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: DoctorConsultationColorPalette.primaryBlue),
                      onPressed: () => _addTag(controller.text),
                    ),
                  ),
                  onSubmitted: (value) => _addTag(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tempTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 14,
                      color: DoctorConsultationColorPalette.primaryBlue,
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _removeTag(tag),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required IconData icon,
    required bool isEditing,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isEditing)
            Switch(
              value: value,
              onChanged: (newValue) {
                onChanged(newValue);
              },
              activeColor: DoctorConsultationColorPalette.primaryBlue,
              activeTrackColor: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.5),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: value ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: value ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value ? Icons.check_circle : Icons.cancel,
                    color: value ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value ? 'Yes' : 'No',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: value ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    // Get list of states
    final List<String> states = StateCityDataProvider.states.map((state) => state.name).toList();
    
    // Get list of cities for the current state
    final List<String> cities = StateCityDataProvider.getCities(profile.state);
    
    return _buildSection(
      title: 'Clinic Location',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Address',
            value: profile.address,
            icon: Icons.home,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(address: value),
            controller: viewModel.addressController,
          ),
          _buildDropdownTile(
            label: 'State',
            value: profile.state,
            icon: Icons.map,
            isEditing: viewModel.isEditing,
            items: states,
            onChanged: (value) {
              if (value != null) {
                viewModel.updateLocationDetails(state: value);
                // Reset city when state changes
                final newCities = StateCityDataProvider.getCities(value);
                if (newCities.isNotEmpty) {
                  viewModel.updateLocationDetails(city: newCities.first);
                }
              }
            },
          ),
          _buildDropdownTile(
            label: 'City',
            value: profile.city,
            icon: Icons.location_city,
            isEditing: viewModel.isEditing,
            items: StateCityDataProvider.getCities(profile.state),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateLocationDetails(city: value);
              }
            },
          ),
          _buildInfoTile(
            label: 'Pincode',
            value: profile.pincode,
            icon: Icons.pin,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(pincode: value),
            controller: viewModel.pincodeController,
          ),
          _buildInfoTile(
            label: 'Nearby Landmark',
            value: profile.nearbyLandmark,
            icon: Icons.place,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(nearbyLandmark: value),
            controller: viewModel.nearbyLandmarkController,
          ),
          _buildInfoTile(
            label: 'Floor',
            value: profile.floor,
            icon: Icons.stairs,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(floor: value),
            controller: viewModel.floorController,
          ),
          _buildSwitchTile(
            label: 'Lift Access',
            value: profile.hasLiftAccess,
            icon: Icons.elevator,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(hasLiftAccess: value),
          ),
          _buildSwitchTile(
            label: 'Wheelchair Access',
            value: profile.hasWheelchairAccess,
            icon: Icons.accessible,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(hasWheelchairAccess: value),
          ),
          _buildSwitchTile(
            label: 'Parking Available',
            value: profile.hasParking,
            icon: Icons.local_parking,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationDetails(hasParking: value),
          ),
          _buildTagsSection(
            label: 'Other Facilities',
            tags: profile.otherFacilities,
            icon: Icons.more_horiz,
            isEditing: viewModel.isEditing,
            onTagsChanged: (tags) => viewModel.updateLocationDetails(otherFacilities: tags),
            addHint: 'Add facility (e.g., Waiting Area)',
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(DoctorClinicProfile profile, DoctorClinicProfileViewModel viewModel) {
    return _buildSection(
      title: 'Documents & Photos',
      icon: Icons.folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentItem(
            label: 'Medical License',
            fileUrl: profile.medicalLicenseFile,
            icon: Icons.assignment,
            isEditing: viewModel.isEditing,
            onUpload: (url) => viewModel.updateMedicalLicenseFile(url),
            fileType: 'medical_license',
          ),
          const SizedBox(height: 24),
          _buildDocumentSectionHeader(
            label: 'Clinic Photos',
            icon: Icons.photo_library,
            onAddPressed: () => _showUploadDialog(
              context,
              'Clinic Photos',
              'clinic_photos',
              isImage: true,
              onUploadSuccess: (name, url) {
                final photos = List<Map<String, String>>.from(profile.clinicPhotos);
                photos.add({'name': name, 'url': url});
                viewModel.updateClinicPhotos(photos);
              },
            ),
            isEditing: viewModel.isEditing,
          ),
          if (profile.clinicPhotos.isNotEmpty)
            _buildImageGrid(
              photos: profile.clinicPhotos,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                try {
                  // Get the document to delete
                  final document = profile.clinicPhotos[index];
                  final url = document['url'] ?? '';
                  
                  // Delete from Firebase Storage
                  if (url.isNotEmpty) {
                    await _storageService.deleteFile(url);
                  }
                  
                  // Update the profile by removing the document
                  final updatedPhotos = List<Map<String, String>>.from(profile.clinicPhotos);
                  updatedPhotos.removeAt(index);
                  viewModel.updateClinicPhotos(updatedPhotos);
                  
                  _showSuccessSnackBar(context, 'Photo deleted successfully');
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to delete photo: $e');
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String label,
    required String fileUrl,
    required IconData icon,
    required bool isEditing,
    required Function(String) onUpload,
    required String fileType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            if (isEditing)
              TextButton.icon(
                icon: Icon(
                  Icons.upload_file,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  size: 20,
                ),
                label: const Text('Upload'),
                style: TextButton.styleFrom(
                  foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                ),
                onPressed: () async {
                  // Pick a file
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                  );

                  if (result != null && result.files.isNotEmpty) {
                    File file = File(result.files.single.path!);
                    try {
                      final url = await _storageService.uploadFile(
                        file,
                        fileType: fileType,
                      );
                      onUpload(url);
                      _showSuccessSnackBar(context, 'File uploaded successfully');
                    } catch (e) {
                      _showErrorSnackBar(context, 'Failed to upload file: $e');
                    }
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (fileUrl.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DoctorConsultationColorPalette.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.file_present,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uploaded File',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileUrl.split('/').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: DoctorConsultationColorPalette.primaryBlue,
                  ),
                  onPressed: () {
                    // Open the file in a browser or viewer
                    // You would typically launch a URL here
                  },
                ),
              ],
            ),
          )
        else
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.none),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No file uploaded yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isEditing)
                    Text(
                      'Click the Upload button to add a file',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentSectionHeader({
    required String label,
    required IconData icon,
    required VoidCallback onAddPressed,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: DoctorConsultationColorPalette.primaryBlue,
                size: 20,
              ),
              onPressed: onAddPressed,
              tooltip: 'Add $label',
            ),
        ],
      ),
    );
  }

  Widget _buildImageGrid({
    required List<Map<String, String>> photos,
    required bool isEditing,
    required Function(int) onDelete,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final url = photo['url'] ?? '';
        final name = photo['name'] ?? 'Photo ${index + 1}';

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: DoctorConsultationColorPalette.errorRed,
                      size: 18,
                    ),
                    onPressed: () => onDelete(index),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete photo',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showUploadDialog(
    BuildContext context,
    String title,
    String fileType, {
    required bool isImage,
    required Function(String name, String url) onUploadSuccess,
  }) {
    final TextEditingController nameController = TextEditingController();
    bool isNameValid = false;
    bool isFileSelected = false;
    File? selectedFile;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: DoctorConsultationColorPalette.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add $title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter a name for this file',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: DoctorConsultationColorPalette.primaryBlue, width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.label_outline,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          isNameValid = value.trim().isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isUploading ? null : () async {
                        // Show file picker
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: isImage ? FileType.image : FileType.custom,
                          allowedExtensions: isImage ? null : ['pdf'],
                          allowMultiple: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedFile = File(result.files.single.path!);
                            selectedFileName = result.files.single.name;
                            isFileSelected = true;

                            // If name is empty, use the file name as default
                            if (nameController.text.isEmpty) {
                              String fileNameWithoutExt = path.basenameWithoutExtension(selectedFileName!);
                              nameController.text = fileNameWithoutExt;
                              isNameValid = true;
                            }
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: isFileSelected ? Colors.green.shade50 : DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFileSelected ? Colors.green.shade200 : DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isFileSelected
                                  ? Icons.check_circle
                                  : (isImage ? Icons.image : Icons.picture_as_pdf),
                              color: isFileSelected ? Colors.green.shade700 : DoctorConsultationColorPalette.primaryBlue,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isFileSelected
                                  ? selectedFileName ?? 'File Selected'
                                  : 'Click to select ${isImage ? 'image' : 'PDF'}',
                              style: TextStyle(
                                color: isFileSelected ? Colors.green.shade700 : DoctorConsultationColorPalette.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isFileSelected) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Supported formats: ${isImage ? 'JPG, PNG' : 'PDF'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: (isNameValid && isFileSelected && !isUploading) ? () async {
                            setState(() {
                              isUploading = true;
                            });
                            
                            try {
                              // Upload file to Firebase Storage
                              final String downloadUrl = await _storageService.uploadFile(
                                selectedFile!,
                                fileType: fileType,
                              );
                              
                              // Call the success callback
                              onUploadSuccess(nameController.text, downloadUrl);
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Success!',
                                    message: 'File uploaded successfully',
                                    contentType: ContentType.success,
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              
                              // Close the dialog
                              Navigator.pop(context);
                            } catch (e) {
                              setState(() {
                                isUploading = false;
                              });
                              
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Error!',
                                    message: 'Failed to upload file: $e',
                                    contentType: ContentType.failure,
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: message,
          contentType: ContentType.success,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: message,
          contentType: ContentType.failure,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 