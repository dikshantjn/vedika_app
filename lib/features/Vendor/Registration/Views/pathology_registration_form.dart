import 'package:flutter/material.dart';

class PathologyRegistrationForm extends StatefulWidget {
  @override
  _PathologyRegistrationFormState createState() => _PathologyRegistrationFormState();
}

class _PathologyRegistrationFormState extends State<PathologyRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String pathologyName = "";
  String address = "";
  String contactNumber = "";
  String licenseNumber = "";
  List<String> testsOffered = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Pathology Name"),
            validator: (value) => value!.isEmpty ? "Enter pathology name" : null,
            onChanged: (value) => pathologyName = value,
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
          TextFormField(
            decoration: InputDecoration(labelText: "Tests Offered (comma separated)"),
            onChanged: (value) => testsOffered = value.split(',').map((e) => e.trim()).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print("Pathology Registration Submitted");
              }
            },
            child: Text("Register Pathology"),
          ),
        ],
      ),
    );
  }
}
