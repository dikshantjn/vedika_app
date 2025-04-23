import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';

class ClinicSearchViewModel extends ChangeNotifier {
  final ClinicService _clinicService = ClinicService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<DoctorClinicProfile> _clinics = [];
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  LatLng? _currentPosition;
  List<bool> _expandedItems = [];
  TextEditingController searchController = TextEditingController();
  List<DoctorClinicProfile> _filteredClinics = [];

  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  List<DoctorClinicProfile> get clinics => _clinics;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentPosition => _currentPosition;
  List<bool> get expandedItems => _expandedItems;
  List<DoctorClinicProfile> get filteredClinics => _filteredClinics;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }


  Future<void> ensureLocationEnabled(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("🔴 User refused to enable location services.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "clinic")),
          );
        });
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        print("🔴 User denied location permission.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "clinic")),
          );
        });
        return;
      }
    }

    print("✅ Location service enabled and permission granted.");

    // Load saved location
    await locationProvider.loadSavedLocation();
    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      print("✅ Updated Position: $_currentPosition");

      _isLoadingLocation = false;
      notifyListeners();

      await loadUserLocation(context);
    } else {
      print("🔴 LocationProvider did not return a valid location.");
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> loadUserLocation(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      _isLoading = false;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      await _fetchNearbyClinics();
      _addUserLocationMarker();
      notifyListeners();
    }
  }

  Future<void> _fetchNearbyClinics() async {
    if (_currentPosition == null) return;
    
    print('🚀 Starting _fetchNearbyClinics in ClinicSearchViewModel');
    print('📍 Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    
    try {
      // Call API to get offline clinics
      print('📡 Calling API service getActiveOfflineClinics');
      _clinics = await _clinicService.getActiveOfflineClinics();
      print('📋 Received ${_clinics.length} clinics from API');
      
      if (_clinics.isEmpty) {
        print('⚠️ No clinics returned from API, falling back to sample data');
        return;
      }
      
      // Only include doctors who offer offline consultation
      _clinics = _clinics.where((clinic) => 
        clinic.consultationTypes.contains('Offline')).toList();
      print('🎯 Filtered to ${_clinics.length} clinics with offline consultation');
      
      if (_clinics.isEmpty) {
        print('⚠️ No clinics with offline consultation found, falling back to sample data');
        return;
      }
      
      _filteredClinics = List.from(_clinics);
      _expandedItems = List<bool>.filled(_clinics.length, false);
      _setClinicMarkers();
      print('✅ _fetchNearbyClinics completed successfully');
    } catch (e) {
      print('❌ Error in _fetchNearbyClinics: $e');
      // Fallback to sample data if API fails
      print('🔄 Falling back to sample data due to error');
    }
    
    notifyListeners();
  }
  


  void _setClinicMarkers() {
    _markers = _clinics.map((clinic) {
      final latLng = _getLatLngFromLocation(clinic.location);
      return Marker(
        markerId: MarkerId(clinic.vendorId ?? ''),
        position: latLng,
        infoWindow: InfoWindow(title: clinic.doctorName),
        onTap: () {
          _filteredClinics = [clinic];
          _expandedItems = [true];
          _moveCameraToClinic(latLng.latitude, latLng.longitude);
          notifyListeners();
        },
      );
    }).toSet();
  }
  
  LatLng _getLatLngFromLocation(String location) {
    try {
      final parts = location.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return LatLng(lat, lng);
      }
    } catch (e) {
      print("Error parsing location: $e");
    }
    // Default to a fallback location if parsing fails
    return LatLng(0, 0);
  }

  void _addUserLocationMarker() {
    if (_currentPosition == null) return;
    _markers.add(
      Marker(
        markerId: MarkerId("userLocation"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    notifyListeners();
  }

  void _moveCameraToClinic(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
    notifyListeners();
  }

  void filterClinics(String query) {
    if (query.isEmpty) {
      _filteredClinics = List.from(_clinics);
    } else {
      _filteredClinics = _clinics.where((clinic) {
        return clinic.doctorName.toLowerCase().contains(query.toLowerCase()) ||
            clinic.address.toLowerCase().contains(query.toLowerCase()) ||
            clinic.specializations.any((s) => s.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    _expandedItems = List.generate(_filteredClinics.length, (index) => false);
    notifyListeners();
  }

  void toggleClinicExpansion(int index) {
    expandedItems[index] = !expandedItems[index];
    notifyListeners();
  }
}
