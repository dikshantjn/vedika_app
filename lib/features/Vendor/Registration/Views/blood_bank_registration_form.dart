import 'package:flutter/material.dart';

class BloodBankRegistrationForm extends StatefulWidget {
  @override
  _BloodBankRegistrationFormState createState() => _BloodBankRegistrationFormState();
}

class _BloodBankRegistrationFormState extends State<BloodBankRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String bankName = "";
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
            decoration: InputDecoration(labelText: "Blood Bank Name"),
            validator: (value) => value!.isEmpty ? "Enter blood bank name" : null,
            onChanged: (value) => bankName = value,
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
                print("Blood Bank Registration Submitted");
              }
            },
            child: Text("Register Blood Bank"),
          ),
        ],
      ),
    );
  }
}
