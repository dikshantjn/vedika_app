import 'package:flutter/material.dart';

class AmbulanceAgencyRegistrationForm extends StatefulWidget {
  @override
  _AmbulanceAgencyRegistrationFormState createState() => _AmbulanceAgencyRegistrationFormState();
}

class _AmbulanceAgencyRegistrationFormState extends State<AmbulanceAgencyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String agencyName = "";
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
            decoration: InputDecoration(labelText: "Agency Name"),
            validator: (value) => value!.isEmpty ? "Enter agency name" : null,
            onChanged: (value) => agencyName = value,
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
                print("Ambulance Agency Registration Submitted");
              }
            },
            child: Text("Register Ambulance Agency"),
          ),
        ],
      ),
    );
  }
}
