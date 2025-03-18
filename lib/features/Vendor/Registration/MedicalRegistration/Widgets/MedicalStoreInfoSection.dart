import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/MedicalStoreRegistration.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/Profile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/View/medical_store_registration.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';

class MedicalStoreInfoSection extends StatefulWidget {
  final MedicalStoreRegistrationViewModel viewModel;
  final VoidCallback onRegister;
  final VoidCallback onPrevious;

  MedicalStoreInfoSection({
    required this.viewModel,
    required this.onRegister,
    required this.onPrevious,
  });

  @override
  _MedicalStoreInfoSectionState createState() =>
      _MedicalStoreInfoSectionState();
}

class _MedicalStoreInfoSectionState extends State<MedicalStoreInfoSection> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Track the loading state

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(widget.viewModel.medicineType, "Medicine Type",
                  ["Allopathy", "Homeopathy", "Ayurvedic", "Generic"]),
              _buildTextField(widget.viewModel.specialMedicationsController,
                  "Specialized Medications Available", Icons.medical_services),
              _buildDropdown(widget.viewModel.paymentOptions, "Payment Options",
                  ["Online", "Cash"]),
              _buildChipsSelection(),

              SizedBox(height: 20),

              // Reuse UploadSectionWidget for Registration Certificates
              UploadSectionWidget(
                label: "Upload Registration Certificates",
                onFilesSelected: (files) {
                  widget.viewModel.uploadRegistrationCertificates(files);
                },
              ),

              SizedBox(height: 20),

              // Reuse UploadSectionWidget for Compliance Certificates
              UploadSectionWidget(
                label: "Upload Compliance Certificates",
                onFilesSelected: (files) {
                  widget.viewModel.uploadComplianceCertificates(files);
                },
              ),

              SizedBox(height: 20),

              // Reuse UploadSectionWidget for Store Photos
              UploadSectionWidget(
                label: "Upload Store Photos",
                onFilesSelected: (files) {
                  widget.viewModel.uploadStorePhotos(files);
                },
              ),

              SizedBox(height: 20),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onPrevious,
                    icon: Icon(Icons.arrow_back, color: Colors.teal, size: 28),
                    tooltip: "Go Back",
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true; // Show loading indicator
                        });

                        // Call the onRegister callback passed from the parent without await
                        widget.onRegister();

                        setState(() {
                          isLoading = false; // Hide loading indicator
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      backgroundColor: Colors.teal,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading) CircularProgressIndicator(color: Colors.white),
                        if (!isLoading) ...[
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Make Request",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// **Dropdown Field**
  Widget _buildDropdown(
      ValueNotifier<String?> notifier, String label, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: options
                .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (newValue) => notifier.value = newValue!,
          );
        },
      ),
    );
  }

  /// **Chips for Selection**
  Widget _buildChipsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additional Facilities",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: [
            _buildChoiceChip("Lift Access", widget.viewModel.isLiftAccess),
            _buildChoiceChip("Wheelchair Access", widget.viewModel.isWheelchairAccess),
            _buildChoiceChip("Parking Available", widget.viewModel.isParkingAvailable),
          ],
        ),
      ],
    );
  }

  /// **Choice Chip Widget**
  Widget _buildChoiceChip(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isSelected, child) {
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (value) => notifier.value = value,
          selectedColor: Colors.teal.shade200,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      },
    );
  }

  /// **TextField**
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
