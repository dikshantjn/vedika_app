import 'package:flutter/material.dart';

class AmbulanceAgencyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Agency Name: ABC Ambulance Services", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Contact Info: 123-456-7890", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Address: 123 Main St, City, Country", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add an action like editing the profile
              },
              child: Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
