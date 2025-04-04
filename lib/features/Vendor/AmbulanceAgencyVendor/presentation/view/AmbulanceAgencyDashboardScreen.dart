import 'package:flutter/material.dart';

class AmbulanceAgencyDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agency Dashboard")),
      body: Center(
        child: Text(
          'This is Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
