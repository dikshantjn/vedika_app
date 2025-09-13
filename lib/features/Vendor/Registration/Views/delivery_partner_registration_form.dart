import 'package:flutter/material.dart';

class DeliveryPartnerRegistrationForm extends StatefulWidget {
  @override
  _DeliveryPartnerRegistrationFormState createState() => _DeliveryPartnerRegistrationFormState();
}

class _DeliveryPartnerRegistrationFormState extends State<DeliveryPartnerRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String fullName = "";
  String contactNumber = "";
  String vehicleType = "";
  String licenseNumber = "";
  String city = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Full Name"),
              validator: (value) => value!.isEmpty ? "Enter full name" : null,
              onChanged: (value) => fullName = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Contact Number"),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? "Enter contact number" : null,
              onChanged: (value) => contactNumber = value,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Vehicle Type"),
              items: ["Bike", "Car", "Van"]
                  .map((vehicle) => DropdownMenuItem(value: vehicle, child: Text(vehicle)))
                  .toList(),
              onChanged: (value) => setState(() => vehicleType = value!),
              validator: (value) => value == null ? "Select a vehicle type" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "License Number"),
              validator: (value) => value!.isEmpty ? "Enter license number" : null,
              onChanged: (value) => licenseNumber = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "City"),
              validator: (value) => value!.isEmpty ? "Enter city" : null,
              onChanged: (value) => city = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print("Delivery Partner Registration Submitted");
                }
              },
              child: Text("Register as Delivery Partner"),
            ),
          ],
        ),
      ),
    );
  }
}
