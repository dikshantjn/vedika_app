import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _mounted = true;
  bool _isServiceActive = false;
  bool _isLoadingStatus = false;
  String? _statusError;

  // Scroll controller for the main scroll view
  final ScrollController _scrollController = ScrollController();

  // Keys for different sections to scroll to
  final GlobalKey _basicInfoKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _medicalInfoKey = GlobalKey();
  final GlobalKey _facilitiesKey = GlobalKey();
  final GlobalKey _specialitiesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<HospitalProfileViewModel>().fetchHospitalProfile();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<HospitalProfileViewModel>(
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
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchHospitalProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = viewModel.hospitalProfile;
          if (profile == null) {
            return const Center(child: Text('No hospital profile found'));
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
                    Container(key: _addressKey, child: _buildAddressSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _medicalInfoKey, child: _buildMedicalInfoSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _facilitiesKey, child: _buildFacilitiesSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _specialitiesKey, child: _buildSpecialitiesSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(child: _buildDocumentsSection(profile, viewModel)),
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
                          onPressed: () {
                            viewModel.updateProfile();
                            _showSuccessSnackBar(context, 'Profile updated successfully');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: HospitalVendorColorPalette.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HospitalVendorColorPalette.primaryBlue,
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

  Widget _buildProfileHeader(HospitalProfile profile, HospitalProfileViewModel viewModel) {
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
                  color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
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
                            border: Border.all(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3), width: 3),
                          ),
                          child: Center(
                            child: Text(
                              profile.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: HospitalVendorColorPalette.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: profile.isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              profile.isActive ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.ownerName,
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
                    color: profile.isActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: profile.isActive ? Colors.green.shade200 : Colors.red.shade200,
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
                      Icon(
                        profile.isActive ? Icons.check_circle : Icons.cancel,
                        color: profile.isActive ? Colors.green.shade700 : Colors.red.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: profile.isActive ? Colors.green.shade700 : Colors.red.shade700,
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
                        color: HospitalVendorColorPalette.primaryBlue,
                      ),
                      onPressed: () {
                        viewModel.toggleEditMode();
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
                  value: profile.contactNumber,
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

  Widget _buildBasicInfoSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Hospital Name',
            value: profile.name,
            icon: Icons.local_hospital,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(name: value),
            controller: viewModel.nameController,
          ),
          _buildInfoTile(
            label: 'Owner Name',
            value: profile.ownerName,
            icon: Icons.person,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(ownerName: value),
            controller: viewModel.ownerNameController,
          ),
          _buildInfoTile(
            label: 'GST Number',
            value: profile.gstNumber,
            icon: Icons.receipt_long,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(gstNumber: value),
            controller: viewModel.gstNumberController,
          ),
          _buildInfoTile(
            label: 'PAN Number',
            value: profile.panNumber,
            icon: Icons.credit_card,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(panNumber: value),
            controller: viewModel.panNumberController,
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
            value: profile.contactNumber,
            icon: Icons.phone,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(phoneNumber: value),
            controller: viewModel.phoneController,
          ),
          if (profile.website != null)
            _buildInfoTile(
              label: 'Website',
              value: profile.website!,
              icon: Icons.language,
              isEditing: viewModel.isEditing,
              onChanged: (value) => viewModel.updateBasicInfo(website: value),
              controller: viewModel.websiteController,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Address',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Complete Address',
            value: profile.address,
            icon: Icons.home,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(address: value),
            controller: viewModel.addressController,
          ),
          _buildInfoTile(
            label: 'Landmark',
            value: profile.landmark,
            icon: Icons.place,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(landmark: value),
            controller: viewModel.landmarkController,
          ),
          _buildInfoTile(
            label: 'City',
            value: profile.city,
            icon: Icons.location_city,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(city: value),
            controller: viewModel.cityController,
          ),
          _buildInfoTile(
            label: 'State',
            value: profile.state,
            icon: Icons.map,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(state: value),
            controller: viewModel.stateController,
          ),
          _buildInfoTile(
            label: 'Pincode',
            value: profile.pincode,
            icon: Icons.pin,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(pincode: value),
            controller: viewModel.pincodeController,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Medical Information',
      icon: Icons.medical_services,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Working Time',
            value: profile.workingTime,
            icon: Icons.access_time,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateMedicalInfo(workingTime: value),
            controller: viewModel.workingTimeController,
          ),
          _buildInfoTile(
            label: 'Working Days',
            value: profile.workingDays,
            icon: Icons.calendar_today,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateMedicalInfo(workingDays: value),
            controller: viewModel.workingDaysController,
          ),
          _buildInfoTile(
            label: 'Beds Available',
            value: profile.bedsAvailable.toString(),
            icon: Icons.bed,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateMedicalInfo(bedsAvailable: int.tryParse(value)),
            controller: viewModel.bedsAvailableController,
          ),
          _buildInfoTile(
            label: 'Fees Range',
            value: profile.feesRange,
            icon: Icons.attach_money,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateMedicalInfo(feesRange: value),
            controller: viewModel.feesRangeController,
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Facilities',
      icon: Icons.home_work,
      child: Column(
        children: [
          _buildSwitchTile(
            label: 'Lift Access',
            value: profile.hasLiftAccess,
            icon: Icons.elevator,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(hasLiftAccess: value),
          ),
          _buildSwitchTile(
            label: 'Parking',
            value: profile.hasParking,
            icon: Icons.local_parking,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(hasParking: value),
          ),
          _buildSwitchTile(
            label: 'Ambulance Service',
            value: profile.providesAmbulanceService,
            icon: Icons.medical_services,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(providesAmbulanceService: value),
          ),
          _buildSwitchTile(
            label: 'Wheelchair Access',
            value: profile.hasWheelchairAccess,
            icon: Icons.accessible,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(hasWheelchairAccess: value),
          ),
          _buildSwitchTile(
            label: 'Online Consultancy',
            value: profile.providesOnlineConsultancy,
            icon: Icons.computer,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(providesOnlineConsultancy: value),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialitiesSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Specialities & Services',
      icon: Icons.medical_services,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceSection(
            label: 'Speciality Types',
            services: profile.specialityTypes,
            icon: Icons.medical_services,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(specialityTypes: services),
          ),
          const SizedBox(height: 16),
          _buildServiceSection(
            label: 'Services Offered',
            services: profile.servicesOffered,
            icon: Icons.medical_services,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(servicesOffered: services),
          ),
          const SizedBox(height: 16),
          _buildServiceSection(
            label: 'Insurance Companies',
            services: profile.insuranceCompanies,
            icon: Icons.medical_services,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(insuranceCompanies: services),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(HospitalProfile profile, HospitalProfileViewModel viewModel) {
    return _buildSection(
      title: 'Documents',
      icon: Icons.folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentSectionHeader(
            label: 'Hospital Photos',
            icon: Icons.photo_library,
            onAddPressed: () => _showUploadDialog(
              context,
              'Hospital Photos',
              'photos',
              isImage: true,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (profile.photos.isNotEmpty)
            _buildDocumentList(
              label: 'Hospital Photos',
              documents: profile.photos,
              icon: Icons.photo_library,
              isImage: true,
              isEditing: viewModel.isEditing,
              onDelete: (index) => viewModel.deleteFile('photos', index),
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Certifications',
            icon: Icons.description,
            onAddPressed: () => _showUploadDialog(
              context,
              'Certifications',
              'certifications',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (profile.certifications.isNotEmpty)
            _buildDocumentList(
              label: 'Certifications',
              documents: profile.certifications,
              icon: Icons.description,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) => viewModel.deleteFile('certifications', index),
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Licenses',
            icon: Icons.assignment,
            onAddPressed: () => _showUploadDialog(
              context,
              'Licenses',
              'licenses',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (profile.licenses.isNotEmpty)
            _buildDocumentList(
              label: 'Licenses',
              documents: profile.licenses,
              icon: Icons.assignment,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) => viewModel.deleteFile('licenses', index),
            ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, String title, String documentType, {required bool isImage}) {
    final viewModel = context.read<HospitalProfileViewModel>();
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
                            color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: HospitalVendorColorPalette.primaryBlue,
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
                      'Document Name',
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
                        hintText: 'Enter a name for this document',
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
                          borderSide: BorderSide(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3), width: 2),
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

                            // If name is empty, use the file name (without extension) as default
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
                          color: isFileSelected ? Colors.green.shade50 : HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFileSelected ? Colors.green.shade200 : HospitalVendorColorPalette.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isFileSelected
                                  ? Icons.check_circle
                                  : (isImage ? Icons.image : Icons.picture_as_pdf),
                              color: isFileSelected ? Colors.green.shade700 : HospitalVendorColorPalette.primaryBlue,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isFileSelected
                                  ? selectedFileName ?? 'File Selected'
                                  : 'Click to select ${isImage ? 'image' : 'PDF'}',
                              style: TextStyle(
                                color: isFileSelected ? Colors.green.shade700 : HospitalVendorColorPalette.primaryBlue,
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
                              // Upload file using the viewModel
                              await viewModel.uploadFile(documentType, isImage: isImage);
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Success!',
                                    message: 'Document uploaded successfully',
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
                                    message: 'Failed to upload document: $e',
                                    contentType: ContentType.failure,
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HospitalVendorColorPalette.primaryBlue,
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
                color: HospitalVendorColorPalette.primaryBlue,
                size: 20,
              ),
              onPressed: onAddPressed,
              tooltip: 'Add $label',
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentList({
    required String label,
    required List<Map<String, String>> documents,
    required IconData icon,
    required bool isImage,
    required bool isEditing,
    required Function(int) onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isImage ? 1.2 : 0.8,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          final url = document['url'] ?? '';
          final name = document['name'] ?? 'Document ${index + 1}';

          return _buildDocumentCard(
            url: url,
            name: name,
            isImage: isImage,
            isEditing: isEditing,
            onDelete: () => onDelete(index),
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard({
    required String url,
    required String name,
    required bool isImage,
    required bool isEditing,
    required VoidCallback onDelete,
  }) {
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
                  child: isImage
                      ? Image.network(
                    url,
                    fit: BoxFit.cover,
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
                  )
                      : Container(
                    color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: HospitalVendorColorPalette.primaryBlue,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PDF Document',
                            style: TextStyle(
                              color: HospitalVendorColorPalette.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  color: Colors.red.shade700,
                  size: 18,
                ),
                onPressed: onDelete,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Delete document',
              ),
            ),
          ),
      ],
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
                  color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: HospitalVendorColorPalette.primaryBlue, size: 20),
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
                    onChanged: onChanged,
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
                        borderSide: BorderSide(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3)),
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
              onChanged: onChanged,
              activeColor: HospitalVendorColorPalette.primaryBlue,
              activeTrackColor: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3),
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

  Widget _buildServiceSection({
    required String label,
    required List<String> services,
    required IconData icon,
    required bool isEditing,
    required Function(List<String>) onServicesChanged,
  }) {
    // Create a unique key for this service section
    final String sectionKey = 'service_${label.replaceAll(' ', '_').toLowerCase()}';

    // Get or create the controller for this section
    final TextEditingController controller = TextEditingController();

    // Get or create the focus node for this section
    final FocusNode focusNode = FocusNode();

    // Create a local copy of services that we can modify
    final List<String> tempServices = List.from(services);

    void _addService(String service) {
      if (service.isEmpty) return;
      setState(() {
        tempServices.add(service.trim());
        controller.clear();
        onServicesChanged(tempServices);
      });
    }

    void _removeService(String service) {
      setState(() {
        tempServices.remove(service);
        onServicesChanged(tempServices);
      });
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
                    hintText: 'Add new service',
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
                      borderSide: BorderSide(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3)),
                    ),
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: HospitalVendorColorPalette.primaryBlue),
                      onPressed: () => _addService(controller.text),
                    ),
                  ),
                  onSubmitted: (value) => _addService(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (isEditing ? tempServices : services).map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service,
                    style: TextStyle(
                      fontSize: 14,
                      color: HospitalVendorColorPalette.primaryBlue,
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _removeService(service),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: HospitalVendorColorPalette.primaryBlue,
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