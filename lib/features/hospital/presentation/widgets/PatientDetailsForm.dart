import 'package:flutter/material.dart';

class PatientDetailsForm extends StatefulWidget {
  @override
  _PatientDetailsFormState createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Removed the shadow for a clean look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Smooth rounded corners
      color: Colors.white, // Set the background of the card to white
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding for better spacing
        child: SingleChildScrollView( // Make the form scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal[800])),
              SizedBox(height: 20), // Increased spacing between title and fields

              // Name Field
              _buildTextField(nameController, "Patient Name", TextInputType.text),

              SizedBox(height: 15), // Increased spacing between fields

              // Age & Gender Row
              Row(
                children: [
                  // Age Field
                  Expanded(
                    child: _buildTextField(ageController, "Age", TextInputType.number),
                  ),
                  SizedBox(width: 15),

                  // Gender Dropdown
                  Container(
                    width: 150, // Set a max width to prevent overflow
                    child: _buildDropdownField(),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Contact Number Field
              _buildTextField(contactController, "Contact Number", TextInputType.phone),
            ],
          ),
        ),
      ),
    );
  }

  // TextField Widget with modern styling
  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white, // Set the background of input fields to white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12), // Spacing inside input field
      ),
    );
  }

  // Dropdown for Gender Selection with modern styling
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Gender",
        labelStyle: TextStyle(color: Colors.teal),
        filled: true,
        fillColor: Colors.white, // Set the background of dropdown to white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      value: selectedGender,
      hint: Text("Select Gender", style: TextStyle(color: Colors.black)), // Set placeholder color to black
      style: TextStyle(fontSize: 14, color: Colors.black), // Ensure the selected value is black
      onChanged: (value) => setState(() => selectedGender = value),
      items: ["Male", "Female", "Other"].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender, style: TextStyle(color: Colors.black))); // Ensure text color is black
      }).toList(),
    );
  }
}
