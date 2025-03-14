import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/hospital_registration_viewmodel.dart';

class HospitalAddressSection extends StatefulWidget {
  final HospitalRegistrationViewModel viewModel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  HospitalAddressSection({
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  _HospitalAddressSectionState createState() => _HospitalAddressSectionState();
}

class _HospitalAddressSectionState extends State<HospitalAddressSection> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  // Drop down selections
  String? selectedState;
  String? selectedCity;
  String? selectedDistrict;

  // Sample state, city, and district data with full state names and codes.
  Map<String, Map<String, dynamic>> stateCityData = {
    'Maharashtra': {
      'code': 'MH',
      'cities': [
        {'city': 'Mumbai', 'code': 'BOM', 'district': 'Mumbai District'},
        {'city': 'Pune', 'code': 'PNQ', 'district': 'Pune District'},
      ],
    },
    'Karnataka': {
      'code': 'KA',
      'cities': [
        {'city': 'Bangalore', 'code': 'BLR', 'district': 'Bangalore District'},
        {'city': 'Mysore', 'code': 'MYR', 'district': 'Mysore District'},
      ],
    },
    'Uttar Pradesh': {
      'code': 'UP',
      'cities': [
        {'city': 'Lucknow', 'code': 'LKO', 'district': 'Lucknow District'},
        {'city': 'Varanasi', 'code': 'VNS', 'district': 'Varanasi District'},
      ],
    },
    'Tamil Nadu': {
      'code': 'TN',
      'cities': [
        {'city': 'Chennai', 'code': 'MAA', 'district': 'Chennai District'},
        {'city': 'Coimbatore', 'code': 'CBE', 'district': 'Coimbatore District'},
      ],
    },
    'Delhi': {
      'code': 'DL',
      'cities': [
        {'city': 'New Delhi', 'code': 'NDL', 'district': 'Central Delhi District'},
        {'city': 'South Delhi', 'code': 'SD', 'district': 'South Delhi District'},
      ],
    },
    'Rajasthan': {
      'code': 'RJ',
      'cities': [
        {'city': 'Jaipur', 'code': 'JPR', 'district': 'Jaipur District'},
        {'city': 'Udaipur', 'code': 'UDR', 'district': 'Udaipur District'},
      ],
    },
    'Punjab': {
      'code': 'PB',
      'cities': [
        {'city': 'Chandigarh', 'code': 'CHD', 'district': 'Chandigarh District'},
        {'city': 'Amritsar', 'code': 'ASR', 'district': 'Amritsar District'},
      ],
    },
    'Haryana': {
      'code': 'HR',
      'cities': [
        {'city': 'Gurugram', 'code': 'GRM', 'district': 'Gurugram District'},
        {'city': 'Faridabad', 'code': 'FDB', 'district': 'Faridabad District'},
      ],
    },
    'West Bengal': {
      'code': 'WB',
      'cities': [
        {'city': 'Kolkata', 'code': 'KOL', 'district': 'Kolkata District'},
        {'city': 'Durgapur', 'code': 'DGP', 'district': 'Durgapur District'},
      ],
    },
    'Gujarat': {
      'code': 'GJ',
      'cities': [
        {'city': 'Ahmedabad', 'code': 'AMD', 'district': 'Ahmedabad District'},
        {'city': 'Surat', 'code': 'SUR', 'district': 'Surat District'},
      ],
    },
    'Kerala': {
      'code': 'KL',
      'cities': [
        {'city': 'Thiruvananthapuram', 'code': 'TRV', 'district': 'Thiruvananthapuram District'},
        {'city': 'Kochi', 'code': 'COK', 'district': 'Ernakulam District'},
      ],
    },
  };

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _validateForm, // Validate on input change
      child: Column(
        children: [
          _buildStateDropdown(),
          _buildCityDropdown(),
          _buildTextField(widget.viewModel.pincodeController, "Pincode", Icons.pin,
              keyboardType: TextInputType.number),
          _buildTextField(widget.viewModel.addressController, "Address", Icons.location_on),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onPrevious,
                icon: Icon(Icons.arrow_circle_left, color: Colors.teal, size: 40),
                tooltip: "Previous",
              ),
              IconButton(
                onPressed: _isFormValid ? widget.onNext : null, // Disable if invalid
                icon: Icon(Icons.arrow_circle_right, color: _isFormValid ? Colors.teal : Colors.grey, size: 40),
                tooltip: "Next",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // State Dropdown
  Widget _buildStateDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedState,
        hint: Text('Select State'),
        icon: Icon(Icons.map, color: Colors.teal),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: stateCityData.keys.map((stateCode) {
          return DropdownMenuItem<String>(
            value: stateCode,
            child: Text(stateCode),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedState = newValue;
            selectedCity = null; // Reset city when state changes
            selectedDistrict = null; // Reset district when state changes
          });
        },
        validator: (value) => value == null ? "Please select a state" : null,
      ),
    );
  }

  // City Dropdown based on selected State
  Widget _buildCityDropdown() {
    if (selectedState == null) {
      return Container(); // Return an empty widget if no state is selected
    }

    List<Map<String, String>> cities = stateCityData[selectedState]?['cities'] ?? [];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        hint: Text('Select City'),
        icon: Icon(Icons.location_city, color: Colors.teal),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: cities.map((cityData) {
          return DropdownMenuItem<String>(
            value: cityData['code'],
            child: Text('${cityData['city']}'),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedCity = newValue;
            selectedDistrict = null; // Reset district when city changes
          });
        },
        validator: (value) => value == null ? "Please select a city" : null,
      ),
    );
  }

  // **Reusable TextField Widget with Validation**
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }
}
