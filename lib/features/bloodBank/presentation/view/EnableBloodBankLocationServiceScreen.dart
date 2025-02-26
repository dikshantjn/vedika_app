import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class EnableBloodBankLocationServiceScreen extends StatefulWidget {
  @override
  _EnableBloodBankLocationServiceScreenState createState() =>
      _EnableBloodBankLocationServiceScreenState();
}

class _EnableBloodBankLocationServiceScreenState extends State<EnableBloodBankLocationServiceScreen> {
  bool _isLoading = false; // Track loading state

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

    Navigator.pushReplacementNamed(context, AppRoutes.bloodBank);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enable Location"),
        backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 100,
              color: ColorPalette.bloodBankColor,
            ),
            const SizedBox(height: 20),
            const Text(
              "Location Access Required",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "To find nearby blood banks, we need access to your location. Please enable location services.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _enableLocation(context), // ✅ Fix: Wrap inside anonymous function
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.bloodBankColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Enable Location", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
