import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/DiagnosticCenterProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyLocationPicker.dart';

class DiagnosticCenterProfileScreen extends StatefulWidget {
  const DiagnosticCenterProfileScreen({super.key});

  @override
  State<DiagnosticCenterProfileScreen> createState() => _DiagnosticCenterProfileScreenState();
}

class _DiagnosticCenterProfileScreenState extends State<DiagnosticCenterProfileScreen> {
  bool _mounted = true;
  final ScrollController _scrollController = ScrollController();

  // Keys for different sections to scroll to
  final GlobalKey _basicInfoKey = GlobalKey();
  final GlobalKey _businessDetailsKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
      context.read<DiagnosticCenterProfileViewModel>().loadProfile();
        context.read<DiagnosticCenterProfileViewModel>().loadServiceStatus();
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
      backgroundColor: LabTestColorPalette.backgroundPrimary,
      body: Consumer<DiagnosticCenterProfileViewModel>(
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
                    style: TextStyle(color: LabTestColorPalette.errorRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LabTestColorPalette.primaryBlue,
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
                    Container(key: _businessDetailsKey, child: _buildBusinessDetailsSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _locationKey, child: _buildLocationSection(profile, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _contactKey, child: _buildContactSection(profile, viewModel)),
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
                            side: BorderSide(color: LabTestColorPalette.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: LabTestColorPalette.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: LabTestColorPalette.primaryBlue,
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

  Widget _buildProfileHeader(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
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
                  color: LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
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
                            border: Border.all(color: LabTestColorPalette.primaryBlueLight, width: 3),
                          ),
                          child: (profile.centerPhotosUrl != null && profile.centerPhotosUrl.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    profile.centerPhotosUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      // If centerPhotosUrl fails, try filesAndImages
                                      if (profile.filesAndImages.isNotEmpty) {
                                        return ClipOval(
                                          child: Image.network(
                                            profile.filesAndImages.first['url'] ?? '',
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.science_outlined,
                                                  size: 40,
                                                  color: LabTestColorPalette.primaryBlue,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return Center(
                                        child: Icon(
                                          Icons.science_outlined,
                                          size: 40,
                                          color: LabTestColorPalette.primaryBlue,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : profile.filesAndImages.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      profile.filesAndImages.first['url'] ?? '',
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.science_outlined,
                                            size: 40,
                                            color: LabTestColorPalette.primaryBlue,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.science_outlined,
                                      size: 40,
                                      color: LabTestColorPalette.primaryBlue,
                                    ),
                                  ),
                        ),
                        if (viewModel.isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _showUploadDialog(
                                  context,
                                  'Profile Photo',
                                  'profilePhoto',
                                  isImage: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: LabTestColorPalette.primaryBlue,
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
                                color: viewModel.isServiceActive ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                viewModel.isServiceActive ? Icons.check : Icons.close,
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
                      profile.testTypes.isNotEmpty
                          ? profile.testTypes.join(', ')
                          : 'No test types added',
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
                    color: viewModel.isServiceActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: viewModel.isServiceActive ? Colors.green.shade200 : Colors.red.shade200,
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
                            viewModel.isServiceActive ? Icons.check_circle : Icons.cancel,
                            color: viewModel.isServiceActive ? Colors.green.shade700 : Colors.red.shade700,
                            size: 16,
                          ),
                          if (viewModel.isLoadingStatus)
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
                        viewModel.isServiceActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: viewModel.isServiceActive ? Colors.green.shade700 : Colors.red.shade700,
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
                        color: LabTestColorPalette.primaryBlue,
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
                  value: profile.mainContactNumber,
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
                  color: LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: LabTestColorPalette.primaryBlue, size: 20),
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

  Widget _buildBasicInfoSection(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Center Name',
            value: profile.name,
            icon: Icons.business,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(name: value),
            controller: viewModel.nameController,
          ),
          _buildInfoTile(
            label: 'GST Number',
            value: profile.gstNumber,
            icon: Icons.numbers,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(gstNumber: value),
            controller: viewModel.gstNumberController,
          ),
          _buildInfoTile(
            label: 'PAN Number',
            value: profile.panNumber,
            icon: Icons.numbers,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(panNumber: value),
            controller: viewModel.panNumberController,
          ),
          _buildInfoTile(
            label: 'Owner Name',
            value: profile.ownerName,
            icon: Icons.person,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(ownerName: value),
            controller: viewModel.ownerNameController,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsSection(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
    return _buildSection(
      title: 'Business Details',
      icon: Icons.business_center,
      child: Column(
        children: [
          _buildDropdownTile(
            label: 'Sample Collection Method',
            value: profile.sampleCollectionMethod,
            icon: Icons.collections,
            isEditing: viewModel.isEditing,
            items: ['Center Only', 'Home Only', 'Both'],
            onChanged: (value) {
              if (value != null) {
                viewModel.updateBusinessInfo(sampleCollectionMethod: value);
              }
            },
          ),
          _buildMultiSelectTile(
            label: 'Test Types',
            values: profile.testTypes,
            icon: Icons.science,
            isEditing: viewModel.isEditing,
            options: [
                        'Blood Tests',
                        'Urine Tests',
                        'X-Ray',
                        'MRI',
                        'CT Scan',
                        'Ultrasound',
                        'ECG',
                        'Other',
                      ],
            onChanged: (values) => viewModel.updateBusinessInfo(testTypes: values),
          ),
          _buildInfoTile(
            label: 'Business Timings',
            value: profile.businessTimings,
            icon: Icons.access_time,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBusinessInfo(businessTimings: value),
            controller: viewModel.businessTimingsController,
          ),
          _buildMultiSelectTile(
            label: 'Business Days',
            values: profile.businessDays,
            icon: Icons.calendar_today,
            isEditing: viewModel.isEditing,
            options: [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday',
                      ],
            onChanged: (values) => viewModel.updateBusinessInfo(businessDays: values),
          ),
          _buildInfoTile(
            label: 'Home Collection Geo Limit',
            value: profile.homeCollectionGeoLimit,
            icon: Icons.location_on,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBusinessInfo(homeCollectionGeoLimit: value),
            controller: viewModel.homeCollectionGeoLimitController,
          ),
          _buildSwitchTile(
            label: 'Emergency Handling Fast Track',
            value: profile.emergencyHandlingFastTrack,
            icon: Icons.emergency,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(emergencyHandlingFastTrack: value),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLocationSection(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
    return _buildSection(
      title: 'Location Details',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Address',
            value: profile.address,
            icon: Icons.home,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(address: value),
            controller: viewModel.addressController,
          ),
          _buildInfoTile(
            label: 'State',
            value: profile.state,
            icon: Icons.map,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(state: value),
            controller: viewModel.stateController,
          ),
          _buildInfoTile(
            label: 'City',
            value: profile.city,
            icon: Icons.location_city,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(city: value),
            controller: viewModel.cityController,
          ),
          _buildInfoTile(
            label: 'Pincode',
            value: profile.pincode,
            icon: Icons.pin,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(pincode: value),
            controller: viewModel.pincodeController,
          ),
          _buildInfoTile(
            label: 'Nearby Landmark',
            value: profile.nearbyLandmark,
            icon: Icons.place,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(nearbyLandmark: value),
            controller: viewModel.nearbyLandmarkController,
          ),
          _buildInfoTile(
            label: 'Floor',
            value: profile.floor,
            icon: Icons.stairs,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateLocationInfo(floor: value),
            controller: viewModel.floorController,
          ),
          if (viewModel.isEditing) ...[
            const SizedBox(height: 16),
            Column(
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
                      child: Icon(Icons.pin_drop, size: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Precise Location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AmbulanceAgencyLocationPicker(
                  initialLocation: profile.location,
                  onLocationSelected: (location) {
                    viewModel.updateLocationInfo(location: location);
                  },
                ),
              ],
            ),
          ] else if (profile.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildLocationMap(profile),
          ],
          const SizedBox(height: 16),
          _buildSwitchTile(
            label: 'Parking Available',
            value: profile.parkingAvailable,
            icon: Icons.local_parking,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(parkingAvailable: value),
          ),
          _buildSwitchTile(
            label: 'Wheelchair Access',
            value: profile.wheelchairAccess,
            icon: Icons.accessible,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(wheelchairAccess: value),
          ),
          _buildSwitchTile(
            label: 'Lift Access',
            value: profile.liftAccess,
            icon: Icons.elevator,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(liftAccess: value),
          ),
          _buildSwitchTile(
            label: 'Ambulance Service Available',
            value: profile.ambulanceServiceAvailable,
            icon: Icons.emergency,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateFacilities(ambulanceServiceAvailable: value),
                    ),
                  ],
                ),
    );
  }

  Widget _buildContactSection(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Main Contact Number',
            value: profile.mainContactNumber,
            icon: Icons.phone,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateContactInfo(mainContactNumber: value),
            controller: viewModel.mainContactNumberController,
          ),
          _buildInfoTile(
            label: 'Emergency Contact Number',
            value: profile.emergencyContactNumber,
            icon: Icons.emergency,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateContactInfo(emergencyContactNumber: value),
            controller: viewModel.emergencyContactNumberController,
          ),
          _buildInfoTile(
            label: 'Email',
            value: profile.email,
            icon: Icons.email,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateContactInfo(email: value),
            controller: viewModel.emailController,
          ),
          _buildInfoTile(
            label: 'Website',
            value: profile.website,
            icon: Icons.web,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateContactInfo(website: value),
            controller: viewModel.websiteController,
          ),
          _buildMultiSelectTile(
            label: 'Languages Spoken',
            values: profile.languagesSpoken,
            icon: Icons.language,
            isEditing: viewModel.isEditing,
            options: [
                        'English',
                        'Hindi',
                        'Marathi',
                        'Gujarati',
                        'Bengali',
                        'Tamil',
                        'Telugu',
                        'Kannada',
                        'Malayalam',
                        'Other',
                      ],
            onChanged: (values) => viewModel.updateFacilities(languagesSpoken: values),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDocumentsSection(DiagnosticCenter profile, DiagnosticCenterProfileViewModel viewModel) {
    return _buildSection(
      title: 'Documents & Photos',
      icon: Icons.folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentSectionHeader(
            label: 'Regulatory Compliance',
            icon: Icons.assignment,
            onAddPressed: () => _showUploadDialog(
              context,
              'Regulatory Compliance',
              'regulatoryCompliance',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (viewModel.regulatoryComplianceUrl.isNotEmpty)
            _buildDocumentList(
              label: 'Regulatory Compliance',
              documents: viewModel.regulatoryComplianceUrl.entries.map((e) => {
                'name': e.key,
                'url': e.value,
              }).toList(),
              icon: Icons.assignment,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                try {
                  await viewModel.deleteDocument('regulatoryCompliance', index);
                  _showSuccessSnackBar(context, 'Document deleted successfully');
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to delete document: $e');
                }
              },
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Quality Assurance',
            icon: Icons.verified,
            onAddPressed: () => _showUploadDialog(
              context,
              'Quality Assurance',
              'qualityAssurance',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (viewModel.qualityAssuranceUrl.isNotEmpty)
            _buildDocumentList(
              label: 'Quality Assurance',
              documents: viewModel.qualityAssuranceUrl.entries.map((e) => {
                'name': e.key,
                'url': e.value,
              }).toList(),
              icon: Icons.verified,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                try {
                  await viewModel.deleteDocument('qualityAssurance', index);
                  _showSuccessSnackBar(context, 'Document deleted successfully');
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to delete document: $e');
                }
              },
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Additional Files & Images',
            icon: Icons.photo_library,
            onAddPressed: () => _showUploadDialog(
              context,
              'Additional Files & Images',
              'filesAndImages',
              isImage: true,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (viewModel.filesAndImages.isNotEmpty)
            _buildDocumentList(
              label: 'Additional Files & Images',
              documents: viewModel.filesAndImages,
              icon: Icons.photo_library,
              isImage: true,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                try {
                  await viewModel.deleteDocument('filesAndImages', index);
                  _showSuccessSnackBar(context, 'File deleted successfully');
                } catch (e) {
                  _showErrorSnackBar(context, 'Failed to delete file: $e');
                }
              },
            ),

          const SizedBox(height: 16),

          _buildLocationMap(profile),
              ],
            ),
          );
  }

  Widget _buildLocationMap(DiagnosticCenter profile) {
    // Parse location coordinates
    if (profile.location.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            'No location coordinates available',
            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final locationParts = profile.location.split(',');
    if (locationParts.length != 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            'Invalid location format: ${profile.location}',
            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final lat = double.tryParse(locationParts[0].trim());
    final lng = double.tryParse(locationParts[1].trim());
    if (lat == null || lng == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            'Invalid coordinates: ${profile.location}',
            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('center_location'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: profile.name,
                snippet: profile.address,
              ),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
        ),
      ),
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
                color: LabTestColorPalette.primaryBlue,
                size: 20,
              ),
              onPressed: onAddPressed,
              tooltip: 'Add $label',
            ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, String title, String documentType, {required bool isImage}) {
    final viewModel = context.read<DiagnosticCenterProfileViewModel>();
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
                            color: LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: LabTestColorPalette.primaryBlue,
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
                          borderSide: BorderSide(color: LabTestColorPalette.primaryBlue),
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
                          color: isFileSelected ? Colors.green.shade50 : LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFileSelected ? Colors.green.shade200 : LabTestColorPalette.primaryBlueLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isFileSelected
                                  ? Icons.check_circle
                                  : (isImage ? Icons.image : Icons.picture_as_pdf),
                              color: isFileSelected ? Colors.green.shade700 : LabTestColorPalette.primaryBlue,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isFileSelected
                                  ? selectedFileName ?? 'File Selected'
                                  : 'Click to select ${isImage ? 'image' : 'PDF'}',
                              style: TextStyle(
                                color: isFileSelected ? Colors.green.shade700 : LabTestColorPalette.primaryBlue,
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
                              await viewModel.uploadDocument(
                                documentType,
                                selectedFile!,
                                nameController.text,
                              );
                              
                              _showSuccessSnackBar(context, 'Document uploaded successfully');
                              Navigator.pop(context);
                            } catch (e) {
                              setState(() {
                                isUploading = false;
                              });
                              _showErrorSnackBar(context, 'Failed to upload document: $e');
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LabTestColorPalette.primaryBlue,
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
                          color: LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: LabTestColorPalette.primaryBlue,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PDF Document',
                                  style: TextStyle(
                                    color: LabTestColorPalette.primaryBlue,
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

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required Function(String?) onChanged,
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
                        borderSide: BorderSide(color: LabTestColorPalette.primaryBlue),
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
                          icon: Icon(Icons.arrow_drop_down, color: LabTestColorPalette.primaryBlue),
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

  Widget _buildMultiSelectTile({
    required String label,
    required List<String> values,
    required IconData icon,
    required bool isEditing,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = values.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: isEditing ? (selected) {
                  final newValues = List<String>.from(values);
                  if (selected) {
                    newValues.add(option);
                  } else {
                    newValues.remove(option);
                  }
                  onChanged(newValues);
                } : null,
                backgroundColor: Colors.grey.shade100,
                selectedColor: LabTestColorPalette.primaryBlueLight.withOpacity(0.2),
                checkmarkColor: LabTestColorPalette.primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? LabTestColorPalette.primaryBlue : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              );
            }).toList(),
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
              activeColor: LabTestColorPalette.primaryBlue,
              activeTrackColor: LabTestColorPalette.primaryBlueLight.withOpacity(0.5),
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