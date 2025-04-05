import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReadOnlyLocationMap extends StatelessWidget {
  final String location; // Ex: "18.4888584, 73.867546"

  const ReadOnlyLocationMap({
    Key? key,
    required this.location,
  }) : super(key: key);

  LatLng _parseLocation(String locationString) {
    final parts = locationString.split(',');
    final lat = double.tryParse(parts[0].trim()) ?? 0.0;
    final lng = double.tryParse(parts[1].trim()) ?? 0.0;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng parsedLocation = _parseLocation(location);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: parsedLocation,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('readonlyMarker'),
              position: parsedLocation,
              infoWindow: const InfoWindow(title: "Selected Location"),
            ),
          },
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          onMapCreated: (controller) {},
        ),
      ),
    );
  }
}
