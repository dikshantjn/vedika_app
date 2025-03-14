import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/hospital_registration_viewmodel.dart';

class HospitalDetailsSection extends StatefulWidget {
  final HospitalRegistrationViewModel viewModel;
  final VoidCallback onNext;

  HospitalDetailsSection({
    required this.viewModel,
    required this.onNext,
  });

  @override
  _HospitalDetailsSectionState createState() => _HospitalDetailsSectionState();
}

class _HospitalDetailsSectionState extends State<HospitalDetailsSection> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        onChanged: _validateForm, // Validate whenever form changes
        child: Column(
          children: [
            _buildTextField(widget.viewModel.hospitalNameController, "Hospital Name", Icons.local_hospital),
            _buildTextField(widget.viewModel.ownerNameController, "Owner Name", Icons.person),
            _buildTextField(widget.viewModel.contactNumberController, "Contact Number", Icons.phone,
                keyboardType: TextInputType.phone, isPhoneNumber: true),
            _buildTextField(widget.viewModel.emailController, "Email", Icons.email,
                keyboardType: TextInputType.emailAddress, isEmail: true),
            _buildTextField(widget.viewModel.websiteController, "Website", Icons.web),
            _buildTextField(widget.viewModel.licenseNumberController, "License Number", Icons.confirmation_number),
            _buildTextField(widget.viewModel.availableBedsController, "Available Beds", Icons.bed,
                keyboardType: TextInputType.number, isNumber: true),

            SizedBox(height: 20),

            /// **Next Icon Button**
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _isFormValid ? widget.onNext : null, // Disable if form is invalid
                icon: Icon(Icons.arrow_circle_right, color: _isFormValid ? Colors.teal : Colors.grey, size: 40),
                tooltip: "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// **Reusable TextField Widget with Validation**
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool isNumber = false,
        bool isPhoneNumber = false,
        bool isEmail = false,
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
          if (isPhoneNumber && !RegExp(r'^\d{10}$').hasMatch(value)) {
            return "Enter a valid 10-digit phone number";
          }
          if (isEmail && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
            return "Enter a valid email address";
          }
          if (isNumber && int.tryParse(value) == null) {
            return "Enter a valid number";
          }
          return null;
        },
      ),
    );
  }
}
