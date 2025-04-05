import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/EditAgencyProfileViewModel.dart';

class OperationalInfoSection extends StatelessWidget {
  final EditAgencyProfileViewModel viewModel;

  const OperationalInfoSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.operationalInfoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Operational Info",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(
                  controller: viewModel.numOfAmbulancesController,
                  label: "Number of Ambulances",
                  icon: Icons.local_hospital,
                  keyboardType: TextInputType.number,
                ),
                _buildSwitch("Driver KYC Completed", viewModel.driverKYC, viewModel.setDriverKYC),
                _buildSwitch("Drivers Trained", viewModel.driverTrained, viewModel.setDriverTrained),
                _buildSwitch("GPS Tracking Available", viewModel.gpsTrackingAvailable, viewModel.setGpsTrackingAvailable),
                _buildSwitch("24x7 Available", viewModel.is24x7Available, viewModel.setIs24x7Available),
                _buildSwitch("Online Payment Available", viewModel.isOnlinePaymentAvailable, viewModel.setIsOnlinePaymentAvailable),
                _buildTextField(
                  controller: viewModel.distanceLimitController,
                  label: "Distance Limit (in km)",
                  icon: Icons.route,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildChipSelector(
                  context: context,
                  label: "Ambulance Types",
                  options: viewModel.ambulanceTypeOptions,
                  selectedItems: viewModel.ambulanceTypes,
                  onChanged: viewModel.setAmbulanceTypes,
                ),
                _buildChipSelector(
                  context: context,
                  label: "Ambulance Equipment",
                  options: viewModel.equipmentOptions,
                  selectedItems: viewModel.ambulanceEquipment,
                  onChanged: viewModel.setAmbulanceEquipment,
                ),
                _buildChipSelector(
                  context: context,
                  label: "Language Proficiency",
                  options: viewModel.languageOptions,
                  selectedItems: viewModel.languageProficiency,
                  onChanged: viewModel.setLanguageProficiency,
                ),
                _buildChipSelector(
                  context: context,
                  label: "Operational Areas",
                  options: viewModel.operationalAreaOptions,
                  selectedItems: viewModel.operationalAreas,
                  onChanged: viewModel.setOperationalAreas,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AmbulanceAgencyColorPalette.secondaryTeal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: AmbulanceAgencyColorPalette.accentCyan,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  Widget _buildChipSelector({
    required BuildContext context,
    required String label,
    required List<String> options,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: options.map((option) {
              final selected = selectedItems.contains(option);
              return FilterChip(
                label: Text(option),
                selected: selected,
                onSelected: (_) {
                  if (selected) {
                    onChanged(List.from(selectedItems)..remove(option));
                  } else {
                    onChanged(List.from(selectedItems)..add(option));
                  }
                },
                selectedColor: AmbulanceAgencyColorPalette.secondaryTeal.withOpacity(0.2),
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: selected ? AmbulanceAgencyColorPalette.secondaryTeal : Colors.black87,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
