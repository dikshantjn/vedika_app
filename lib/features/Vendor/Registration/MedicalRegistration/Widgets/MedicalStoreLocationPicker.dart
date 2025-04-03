import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MedicalStoreLocationPicker extends StatefulWidget {
  final Function(String) onLocationSelected;
  final String? initialLocation;

  const MedicalStoreLocationPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  _MedicalStoreLocationPickerState createState() => _MedicalStoreLocationPickerState();
}

class _MedicalStoreLocationPickerState extends State<MedicalStoreLocationPicker> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _currentLocation = const LatLng(18.5204, 73.8567);
  final Set<Marker> _markers = {};
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      await _setInitialLocation(widget.initialLocation!);
    } else {
      _setDefaultMarker();
    }
  }

  Future<void> _setInitialLocation(String location) async {
    try {
      final parts = location.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        await _updateLocation(LatLng(lat, lng), "Saved Location");
      }
    } catch (e) {
      debugPrint("Error parsing location: $e");
      _setDefaultMarker();
    }
  }

  void _setDefaultMarker() {
    _updateLocation(_currentLocation, "Default Location");
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        final serviceRequest = await _location.requestService();
        if (!serviceRequest) return;
      }

      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        await _updateLocation(
          LatLng(locationData.latitude!, locationData.longitude!),
          "Current Location",
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation(LatLng position, String title) async {
    if (!mounted) return;

    setState(() {
      _currentLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selectedLocation"),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      );
      _locationController.text = "${position.latitude}, ${position.longitude}";
    });

    widget.onLocationSelected(_locationController.text);

    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: "Latitude, Longitude",
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _locationController.clear();
                  _setDefaultMarker();
                },
              ),
            ),
            readOnly: true,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: _isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.my_location, color: Colors.white),
            label: Text(_isLoading ? "Fetching Location..." : "Get Current Location"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade600, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController.complete(controller);
              },
              markers: _markers,
              onTap: (position) => _updateLocation(position, "Selected Location"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}