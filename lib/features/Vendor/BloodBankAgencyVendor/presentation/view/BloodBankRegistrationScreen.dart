import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyLocationPicker.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';

class BloodBankRegistrationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BloodBankRegistrationViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, title: Text("Register Blood Bank")),
        body: Consumer<BloodBankRegistrationViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    section([
                      buildTextField("Agency Name", viewModel.agencyNameController),
                      buildTextField("Owner Name", viewModel.ownerNameController),
                      buildNumberField("Emergency Contact", viewModel.emergencyContactController),
                      buildTextField("Email", viewModel.emailController),
                      buildTextField("GST Number", viewModel.gstNumberController),
                      buildTextField("PAN Number", viewModel.panNumberController),
                      buildTextField("Govt Registration Number", viewModel.govtRegNumberController),
                    ]),
                    section([
                      buildMultiSelectChips("Blood Services", viewModel.bloodOptions, viewModel.selectedBloodServices),
                      buildSwitch("Provides Platelets", viewModel.providesPlatelets, viewModel.togglePlatelets),
                      buildTextField("Other Services", viewModel.otherServicesController),
                      buildSwitch("Open 24/7", viewModel.is24x7, viewModel.toggle24x7),
                      buildSwitch("Open All Days", viewModel.allDaysWorking, viewModel.toggleAllDays),
                    ]),
                    section([
                      buildTextField("Address", viewModel.addressController),
                      buildTextField("Landmark", viewModel.landmarkController),
                      buildDropdown("State",viewModel.statesList, viewModel.selectedState),
                      buildDropdown("City", viewModel.citiesList, viewModel.selectedCity),
                      buildNumberField("Pincode", viewModel.pincodeController),
                      buildTextField("Website", viewModel.websiteController),
                    ]),
                    section([
                      buildMultiSelectChips("Languages", viewModel.languages, viewModel.selectedLanguages),
                      buildChipInputField(
                        label: "Operational Areas",
                        chipList: viewModel.operationalAreas.value,
                        onAddChip: viewModel.addOperationalArea,
                        onRemoveChip: viewModel.removeOperationalArea,
                      ),
                      buildNumberField("Distance Limit (in KM)", viewModel.distanceLimitController),
                      buildSwitch("Accepts Online Payment", viewModel.acceptsOnlinePayment, viewModel.toggleOnlinePayment),
                    ]),
                    section([
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
                            viewModel.addOfficePhoto(fileData['file'] as File, fileData['name'] as String,)),
                      ),
                    ]),
                    section([
                      AmbulanceAgencyLocationPicker(
                        onLocationSelected: (location) {
                          viewModel.preciseLocationController.text = location;
                        },
                      ),
                    ]),
                    SizedBox(height: 24),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Theme.of(context).primaryColor,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: viewModel.Loading
                            ? null
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await viewModel.submitRegistration();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                            }
                          }
                        },
                        child: viewModel.Loading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple),
                            ),
                            SizedBox(width: 10),
                            Text("Submitting...",
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                          ],
                        )
                            : Text("Register Blood Bank"),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget section(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...children,
        Divider(height: 32, thickness: 1.2, color: Colors.grey[300]),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, ValueNotifier<String?> selectedValue) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedValue,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: value,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (val) {
              selectedValue.value = val;
            },
            validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
          ),
        );
      },
    );
  }

  Widget buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget buildMultiSelectChips(String label, List<String> options, ValueNotifier<List<String>> selectedListNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder<List<String>>(
        valueListenable: selectedListNotifier,
        builder: (context, selectedList, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: options.map((item) {
                  final isSelected = selectedList.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade700,
                    elevation: 4,
                    onSelected: (selected) {
                      if (selected) {
                        selectedListNotifier.value = [...selectedList, item];
                      } else {
                        selectedListNotifier.value = selectedList.where((e) => e != item).toList();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildChipInputField({
    required String label,
    required List<String> chipList,
    required Function(String) onAddChip,
    required Function(String) onRemoveChip,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final chipController = TextEditingController();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: chipList.map((chip) {
                  return InputChip(
                    label: Text(chip),
                    onDeleted: () {
                      onRemoveChip(chip);
                      setState(() {});
                    },
                    elevation: 2,
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: chipController,
                decoration: InputDecoration(
                  labelText: 'Add $label',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final chip = chipController.text.trim();
                      if (chip.isNotEmpty && !chipList.contains(chip)) {
                        onAddChip(chip);
                        setState(() {});
                        chipController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
