import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabTestService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:logger/logger.dart';

class LabSearchViewModel extends ChangeNotifier {
  final _logger = Logger();
  final LabTestService _labTestService = LabTestService();
  
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  List<DiagnosticCenter> _labCenters = [];
  List<DiagnosticCenter> _filteredLabCenters = [];
  bool _isLoading = true;
  bool _isMapReady = false;
  TextEditingController searchController = TextEditingController();
  bool _isSidePanelOpen = false;
  BitmapDescriptor? _labMarkerIcon;

  // Track the selected lab
  DiagnosticCenter? _selectedLab;

  // City data
  Map<String, int> _cityLabCounts = {};
  String? _selectedCity;

  // City coordinates map
  final Map<String, LatLng> _cityCoordinates = {
    'Mumbai': LatLng(19.0760, 72.8777),
    'Delhi': LatLng(28.6139, 77.2090),
    'Bangalore': LatLng(12.9716, 77.5946),
    'Hyderabad': LatLng(17.3850, 78.4867),
    'Chennai': LatLng(13.0827, 80.2707),
    'Kolkata': LatLng(22.5726, 88.3639),
    'Pune': LatLng(18.5204, 73.8567),
    'Ahmedabad': LatLng(23.0225, 72.5714),
    'Jaipur': LatLng(26.9124, 75.7873),
    'Lucknow': LatLng(26.8467, 80.9462),
  };

  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  List<DiagnosticCenter> get labs => _selectedLab != null ? [_selectedLab!] : _filteredLabCenters;
  bool get isLoading => _isLoading;
  LatLng? get currentPosition => _currentPosition;
  DiagnosticCenter? get selectedLab => _selectedLab;
  bool get isSidePanelOpen => _isSidePanelOpen;
  Map<String, int> get cityLabCounts => _cityLabCounts;
  String? get selectedCity => _selectedCity;
  bool get isMapReady => _isMapReady;

  Future<void> _initializeMarkerIcons() async {
    _labMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/lab_marker.png',
    );
  }

  void setMapController(GoogleMapController controller) async {
    _logger.i("Setting MapController in ViewModel");
    _mapController = controller;
    _isMapReady = true;

    // Initialize marker icons
    await _initializeMarkerIcons();

    if (_currentPosition != null) {
      _logger.i("Moving camera to user location: $_currentPosition");
      try {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      } catch (e) {
        _logger.e("Error moving camera: $e");
      }
      // Update markers after controller is set
      _updateMarkers();
    } else {
      _logger.w("Current position is null in setMapController");
    }

    notifyListeners();
  }

  Future<void> loadUserLocation(BuildContext context) async {
    try {
      _selectedLab = null; // Reset selected lab when reopening the page
      _isLoading = true;
      notifyListeners();

      var locationProvider = Provider.of<LocationProvider>(context, listen: false);
      loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _logger.w("Location services disabled. Showing city options.");
          _isLoading = false;
          _isSidePanelOpen = true; // Open side panel to show city options
          notifyListeners();
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          _logger.w("Location permission denied. Showing city options.");
          _isLoading = false;
          _isSidePanelOpen = true; // Open side panel to show city options
          notifyListeners();
          return;
        }
      }

      await locationProvider.loadSavedLocation();
      if (locationProvider.latitude != null && locationProvider.longitude != null) {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
        _logger.i("User location set: $_currentPosition");
      } else {
        _logger.e("Failed to get saved location, using default location");
        // Use a default location if saved location is not available
        _currentPosition = LatLng(18.488726, 73.8674683); // Default location
      }

      // Fetch lab centers before attempting to use mapController
      await _fetchLabCenters();
      
      _isLoading = false;
      notifyListeners();
      _logger.i("_isLoading set to false");

      // If controller is already initialized, move camera to user's location
      if (_mapController != null && _currentPosition != null) {
        _logger.i("Moving map to user location");
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      } else {
        _logger.w("MapController is NULL. It will be initialized when the map is created.");
      }

      _addUserLocationMarker();
    } catch (e, stackTrace) {
      _logger.e("Error in loadUserLocation(): $e");
      _logger.e("Stack trace: $stackTrace");
      _isLoading = false;
      _isSidePanelOpen = true; // Open side panel to show city options on error
      notifyListeners();
    }
  }

  Future<void> _fetchLabCenters() async {
    try {
      _logger.i("Fetching lab centers from API");
      _labCenters = await _labTestService.getAllDiagnosticCenters();
      _logger.i("Fetched ${_labCenters.length} lab centers");
      
      if (_labCenters.isEmpty) {
        _logger.w("No lab centers found from API");
        _filteredLabCenters = [];
        return;
      }
      
      // Update city lab counts
      _updateCityLabCounts();
      
      // Filter labs that are within a reasonable distance (if location data available)
      if (_currentPosition != null) {
        _filteredLabCenters = _labCenters.where((center) {
          // Extract location from the location string (assuming format: "lat,lng")
          try {
            if (center.location.isEmpty) {
              _logger.w("Empty location for center: ${center.name}");
              // Return true to include centers even with empty location
              return true;
            }
            
            List<String> coordinates = center.location.split(',');
            if (coordinates.length != 2) {
              _logger.w("Invalid location format for center: ${center.name}, location: ${center.location}");
              return false;
            }
            
            double lat = double.tryParse(coordinates[0].trim()) ?? 0;
            double lng = double.tryParse(coordinates[1].trim()) ?? 0;
            
            if (lat == 0 && lng == 0) {
              _logger.w("Invalid coordinates for center: ${center.name}, location: ${center.location}");
              return false;
            }
            
            // Calculate distance and include only those within 50km
            double distance = _calculateDistanceFromCoordinates(lat, lng);
            return distance <= 50.0; // Increased from 10km to 50km radius
          } catch (e) {
            _logger.e("Error parsing location for center ${center.name}: $e");
            return false;
          }
        }).toList();
        
        _logger.i("Filtered to ${_filteredLabCenters.length} lab centers within 50km");
        
        // If no centers found within the distance limit, show all centers as fallback
        if (_filteredLabCenters.isEmpty && _labCenters.isNotEmpty) {
          _logger.i("No centers found within distance limit, showing all ${_labCenters.length} centers");
          _filteredLabCenters = _labCenters;
        }
      } else {
        _filteredLabCenters = _labCenters;
      }
      
      _updateMarkers();
    } catch (e, stackTrace) {
      _logger.e("Error fetching lab centers: $e");
      _logger.e("Stack trace: $stackTrace");
      _filteredLabCenters = [];
    }
  }

  double _calculateDistanceFromCoordinates(double lat, double lng) {
    if (_currentPosition == null) return double.infinity;
    
    const double earthRadius = 6371; // in kilometers
    double dLat = _degreesToRadians(lat - _currentPosition!.latitude);
    double dLng = _degreesToRadians(lng - _currentPosition!.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(_currentPosition!.latitude)) *
            cos(_degreesToRadians(lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _updateMarkers() {
    try {
      _markers.clear();
      _logger.i("Updating markers for ${_filteredLabCenters.length} centers");

      for (var center in _filteredLabCenters) {
        try {
          if (center.location.isEmpty) {
            _logger.w("Skipping marker for center with empty location: ${center.name}");
            continue;
          }
          
          List<String> coordinates = center.location.split(',');
          if (coordinates.length != 2) {
            _logger.w("Skipping marker for center with invalid location format: ${center.name}");
            continue;
          }
          
          double? lat = double.tryParse(coordinates[0].trim());
          double? lng = double.tryParse(coordinates[1].trim());
          
          if (lat == null || lng == null) {
            _logger.w("Skipping marker for center with invalid coordinates: ${center.name}");
            continue;
          }
          
          final markerId = MarkerId(center.vendorId ?? center.generatedId ?? center.name);
          _logger.i("Adding marker for ${center.name} at $lat,$lng");
          
          _markers.add(
            Marker(
              markerId: markerId,
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title: center.name,
                snippet: center.address,
              ),
              onTap: () {
                moveCameraToLab(lat, lng, center);
              },
            ),
          );
        } catch (e) {
          _logger.e("Error creating marker for center ${center.name}: $e");
        }
      }

      _addUserLocationMarker();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e("Error in _updateMarkers: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  void _addUserLocationMarker() {
    if (_currentPosition == null) return;

    _markers.add(
      Marker(
        markerId: MarkerId("userLocation"),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: "Your Location"),
      ),
    );
    notifyListeners();
  }

  void filterLabs(String query) {
    try {
      _logger.i("Filtering labs with query: '$query'");
      _selectedLab = null; // Reset selected lab to show all matching results

      if (query.isEmpty) {
        // If no query, show all labs within distance limit
        if (_currentPosition != null) {
          _filteredLabCenters = _labCenters.where((center) {
            try {
              if (center.location.isEmpty) {
                _logger.w("Empty location for center: ${center.name}");
                // Return true to include centers even with empty location
                return true;
              }
              
              List<String> coordinates = center.location.split(',');
              if (coordinates.length != 2) {
                _logger.w("Invalid location format for center: ${center.name}");
                return false;
              }
              
              double? lat = double.tryParse(coordinates[0].trim());
              double? lng = double.tryParse(coordinates[1].trim());
              
              if (lat == null || lng == null) {
                _logger.w("Invalid coordinates for center: ${center.name}");
                return false;
              }
              
              double distance = _calculateDistanceFromCoordinates(lat, lng);
              return distance <= 50.0;
            } catch (e) {
              _logger.e("Error calculating distance for center ${center.name}: $e");
              return false;
            }
          }).toList();
        } else {
          _filteredLabCenters = _labCenters;
        }
      } else {
        // Filter by name or test types containing the query
        _filteredLabCenters = _labCenters.where((center) {
          return center.name.toLowerCase().contains(query.toLowerCase()) ||
              center.testTypes.any((test) => test.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }

      _logger.i("Filtered to ${_filteredLabCenters.length} centers");
      _updateMarkers();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e("Error in filterLabs: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  void moveCameraToLab(double lat, double lng, DiagnosticCenter lab) {
    try {
      _logger.i("Moving camera to lab: ${lab.name} at $lat,$lng");
      _selectedLab = lab;
      notifyListeners();

      if (_mapController == null) {
        _logger.e("MapController is null in moveCameraToLab");
        return;
      }

      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
    } catch (e, stackTrace) {
      _logger.e("Error in moveCameraToLab: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  void bookLabAppointment(BuildContext context, DiagnosticCenter center) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookLabTestAppointment,
      arguments: center,
    );
  }

  void selectLabWithoutMovingCamera(DiagnosticCenter lab) {
    try {
      _logger.i("Selecting lab without moving camera: ${lab.name}");
      _selectedLab = lab;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e("Error in selectLabWithoutMovingCamera: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  void toggleSidePanel() {
    _isSidePanelOpen = !_isSidePanelOpen;
    notifyListeners();
  }

  void _updateCityLabCounts() {
    _cityLabCounts.clear();
    for (var center in _labCenters) {
      if (center.city.isNotEmpty) {
        _cityLabCounts[center.city] = (_cityLabCounts[center.city] ?? 0) + 1;
      }
    }
    // Sort cities by lab count in descending order
    _cityLabCounts = Map.fromEntries(
      _cityLabCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    notifyListeners();
  }

  void selectCity(String city) {
    _selectedCity = city;
    _filterLabsByCity(city);
    
    // Move camera to selected city
    if (_cityCoordinates.containsKey(city) && _mapController != null) {
      final cityLocation = _cityCoordinates[city]!;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(cityLocation, 12.0),
      );
    }
    
    notifyListeners();
  }

  void _filterLabsByCity(String city) {
    if (city.isEmpty) {
      _filteredLabCenters = _labCenters;
    } else {
      _filteredLabCenters = _labCenters.where((center) => center.city == city).toList();
    }
    _updateMarkers();
  }
}