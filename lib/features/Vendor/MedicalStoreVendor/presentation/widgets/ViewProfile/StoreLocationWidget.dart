import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreLocationWidget extends StatelessWidget {
  final String locationString;

  const StoreLocationWidget({super.key, required this.locationString});

  @override
  Widget build(BuildContext context) {
    // Parse latitude and longitude from location string
    List<String> latLng = locationString.split(",");
    double latitude = double.tryParse(latLng[0]) ?? 0.0;
    double longitude = double.tryParse(latLng[1]) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("storeLocation"),
                      position: LatLng(latitude, longitude),
                      infoWindow: const InfoWindow(title: 'Store Location'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Default icon for directions
                    ),
                  },
                  zoomControlsEnabled: true,
                ),
              ),
              Positioned(
                top: 10, // Move the icon to the top
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: () => _openGoogleMaps(latitude, longitude),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUri =
    Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not open Google Maps");
    }
  }
}
