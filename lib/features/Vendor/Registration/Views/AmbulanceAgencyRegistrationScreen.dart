import 'package:flutter/material.dart';

class AmbulanceAgencyRegistrationScreen extends StatefulWidget {
  @override
  _AmbulanceAgencyRegistrationScreenState createState() =>
      _AmbulanceAgencyRegistrationScreenState();
}

class _AmbulanceAgencyRegistrationScreenState
    extends State<AmbulanceAgencyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String agencyName = "";
  String address = "";
  String contactNumber = "";
  String licenseNumber = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back action here
        Navigator.pop(context); // Go back to the previous screen
        return true; // Allow the back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Ambulance Agency Registration"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height, // Limit the height
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "Agency Name"),
                    validator: (value) =>
                    value!.isEmpty ? "Enter agency name" : null,
                    onChanged: (value) => agencyName = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Address"),
                    validator: (value) =>
                    value!.isEmpty ? "Enter address" : null,
                    onChanged: (value) => address = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Contact Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    value!.isEmpty ? "Enter contact number" : null,
                    onChanged: (value) => contactNumber = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "License Number"),
                    validator: (value) =>
                    value!.isEmpty ? "Enter license number" : null,
                    onChanged: (value) => licenseNumber = value,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Ambulance Agency Registered Successfully!")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text("Register Ambulance Agency"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
