import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreLocationPicker.dart';

class MedicalStoreInfoSection extends StatefulWidget {
  final MedicalStoreRegistrationViewModel viewModel;
  final VoidCallback onRegister;
  final VoidCallback onPrevious;

  const MedicalStoreInfoSection({
    Key? key,
    required this.viewModel,
    required this.onRegister,
    required this.onPrevious,
  }) : super(key: key);

  @override
  _MedicalStoreInfoSectionState createState() => _MedicalStoreInfoSectionState();
}

class _MedicalStoreInfoSectionState extends State<MedicalStoreInfoSection> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Picker at the top
              _buildLocationPicker(),
              const SizedBox(height: 20),

              _buildDropdown(
                widget.viewModel.medicineType,
                "Medicine Type",
                ["Allopathy", "Homeopathy", "Ayurvedic", "Generic"],
              ),

              _buildTextField(
                widget.viewModel.specialMedicationsController,
                "Specialized Medications Available",
                Icons.medical_services,
              ),

              _buildDropdown(
                widget.viewModel.paymentOptions,
                "Payment Options",
                ["Online", "Cash"],
              ),

              _buildChipsSelection(),
              const SizedBox(height: 20),

              UploadSectionWidget(
                label: "Upload Registration Certificates",
                onFilesSelected: (files) {
                  widget.viewModel.uploadRegistrationCertificates(files);
                },
              ),
              const SizedBox(height: 20),

              UploadSectionWidget(
                label: "Upload Compliance Certificates",
                onFilesSelected: (files) {
                  widget.viewModel.uploadComplianceCertificates(files);
                },
              ),
              const SizedBox(height: 20),

              UploadSectionWidget(
                label: "Upload Store Photos",
                onFilesSelected: (files) {
                  widget.viewModel.uploadStorePhotos(files);
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onPrevious,
                    icon: const Icon(Icons.arrow_back, color: Colors.teal, size: 28),
                    tooltip: "Go Back",
                  ),
                  ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      backgroundColor: Colors.teal,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Make Request",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
         widget.onRegister();
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  Widget _buildDropdown(
      ValueNotifier<String?> notifier,
      String label,
      List<String> options,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder<String?>(
        valueListenable: notifier,
        builder: (context, value, child) {
          return DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: (newValue) => notifier.value = newValue,
          );
        },
      ),
    );
  }

  Widget _buildChipsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Additional Facilities",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildChoiceChip(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isSelected, child) {
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (value) => notifier.value = value,
          selectedColor: Colors.teal.shade200,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Store Location",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        MedicalStoreLocationPicker(
          onLocationSelected: (location) {
            print("onLocationSelected :$location");
            widget.viewModel.getLocation.value = location;
          },
          initialLocation: widget.viewModel.getLocation.value,
        ),
      ],
    );
  }
}