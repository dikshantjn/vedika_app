import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';
import '../viewModel/BloodBankAgencyProfileViewModel.dart';
import '../../data/model/BloodBankAgency.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../data/services/BloodbankAgencyStorageService.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class BloodBankAgencyProfileScreen extends StatefulWidget {
  const BloodBankAgencyProfileScreen({Key? key}) : super(key: key);

  @override
  State<BloodBankAgencyProfileScreen> createState() => _BloodBankAgencyProfileScreenState();
}

class _BloodBankAgencyProfileScreenState extends State<BloodBankAgencyProfileScreen> {
  bool _mounted = true;
  bool _isServiceActive = false;
  bool _isLoadingStatus = false;
  String? _statusError;

  // Scroll controller for the main scroll view
  final ScrollController _scrollController = ScrollController();

  // Keys for different sections to scroll to
  final GlobalKey _basicInfoKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final GlobalKey _operationalDetailsKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _documentsKey = GlobalKey();

  final VendorService _statusService = VendorService();
  final VendorLoginService _loginService = VendorLoginService();

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<BloodBankAgencyProfileViewModel>().loadAgencyProfile();
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
    // Call the onChanged callback
    onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<BloodBankAgencyProfileViewModel>(
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
                    onPressed: () => viewModel.loadAgencyProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final agency = viewModel.agency;
          if (agency == null) {
            return const Center(child: Text('No agency profile found'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(agency, viewModel),
                    const SizedBox(height: 24),
                    Container(key: _basicInfoKey, child: _buildBasicInfoSection(agency, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _addressKey, child: _buildAddressSection(agency, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _operationalDetailsKey, child: _buildOperationalDetailsSection(agency, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _servicesKey, child: _buildServicesSection(agency, viewModel)),
                    const SizedBox(height: 24),
                    Container(key: _documentsKey, child: _buildDocumentsSection(agency)),
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
                          onPressed: () {
                            viewModel.saveChanges();
                            _showSuccessSnackBar(context, 'Profile updated successfully');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.deepPurple.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: Colors.deepPurple.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.deepPurple.shade700,
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

  Widget _buildProfileHeader(BloodBankAgency agency, BloodBankAgencyProfileViewModel viewModel) {
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
                  color: Colors.deepPurple.shade50,
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
                            border: Border.all(color: Colors.deepPurple.shade100, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              agency.agencyName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
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
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      agency.agencyName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agency.ownerName,
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
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.deepPurple,
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
                  value: agency.email,
                ),
                const SizedBox(height: 16),
                _buildProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: agency.phoneNumber,
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
                            '${agency.city}, ${agency.state}',
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

  Widget _buildBasicInfoSection(BloodBankAgency agency, BloodBankAgencyProfileViewModel viewModel) {
    return _buildSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Agency Name',
            value: agency.agencyName,
            icon: Icons.business,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(agencyName: value),
            controller: viewModel.agencyNameController,
          ),
          _buildInfoTile(
            label: 'Owner Name',
            value: agency.ownerName,
            icon: Icons.person,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(ownerName: value),
            controller: viewModel.ownerNameController,
          ),
          _buildInfoTile(
            label: 'GST Number',
            value: agency.gstNumber,
            icon: Icons.receipt_long,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(gstNumber: value),
            controller: viewModel.gstNumberController,
          ),
          _buildInfoTile(
            label: 'PAN Number',
            value: agency.panNumber,
            icon: Icons.credit_card,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(panNumber: value),
            controller: viewModel.panNumberController,
          ),
          _buildInfoTile(
            label: 'Email',
            value: agency.email,
            icon: Icons.email,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(email: value),
            controller: viewModel.emailController,
          ),
          _buildInfoTile(
            label: 'Phone',
            value: agency.phoneNumber,
            icon: Icons.phone,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(phoneNumber: value),
            controller: viewModel.phoneNumberController,
          ),
          if (agency.website?.isNotEmpty ?? false)
            _buildInfoTile(
              label: 'Website',
              value: agency.website ?? '',
              icon: Icons.language,
              isEditing: viewModel.isEditing,
              onChanged: (value) => viewModel.updateBasicInfo(website: value),
              controller: viewModel.websiteController,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BloodBankAgency agency, BloodBankAgencyProfileViewModel viewModel) {
    // Get list of states
    final List<String> states = StateCityDataProvider.states.map((state) => state.name).toList();
    
    // Get list of cities for the current state
    final List<String> cities = StateCityDataProvider.getCities(agency.state);
    
    return _buildSection(
      title: 'Address',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            label: 'Complete Address',
            value: agency.completeAddress,
            icon: Icons.home,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(completeAddress: value),
            controller: viewModel.completeAddressController,
          ),
          _buildInfoTile(
            label: 'Landmark',
            value: agency.nearbyLandmark,
            icon: Icons.place,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateAddress(nearbyLandmark: value),
            controller: viewModel.nearbyLandmarkController,
          ),
          // State dropdown in its own row
          _buildDropdownTile(
            label: 'State',
            value: agency.state,
            icon: Icons.map,
            isEditing: viewModel.isEditing,
            items: states,
            onChanged: (value) {
              if (value != null) {
                viewModel.updateBasicInfo(state: value);
                // Reset city when state changes
                final newCities = StateCityDataProvider.getCities(value);
                if (newCities.isNotEmpty) {
                  viewModel.updateBasicInfo(city: newCities.first);
                }
              }
            },
          ),
          // City dropdown in its own row
          _buildDropdownTile(
            label: 'City',
            value: agency.city,
            icon: Icons.location_city,
            isEditing: viewModel.isEditing,
            items: StateCityDataProvider.getCities(agency.state),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateBasicInfo(city: value);
              }
            },
          ),
          _buildInfoTile(
            label: 'Pincode',
            value: agency.pincode,
            icon: Icons.pin,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateBasicInfo(pincode: value),
            controller: viewModel.pincodeController,
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
                          icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade700),
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

  Widget _buildOperationalDetailsSection(BloodBankAgency agency, BloodBankAgencyProfileViewModel viewModel) {
    return _buildSection(
      title: 'Operational Details',
      icon: Icons.schedule,
      child: Column(
        children: [
          _buildSwitchTile(
            label: '24x7 Operational',
            value: agency.is24x7Operational,
            icon: Icons.access_time,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateOperationalDetails(is24x7Operational: value),
          ),
          _buildSwitchTile(
            label: 'All Days Working',
            value: agency.isAllDaysWorking,
            icon: Icons.calendar_today,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateOperationalDetails(isAllDaysWorking: value),
          ),
          _buildInfoTile(
            label: 'Distance Limitations',
            value: '${agency.distanceLimitations} km',
            icon: Icons.route,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateOperationalDetails(
              distanceLimitations: int.tryParse(value) ?? agency.distanceLimitations,
            ),
            controller: viewModel.distanceLimitationsController,
          ),
          _buildInfoTile(
            label: 'Operational Areas',
            value: agency.deliveryOperationalAreas.join(', '),
            icon: Icons.map_outlined,
            isEditing: viewModel.isEditing,
            onChanged: (value) => viewModel.updateOperationalDetails(
              deliveryOperationalAreas: value.split(',').map((e) => e.trim()).toList(),
            ),
            controller: viewModel.deliveryOperationalAreasController,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BloodBankAgency agency, BloodBankAgencyProfileViewModel viewModel) {
    return _buildSection(
      title: 'Services',
      icon: Icons.medical_services,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceSection(
            label: 'Blood Types',
            services: agency.bloodServicesProvided,
            icon: Icons.bloodtype,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(
              bloodServicesProvided: services,
            ),
            viewModel: viewModel,
          ),
          const SizedBox(height: 16),
          _buildServiceSection(
            label: 'Platelet Services',
            services: agency.plateletServicesProvided,
            icon: Icons.science,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(
              plateletServicesProvided: services,
            ),
            viewModel: viewModel,
          ),
          const SizedBox(height: 16),
          _buildServiceSection(
            label: 'Other Services',
            services: agency.otherServicesProvided,
            icon: Icons.more_horiz,
            isEditing: viewModel.isEditing,
            onServicesChanged: (services) => viewModel.updateServices(
              otherServicesProvided: services,
            ),
            viewModel: viewModel,
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
    required BloodBankAgencyProfileViewModel viewModel,
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
                      borderSide: BorderSide(color: Colors.deepPurple.shade300),
                    ),
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.deepPurple.shade700),
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
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _removeService(service),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.deepPurple.shade700,
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

  Widget _buildDocumentsSection(BloodBankAgency agency) {
    final viewModel = context.read<BloodBankAgencyProfileViewModel>();
    final storageService = BloodbankAgencyStorageService();
    
    return _buildSection(
      title: 'Documents',
      icon: Icons.folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentSectionHeader(
            label: 'Agency Photos',
            icon: Icons.photo_library,
            onAddPressed: () => _showUploadDialog(
              context,
              'Agency Photos',
              'agencyPhotos',
              isImage: true,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (agency.agencyPhotos.isNotEmpty)
            _buildDocumentList(
              label: 'Agency Photos',
              documents: agency.agencyPhotos,
              icon: Icons.photo_library,
              isImage: true,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                // Get the document to delete
                final document = agency.agencyPhotos[index];
                final url = document['url'] ?? '';
                
                try {
                  // Delete from Firebase Storage
                  await storageService.deleteFile(url);
                  
                  // Update the agency profile by removing the document
                  final updatedPhotos = List<Map<String, String>>.from(agency.agencyPhotos);
                  updatedPhotos.removeAt(index);
                  
                  // Update the agency profile
                  viewModel.updateDocuments(
                    agencyPhotos: updatedPhotos,
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error!',
                        message: 'Failed to delete document: $e',
                        contentType: ContentType.failure,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'License Files',
            icon: Icons.description,
            onAddPressed: () => _showUploadDialog(
              context,
              'License Files',
              'licenseFiles',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (agency.licenseFiles.isNotEmpty)
            _buildDocumentList(
              label: 'License Files',
              documents: agency.licenseFiles,
              icon: Icons.description,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                // Get the document to delete
                final document = agency.licenseFiles[index];
                final url = document['url'] ?? '';
                
                try {
                  // Delete from Firebase Storage
                  await storageService.deleteFile(url);
                  
                  // Update the agency profile by removing the document
                  final updatedFiles = List<Map<String, String>>.from(agency.licenseFiles);
                  updatedFiles.removeAt(index);
                  
                  // Update the agency profile
                  viewModel.updateDocuments(
                    licenseFiles: updatedFiles,
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error!',
                        message: 'Failed to delete document: $e',
                        contentType: ContentType.failure,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),

          const SizedBox(height: 16),

          _buildDocumentSectionHeader(
            label: 'Registration Certificates',
            icon: Icons.assignment,
            onAddPressed: () => _showUploadDialog(
              context,
              'Registration Certificates',
              'registrationCertificateFiles',
              isImage: false,
            ),
            isEditing: viewModel.isEditing,
          ),
          if (agency.registrationCertificateFiles.isNotEmpty)
            _buildDocumentList(
              label: 'Registration Certificates',
              documents: agency.registrationCertificateFiles,
              icon: Icons.assignment,
              isImage: false,
              isEditing: viewModel.isEditing,
              onDelete: (index) async {
                // Get the document to delete
                final document = agency.registrationCertificateFiles[index];
                final url = document['url'] ?? '';
                
                try {
                  // Delete from Firebase Storage
                  await storageService.deleteFile(url);
                  
                  // Update the agency profile by removing the document
                  final updatedFiles = List<Map<String, String>>.from(agency.registrationCertificateFiles);
                  updatedFiles.removeAt(index);
                  
                  // Update the agency profile
                  viewModel.updateDocuments(
                    registrationCertificateFiles: updatedFiles,
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error!',
                        message: 'Failed to delete document: $e',
                        contentType: ContentType.failure,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
        ],
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
                color: Colors.deepPurple.shade700,
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
    final viewModel = context.read<BloodBankAgencyProfileViewModel>();
    final storageService = BloodbankAgencyStorageService();
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
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            color: Colors.deepPurple.shade700,
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
                          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
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
                          color: isFileSelected ? Colors.green.shade50 : Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFileSelected ? Colors.green.shade200 : Colors.deepPurple.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isFileSelected
                                  ? Icons.check_circle
                                  : (isImage ? Icons.image : Icons.picture_as_pdf),
                              color: isFileSelected ? Colors.green.shade700 : Colors.deepPurple.shade700,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isFileSelected
                                  ? selectedFileName ?? 'File Selected'
                                  : 'Click to select ${isImage ? 'image' : 'PDF'}',
                              style: TextStyle(
                                color: isFileSelected ? Colors.green.shade700 : Colors.deepPurple.shade700,
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
                              final String downloadUrl = await storageService.uploadFile(
                                selectedFile!,
                                fileType: documentType,
                              );
                              
                              // Create the document object
                              final Map<String, String> newDocument = {
                                'name': nameController.text,
                                'url': downloadUrl,
                              };
                              
                              // Update the agency profile with the new document
                              switch (documentType) {
                                case 'agencyPhotos':
                                  final updatedPhotos = List<Map<String, String>>.from(
                                    viewModel.agency?.agencyPhotos ?? [],
                                  );
                                  updatedPhotos.add(newDocument);
                                  viewModel.updateDocuments(agencyPhotos: updatedPhotos);
                                  break;
                                case 'licenseFiles':
                                  final updatedFiles = List<Map<String, String>>.from(
                                    viewModel.agency?.licenseFiles ?? [],
                                  );
                                  updatedFiles.add(newDocument);
                                  viewModel.updateDocuments(licenseFiles: updatedFiles);
                                  break;
                                case 'registrationCertificateFiles':
                                  final updatedFiles = List<Map<String, String>>.from(
                                    viewModel.agency?.registrationCertificateFiles ?? [],
                                  );
                                  updatedFiles.add(newDocument);
                                  viewModel.updateDocuments(registrationCertificateFiles: updatedFiles);
                                  break;
                              }
                              
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
                            backgroundColor: Colors.deepPurple,
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
                    color: Colors.deepPurple.shade50,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.deepPurple.shade700,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PDF Document',
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
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
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.deepPurple.shade700, size: 20),
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
                        borderSide: BorderSide(color: Colors.deepPurple.shade300),
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
              onChanged: (newValue) {
                onChanged(newValue);
              },
              activeColor: Colors.deepPurple,
              activeTrackColor: Colors.deepPurple.shade100,
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