import 'package:flutter/material.dart';

class PatientDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PatientDetailsForm({Key? key, required this.formKey}) : super(key: key);

  @override
  _PatientDetailsFormState createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  String? _selectedGender;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient Details Form",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),

            // Full Name Field
            _buildTextField("Full Name", controller: _nameController),

            // Age and Gender Fields in one row
            Row(
              children: [
                // Age Field
                Expanded(
                  child: _buildTextField("Age",
                      controller: _ageController, isAgeField: true),
                ),
                SizedBox(width: 10),
                // Gender Field
                Expanded(
                  child: _buildGenderDropdown(),
                ),
              ],
            ),

            // Phone Number Field
            _buildTextField("Contact Number", controller: _phoneController, isPhoneNumber: true),

            // Address Field
            _buildTextField("Address", controller: _addressController),
          ],
        ),
      ),
    );
  }

  // Custom text field with validation
  Widget _buildTextField(String label,
      {bool isAgeField = false, bool isPhoneNumber = false, required TextEditingController controller}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isAgeField || isPhoneNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12), // Improved spacing
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (isAgeField) {
            int? age = int.tryParse(value);
            if (age == null || age <= 0 || age > 120) {
              return "Enter a valid age";
            }
          }
          if (isPhoneNumber) {
            if (value.length != 10 || int.tryParse(value) == null) {
              return "Enter a valid 10-digit Contact number";
            }
          }
          return null;
        },
      ),
    );
  }


  // Gender dropdown widget
  Widget _buildGenderDropdown() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        isExpanded: true, // This prevents overflow by making dropdown fill available space
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) => value == null ? "Please select a gender" : null,
        items: <String>['Male', 'Female', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }
}
