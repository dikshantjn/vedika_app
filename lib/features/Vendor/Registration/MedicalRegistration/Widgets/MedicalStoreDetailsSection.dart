import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';

class MedicalStoreDetailsSection extends StatefulWidget {
  final MedicalStoreRegistrationViewModel viewModel;
  final VoidCallback onNext;

  MedicalStoreDetailsSection({required this.viewModel, required this.onNext});

  @override
  _MedicalStoreDetailsSectionState createState() => _MedicalStoreDetailsSectionState();
}

class _MedicalStoreDetailsSectionState extends State<MedicalStoreDetailsSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(widget.viewModel.storeNameController, "Medical Store Name", Icons.store),
            _buildTextField(widget.viewModel.gstNumberController, "GST Number", Icons.confirmation_number),
            _buildTextField(widget.viewModel.panNumberController, "PAN Number", Icons.credit_card),
            _buildTextField(widget.viewModel.emailController, "Email Address", Icons.email, isEmail: true),
            _buildTextField(widget.viewModel.contactNumberController, "Phone Number", Icons.phone, isNumber: true),
            _buildTextField(widget.viewModel.ownerNameController, "Owner Name", Icons.person, isNumber: false),
            _buildTextField(widget.viewModel.licenseNumberController, "License Number", Icons.card_membership), // Added License Number field

            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) widget.onNext();
                },
                icon: Icon(Icons.arrow_forward_rounded, size: 32, color: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
        bool isEmail = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Please enter $label";
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
          if (isNumber && value.length < 10) return "Enter a valid phone number";
          return null;
        },
      ),
    );
  }
}
