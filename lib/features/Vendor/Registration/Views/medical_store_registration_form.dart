import 'package:flutter/material.dart';

class MedicalStoreRegistrationForm extends StatefulWidget {
  @override
  _MedicalStoreRegistrationFormState createState() => _MedicalStoreRegistrationFormState();
}

class _MedicalStoreRegistrationFormState extends State<MedicalStoreRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String storeName = "";
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
            decoration: InputDecoration(labelText: "Store Name"),
            validator: (value) => value!.isEmpty ? "Enter store name" : null,
            onChanged: (value) => storeName = value,
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
                print("Medical Store Registration Submitted");
              }
            },
            child: Text("Register Medical Store"),
          ),
        ],
      ),
    );
  }
}
