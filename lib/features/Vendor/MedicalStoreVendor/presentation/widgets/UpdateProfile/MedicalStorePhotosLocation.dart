import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';

class MedicalStorePhotosLocation extends StatefulWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;

  const MedicalStorePhotosLocation({Key? key, required this.viewModel}) : super(key: key);

  @override
  _MedicalStorePhotosLocationState createState() =>
      _MedicalStorePhotosLocationState();
}

class _MedicalStorePhotosLocationState extends State<MedicalStorePhotosLocation> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(12.9716, 77.5946); // Default: Bangalore coordinates
  Set<Marker> _markers = {};
  Location _location = Location(); // Location package instance

  TextEditingController _locationController = TextEditingController();
  bool _isLoading = false; // To track the loading state

  @override
  void initState() {
    super.initState();

    // Check if the location is already available in the viewModel
    if (widget.viewModel.location != null && widget.viewModel.location!.isNotEmpty) {
      // Parse the saved location (latitude, longitude) from the viewModel
      List<String> locationParts = widget.viewModel.location!.split(',');
      if (locationParts.length == 2) {
        double lat = double.parse(locationParts[0]);
        double lng = double.parse(locationParts[1]);
        _currentLocation = LatLng(lat, lng);

        // Update the marker and location text field immediately
        _markers.add(Marker(
          markerId: MarkerId("currentLocation"),
          position: _currentLocation,
          infoWindow: InfoWindow(title: "Saved Location"),
        ));
        _locationController.text = "${_currentLocation.latitude}, ${_currentLocation.longitude}";
      }
    } else {
      // If no location available, use default values
      _markers.add(Marker(
        markerId: MarkerId("currentLocation"),
        position: _currentLocation,
        infoWindow: InfoWindow(title: "Current Location"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Photos & Location"),

        // Upload Photos Section with Multiple File Selection
        UploadSectionWidget(
          label: "Upload Latest Photos of Medical Store",
          onFilesSelected: (List<Map<String, Object>> files) {
            widget.viewModel.photos = files; // Directly store the list of maps (dt & file)
            widget.viewModel.notifyListeners();
          },
        ),

        const SizedBox(height: 15),

        // Google Maps Location Picker
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Precise Location using Google Maps",
                style: TextStyle(
                  fontSize: 14,
                  color: MedicalStoreVendorColorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Location text box with styling
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
                      },
                    ),
                  ),
                  readOnly: true, // Make the text field read-only
                ),
              ),
            ],
          ),
        ),

        // Button to get current location with better styling (Smaller size)
        if (!_isLoading)
          ElevatedButton(
            onPressed: () async {
              await _getCurrentLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MedicalStoreVendorColorPalette.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15), // Reduced padding for smaller button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: TextStyle(fontSize: 14), // Smaller text size
            ),
            child: const Text(
              "Get Current Location",
              style: TextStyle(fontSize: 14), // Smaller text size
            ),
          )
        else
          Center(
            child: CircularProgressIndicator(), // Show loading indicator while fetching location
          ),

        const SizedBox(height: 15),

        // Google Map display with a border
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade600, width: 1), // Add border to the map container
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            onTap: (LatLng position) {
              setState(() {
                _currentLocation = position;
                _markers.clear();
                _markers.add(Marker(
                  markerId: MarkerId("selectedLocation"),
                  position: position,
                  infoWindow: InfoWindow(title: "Selected Location"),
                ));
                // Update the location in the text field
                _locationController.text = "${_currentLocation.latitude}, ${_currentLocation.longitude}";
              });
            },
          ),
        ),
      ],
    );
  }



  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Request permission if needed
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      LocationData locationData = await _location.getLocation();

      // Set current location on the map and update the UI
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _markers.clear();  // Clear existing markers
        _markers.add(Marker(
          markerId: MarkerId("currentLocation"),
          position: _currentLocation,
          infoWindow: InfoWindow(title: "Current Location"),
        ));

        // Move camera to the new location and show the marker immediately
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );

        // Update the location in the text field immediately
        _locationController.text = "${_currentLocation.latitude}, ${_currentLocation.longitude}";
      });

      // Update the location in viewModel
      String locationString = "${_currentLocation.latitude},${_currentLocation.longitude}";
      widget.viewModel.location = locationString;
      widget.viewModel.notifyListeners();
    } catch (e) {
      print("Error getting current location: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator once the location is fetched
      });
    }
  }
}

