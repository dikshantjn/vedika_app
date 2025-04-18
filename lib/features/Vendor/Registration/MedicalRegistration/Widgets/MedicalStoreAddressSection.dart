import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class MedicalStoreAddressSection extends StatefulWidget {
  final MedicalStoreRegistrationViewModel viewModel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MedicalStoreAddressSection({
    Key? key,
    required this.viewModel,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  _MedicalStoreAddressSectionState createState() =>
      _MedicalStoreAddressSectionState();
}

class _MedicalStoreAddressSectionState extends State<MedicalStoreAddressSection> {
  final _formKey = GlobalKey<FormState>();

  String? selectedState;
  String? selectedCity;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  Widget build(BuildContext context) {
    final stateCityData = StateCityDataProvider.states;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **Text Fields**
              _buildTextField(widget.viewModel.addressController, "Address", Icons.location_on),
              _buildTextField(widget.viewModel.landmarkController, "Nearby Landmark", Icons.map),
              _buildTextField(widget.viewModel.storeDaysController, "Store Open Days", Icons.calendar_today),
              _buildTextField(widget.viewModel.floorController, "Floor", Icons.stairs),

              /// **Store Timing (Start & End Time)**
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStartTime: true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Start Time: ${formatTime(_startTime)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStartTime: false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "End Time: ${formatTime(_endTime)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// **State Dropdown**
              _buildStateDropdown(stateCityData),

              /// **City Dropdown**
              _buildCityDropdown(),

              /// **Pincode Field**
              _buildTextField(widget.viewModel.pincodeController, "Pincode", Icons.pin, isNumber: true),

              const SizedBox(height: 20),

              /// **Navigation Buttons**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(Icons.arrow_back, widget.onPrevious),
                  _buildNavButton(Icons.arrow_forward, () {
                    if (_formKey.currentState!.validate()) {
                      widget.onNext();
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Format time to 12-hour format (AM/PM)**
  String formatTime(TimeOfDay? time) {
    if (time == null) return "Select Time";
    final now = DateTime.now();
    final formattedTime = DateFormat.jm().format(DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ));
    return formattedTime;
  }

  /// **Show Time Picker**
  Future<void> _pickTime({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
        widget.viewModel.storeTimingController.text = "${formatTime(_startTime)} - ${formatTime(_endTime)}";
        widget.viewModel.notifyListeners();
      });
    }
  }

  /// **State Dropdown**
  Widget _buildStateDropdown(List<StateModel> states) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedState,
        decoration: _inputDecoration("State", Icons.location_city),
        items: states.map((state) => DropdownMenuItem(value: state.name, child: Text(state.name))).toList(),
        onChanged: (value) {
          setState(() {
            selectedState = value;
            selectedCity = null; // Reset city when state changes
          });
          widget.viewModel.stateController.text = value ?? "";
        },
        validator: (value) => value == null ? "Please select a state" : null,
      ),
    );
  }

  /// **City Dropdown**
  Widget _buildCityDropdown() {
    final List<String> cities = selectedState != null
        ? StateCityDataProvider.getCities(selectedState!)
        : [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        decoration: _inputDecoration("City", Icons.apartment),
        items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
        onChanged: (value) {
          setState(() => selectedCity = value);
          widget.viewModel.cityController.text = value ?? "";
        },
        validator: (value) => value == null ? "Please select a city" : null,
      ),
    );
  }

  /// **Reusable TextField Widget**
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "Please enter $label";
          if (isNumber && int.tryParse(value) == null) return "Enter a valid number";
          return null;
        },
      ),
    );
  }

  /// **Reusable Navigation Button**
  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 32, color: Colors.teal),
    );
  }

  /// **Input Decoration Helper**
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }
}
