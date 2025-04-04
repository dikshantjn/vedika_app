import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class AmbulanceDetailsSection extends StatefulWidget {
  @override
  _AmbulanceDetailsSectionState createState() => _AmbulanceDetailsSectionState();
}

class _AmbulanceDetailsSectionState extends State<AmbulanceDetailsSection> {
  final _formKey = GlobalKey<FormState>();

  final List<String> ambulanceTypes = [
    'Basic Life Support (BLS)',
    'Advanced Life Support (ALS)',
    'Neonatal Ambulance',
    'Air Ambulance',
    'Mortuary Van'
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AmbulanceAgencyViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // State Dropdown
            _buildDropdownField(
              label: 'Select State',
              controller: viewModel.stateController,
              items: StateCityDataProvider.states.map((state) => state.name).toList(),
              onChanged: (value) {
                setState(() {
                  viewModel.stateController.text = value ?? "";
                  viewModel.cityController.text = "";
                });
              },
            ),

            SizedBox(height: 16),

            // City Dropdown
            _buildDropdownField(
              label: 'Select City',
              controller: viewModel.cityController,
              items: viewModel.stateController.text.isNotEmpty
                  ? StateCityDataProvider.getCities(viewModel.stateController.text)
                  : [],
              onChanged: (value) {
                setState(() {
                  viewModel.cityController.text = value ?? "";
                });
              },
            ),

            SizedBox(height: 16),

            _buildTextField(label: 'Address', controller: viewModel.addressController),  // Added Address Field
            _buildTextField(label: 'Landmark', controller: viewModel.landmarkController), // Added Landmark Field
            _buildTextField(label: 'Pincode', controller: viewModel.pinCodeController, keyboardType: TextInputType.number),
            _buildTextField(label: 'Number of Ambulances', controller: viewModel.numOfAmbulancesController, keyboardType: TextInputType.number),
            _buildTextField(label: 'Driver License Number', controller: viewModel.driverLicenseController),

            _buildCustomSwitch(title: 'Driver KYC Completed', value: viewModel.driverKYC, field: 'driverKYC', viewModel: viewModel),
            _buildCustomSwitch(title: 'Driver Trained for Emergency Situations', value: viewModel.driverTrained, field: 'driverTrained', viewModel: viewModel),

            SizedBox(height: 12),

            _buildMultiSelect(viewModel),

            SizedBox(height: 12),

            _buildCustomSwitch(title: 'GPS Tracking Available', value: viewModel.gpsTrackingAvailable, field: 'gpsTrackingAvailable', viewModel: viewModel),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
        validator: (value) => (value == null || value.isEmpty) ? '$label is required' : null,
      ),
    );
  }

  Widget _buildDropdownField({required String label, required TextEditingController controller, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: items.contains(controller.text) ? controller.text : null,
      decoration: _inputDecoration(label),
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => (value == null || value.isEmpty) ? 'Please select $label' : null,
    );
  }

  Widget _buildCustomSwitch({required String title, required bool value, required String field, required AmbulanceAgencyViewModel viewModel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: (newValue) => viewModel.updateBooleanField(field, newValue),
              activeColor: Colors.green,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(AmbulanceAgencyViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Ambulance Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ambulanceTypes.map((type) {
            bool isSelected = viewModel.ambulanceTypes.contains(type);

            return ChoiceChip(
              label: Text(type, style: TextStyle(fontSize: 14)),
              selected: isSelected,
              selectedColor: Colors.green.shade600,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? Colors.green : Colors.grey.shade400),
              ),
              onSelected: (selected) {
                List<String> updatedList = List.from(viewModel.ambulanceTypes);
                selected ? updatedList.add(type) : updatedList.remove(type);
                viewModel.updateListField('ambulanceTypes', updatedList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
