import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/LabSearchPage.dart';

class EnableLocationPage extends StatelessWidget {
  final String fromSource; // Added parameter to determine source

  // Constructor accepts fromSource to determine navigation behavior
  const EnableLocationPage({Key? key, required this.fromSource}) : super(key: key);

  Future<void> _enableLocation(BuildContext context) async {
    Location location = Location();

    // Check if location services are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location services are required to proceed.")),
        );
        return;
      }
    }

    // Check location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required.")),
        );
        return;
      }
    }

    // Based on the source, navigate to the correct page
    if (fromSource == 'emergency') {
      Navigator.pop(context); // Go back to the emergency dialog
    } else if (fromSource == 'ambulance') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AmbulanceSearchPage()),
      );
    } else if (fromSource == 'blood_bank') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BloodBankMapScreen()),
      );
    }
    else if (fromSource == 'hospital') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HospitalSearchPage()),
      );
    }
    else if (fromSource == 'labTest') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LabSearchPage()),
      );
    } else if (fromSource == 'clinic') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClinicSearchPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enable Location")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80, color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              "Location Access Required",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "We need your location to find the nearest service.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _enableLocation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Enable Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
