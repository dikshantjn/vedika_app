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
                                    // Validate all form sections
                                    bool isBasicInfoValid = true;
                                    List<String> basicInfoErrors = [];
                                    
                                    // Manually validate each basic info field
                                    if (viewModel.agencyNameController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('Agency Name');
                                    }
                                    if (viewModel.ownerNameController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('Owner Name');
                                    }
                                    if (viewModel.phoneNumberController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('Contact Number');
                                    }
                                    if (viewModel.emailController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('Email');
                                    }
                                    if (viewModel.gstNumberController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('GST Number');
                                    }
                                    if (viewModel.panNumberController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('PAN Number');
                                    }
                                    if (viewModel.govtRegNumberController.text.isEmpty) {
                                      isBasicInfoValid = false;
                                      basicInfoErrors.add('Govt Registration Number');
                                    }

                                    bool isServicesValid = viewModel.selectedBloodServices.value.isNotEmpty &&
                                        viewModel.selectedLanguages.value.isNotEmpty &&
                                        viewModel.operationalAreas.value.isNotEmpty;
                                        
                                    bool isLocationValid = viewModel.selectedState.value != null &&
                                        viewModel.selectedCity.value != null &&
                                        viewModel.addressController.text.isNotEmpty &&
                                        viewModel.landmarkController.text.isNotEmpty &&
                                        viewModel.pincodeController.text.isNotEmpty;

                                    print('\nValidation Results:');
                                    print('Basic Info Valid: $isBasicInfoValid');
                                    print('Basic Info Errors: $basicInfoErrors');
                                    print('Services Valid: $isServicesValid');
                                    print('Location Valid: $isLocationValid');
                                    
                                    // Detailed validation messages
                                    List<String> missingFields = [];
                                    
                                    if (!isBasicInfoValid) {
                                      missingFields.addAll(basicInfoErrors);
                                    }
                                    
                                    if (!isServicesValid) {
                                      if (viewModel.selectedBloodServices.value.isEmpty) missingFields.add('Blood Services');
                                      if (viewModel.selectedLanguages.value.isEmpty) missingFields.add('Languages');
                                      if (viewModel.operationalAreas.value.isEmpty) missingFields.add('Operational Areas');
                                    }
                                    
                                    if (!isLocationValid) {
                                      if (viewModel.selectedState.value == null) missingFields.add('State');
                                      if (viewModel.selectedCity.value == null) missingFields.add('City');
                                      if (viewModel.addressController.text.isEmpty) missingFields.add('Address');
                                      if (viewModel.landmarkController.text.isEmpty) missingFields.add('Landmark');
                                      if (viewModel.pincodeController.text.isEmpty) missingFields.add('Pincode');
                                    }
                                    
                                    print('Missing Fields: $missingFields');
                                    print('=====================');

                                    if (isBasicInfoValid && isServicesValid && isLocationValid) {
                                      try {
                                        await viewModel.submitRegistration(context);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Please fill: ${missingFields.join(", ")}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            _buildTextFieldWithIcon(
              "Agency Name",
              viewModel.agencyNameController,
              Icons.business,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "Owner Name",
              viewModel.ownerNameController,
              Icons.person,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "Contact Number",
              viewModel.phoneNumberController,
              Icons.phone,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "Email",
              viewModel.emailController,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "GST Number",
              viewModel.gstNumberController,
              Icons.receipt,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "PAN Number",
              viewModel.panNumberController,
              Icons.credit_card,
              isRequired: true,
            ),
            _buildTextFieldWithIcon(
              "Govt Registration Number",
              viewModel.govtRegNumberController,
              Icons.description,
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    final TextEditingController operationalAreaController = TextEditingController();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
      child: Column(
        children: [
          _buildSectionTitle(context, "Blood Services"),
          ValueListenableBuilder<List<String>>(
            valueListenable: viewModel.selectedBloodServices,
            builder: (context, selectedServices, _) {
              return Column(
                children: [
                  if (selectedServices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Please select at least one blood service",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.bloodOptions.map((service) {
                      final isSelected = selectedServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        elevation: 2,
                        onSelected: (selected) {
                          if (selected) {
                            viewModel.updateBloodServices(service, true);
                          } else {
                            viewModel.updateBloodServices(service, false);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          _buildTextFieldWithIcon(
            "Distance Limit (km)",
            viewModel.distanceLimitController,
            Icons.directions,
            keyboardType: TextInputType.number,
            isRequired: true,
          ),
          _buildSectionTitle(context, "Languages"),
          ValueListenableBuilder<List<String>>(
            valueListenable: viewModel.selectedLanguages,
            builder: (context, selectedLanguages, _) {
              return Column(
                children: [
                  if (selectedLanguages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Please select at least one language",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.languages.map((language) {
                      final isSelected = selectedLanguages.contains(language);
                      return FilterChip(
                        label: Text(language),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        elevation: 2,
                        onSelected: (selected) {
                          if (selected) {
                            viewModel.updateLanguages(language, true);
                          } else {
                            viewModel.updateLanguages(language, false);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          _buildSectionTitle(context, "Operational Areas"),
          ValueListenableBuilder<List<String>>(
            valueListenable: viewModel.operationalAreas,
            builder: (context, areas, _) {
              return Column(
                children: [
                  if (areas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        "Please add at least one operational area",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: operationalAreaController,
                      decoration: InputDecoration(
                        labelText: "Add Operational Area",
                        prefixIcon: Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                          onPressed: () {
                            if (operationalAreaController.text.isNotEmpty) {
                              viewModel.addOperationalArea(operationalAreaController.text);
                              operationalAreaController.clear();
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          viewModel.addOperationalArea(value);
                          operationalAreaController.clear();
                        }
                      },
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: areas.map((area) {
                      return Chip(
                        label: Text(area),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () => viewModel.removeOperationalArea(area),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          _buildSwitchTile(context, "Provides Platelets", viewModel.providesPlatelets, viewModel.togglePlatelets),
          _buildTextFieldWithIcon(
            "Other Services",
            viewModel.otherServicesController,
            Icons.medical_services,
          ),
          _buildSwitchTile(context, "Open 24/7", viewModel.is24x7, viewModel.toggle24x7),
          _buildSwitchTile(context, "Open All Days", viewModel.allDaysWorking, viewModel.toggleAllDays),
          _buildSwitchTile(context, "Accepts Online Payment", viewModel.acceptsOnlinePayment, viewModel.toggleOnlinePayment),
        ],
      ),
    ));
  }

  Widget _buildLocationSection(BuildContext context, BloodBankRegistrationViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
      child: Column(
        children: [
          _buildTextFieldWithIcon(
            "Address",
            viewModel.addressController,
            Icons.location_on,
              isRequired: true,
          ),
          _buildTextFieldWithIcon(
            "Landmark",
            viewModel.landmarkController,
            Icons.place,
              isRequired: true,
          ),
          _buildDropdownWithIcon(
            "State",
            viewModel.statesList,
            viewModel.selectedState,
            Icons.map,
              isRequired: true,
          ),
          _buildDropdownWithIcon(
            "City",
            viewModel.citiesList,
            viewModel.selectedCity,
            Icons.location_city,
              isRequired: true,
          ),
          _buildTextFieldWithIcon(
            "Pincode",
            viewModel.pincodeController,
            Icons.pin,
            keyboardType: TextInputType.number,
              isRequired: true,
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
    Function(String)? onSubmitted,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownWithIcon(
    String label,
    List<String> items,
    ValueNotifier<String?> selectedValue,
    IconData icon, {
    bool isRequired = false,
  }) {
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
            validator: (val) {
              if (isRequired && (val == null || val.isEmpty)) {
                return 'Please select $label';
              }
              return null;
            },
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
