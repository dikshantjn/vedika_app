import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyLocationPicker.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';

class BloodBankRegistrationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BloodBankRegistrationViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<BloodBankRegistrationViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                // Modern Header
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 40,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bloodtype, size: 50, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              "Register Blood Bank",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context, currentPage, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index <= currentPage
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                // Form Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => _currentPage.value = index,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildBasicInfoSection(context, viewModel),
                      _buildServicesSection(context, viewModel),
                      _buildLocationSection(context, viewModel),
                      _buildDocumentsSection(context, viewModel),
                    ],
                  ),
                ),
                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (_currentPage.value > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("Previous"),
                          ),
                        ),
                      if (_currentPage.value > 0) SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.Loading
                              ? null
                              : () async {
                                  if (_currentPage.value < 3) {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        await viewModel.submitRegistration();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: viewModel.Loading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  _currentPage.value < 3 ? "Next" : "Submit Registration",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextFieldWithIcon(
              "Agency Name",
              viewModel.agencyNameController,
              Icons.business,
            ),
            _buildTextFieldWithIcon(
              "Owner Name",
              viewModel.ownerNameController,
              Icons.person,
            ),
            _buildTextFieldWithIcon(
              "Emergency Contact",
              viewModel.emergencyContactController,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildTextFieldWithIcon(
              "Email",
              viewModel.emailController,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextFieldWithIcon(
              "GST Number",
              viewModel.gstNumberController,
              Icons.receipt,
            ),
            _buildTextFieldWithIcon(
              "PAN Number",
              viewModel.panNumberController,
              Icons.credit_card,
            ),
            _buildTextFieldWithIcon(
              "Govt Registration Number",
              viewModel.govtRegNumberController,
              Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionTitle(context, "Blood Services"),
          _buildMultiSelectChips(context, viewModel.bloodOptions, viewModel.selectedBloodServices),
          SizedBox(height: 16),
          _buildSwitchTile(context, "Provides Platelets", viewModel.providesPlatelets, viewModel.togglePlatelets),
          _buildTextFieldWithIcon(
            "Other Services",
            viewModel.otherServicesController,
            Icons.medical_services,
          ),
          _buildSwitchTile(context, "Open 24/7", viewModel.is24x7, viewModel.toggle24x7),
          _buildSwitchTile(context, "Open All Days", viewModel.allDaysWorking, viewModel.toggleAllDays),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextFieldWithIcon(
            "Address",
            viewModel.addressController,
            Icons.location_on,
          ),
          _buildTextFieldWithIcon(
            "Landmark",
            viewModel.landmarkController,
            Icons.place,
          ),
          _buildDropdownWithIcon(
            "State",
            viewModel.statesList,
            viewModel.selectedState,
            Icons.map,
          ),
          _buildDropdownWithIcon(
            "City",
            viewModel.citiesList,
            viewModel.selectedCity,
            Icons.location_city,
          ),
          _buildTextFieldWithIcon(
            "Pincode",
            viewModel.pincodeController,
            Icons.pin,
            keyboardType: TextInputType.number,
          ),
          _buildTextFieldWithIcon(
            "Website",
            viewModel.websiteController,
            Icons.web,
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16),
          AmbulanceAgencyLocationPicker(
            onLocationSelected: (location) {
              viewModel.preciseLocationController.text = location;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionTitle(context, "Required Documents"),
          UploadSectionWidget(
            label: 'Upload License',
            onFilesSelected: (files) => files.forEach((fileData) =>
                viewModel.addLicenseFile(fileData['file'] as File, fileData['name'] as String)),
          ),
          UploadSectionWidget(
            label: 'Upload Certificates',
            onFilesSelected: (files) => files.forEach((fileData) =>
                viewModel.addRegistrationCertificateFile(fileData['file'] as File, fileData['name'] as String)),
          ),
          UploadSectionWidget(
            label: 'Upload Office Photos',
            onFilesSelected: (files) => files.forEach((fileData) =>
                viewModel.addOfficePhoto(fileData['file'] as File, fileData['name'] as String)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithIcon(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownWithIcon(
    String label,
    List<String> items,
    ValueNotifier<String?> selectedValue,
    IconData icon,
  ) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedValue,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: value,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (val) => selectedValue.value = val,
            validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(BuildContext context, String label, bool value, Function(bool) onChanged) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectChips(
    BuildContext context,
    List<String> options,
    ValueNotifier<List<String>> selectedListNotifier,
  ) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: selectedListNotifier,
      builder: (context, selectedList, _) {
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((item) {
            final isSelected = selectedList.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              elevation: 2,
              onSelected: (selected) {
                if (selected) {
                  selectedListNotifier.value = [...selectedList, item];
                } else {
                  selectedListNotifier.value = selectedList.where((e) => e != item).toList();
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
