import 'package:flutter/material.dart';

class ClinicRegistrationForm extends StatefulWidget {
  @override
  _ClinicRegistrationFormState createState() => _ClinicRegistrationFormState();
}

class _ClinicRegistrationFormState extends State<ClinicRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String clinicName = "";
  String address = "";
  String contactNumber = "";
  String licenseNumber = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Clinic Name"),
            validator: (value) => value!.isEmpty ? "Enter clinic name" : null,
            onChanged: (value) => clinicName = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Address"),
            validator: (value) => value!.isEmpty ? "Enter address" : null,
            onChanged: (value) => address = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Contact Number"),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? "Enter contact number" : null,
            onChanged: (value) => contactNumber = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "License Number"),
            validator: (value) => value!.isEmpty ? "Enter license number" : null,
            onChanged: (value) => licenseNumber = value,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print("Clinic Registration Submitted");
              }
            },
            child: Text("Register Clinic"),
          ),
        ],
      ),
    );
  }
}


