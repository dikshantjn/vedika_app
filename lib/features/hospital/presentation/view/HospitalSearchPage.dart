import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/DraggableHospitalList.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

const String apiKey = "AIzaSyAPbU5HX04forjDEfpkrhofAyna0cUfboI";

class HospitalSearchPage extends StatefulWidget {
  @override
  _HospitalSearchPageState createState() => _HospitalSearchPageState();
}

class _HospitalSearchPageState extends State<HospitalSearchPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _hospitals = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  List<bool> _expandedItems = []; // Change this from Map<int, bool> to List<bool>
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredHospitals = [];


  void _moveCameraToHospital(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation(); // Call it here
    _filteredHospitals = List.from(_hospitals); // Initialize filtered hospitals
    _expandedItems = List<bool>.generate(_hospitals.length, (index) => false);  }

  // Load User Location after Map is Initialized
  void _loadUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    print("Lat : ${locationProvider.latitude} Lang: ${locationProvider.longitude}");

    // Ensure location is loaded
    await locationProvider.loadSavedLocation();
    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      setState(() {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      }

      _fetchNearbyHospitals();
    }
  }

  // Fetch Nearby Hospitals (Static Data for Now)
  void _fetchNearbyHospitals() {
    if (_currentPosition == null) return;  // Ensure the current position is available

    List<Map<String, dynamic>> hospitals = [
      {
        "id": "H1",
        "name": "Rao Nursing Home",
        "address": "Survey No. 691A, B, CTS No. 1897, 1A-1, Pune - Satara Rd, Bibwewadi, Pune, Maharashtra 411037",
        "contact": "091300 06009",
        "email": "contact@raonursinghome.com",
        "website": "https://raonursinghome.com",
        "specialties": ["Multi-Speciality"],
        "doctors": [
          {
            "name": "Dr. A. Rao",
            "specialization": "General Practitioner",
            "timeSlots": ["9:00 AM", "12:00 PM", "3:00 PM"],
            "fee": 500
          },
          {
            "name": "Dr. R. Deshmukh",
            "specialization": "Pediatrician",
            "timeSlots": ["10:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 400
          },
          {
            "name": "Dr. S. Joshi",
            "specialization": "Cardiologist",
            "timeSlots": ["8:00 AM", "12:00 PM", "4:00 PM"],
            "fee": 700
          }
        ],
        "beds": 100,
        "services": ["General Services", "Emergency Care", "ICU"],
        "visitingHours": "Open 24 hours",
        "ratings": 4.0,
        "insuranceProviders": ["Provider A", "Provider B"],
        "labs": ["Lab A", "Lab B"],
        "lat": _currentPosition!.latitude - 0.01,
        "lng": _currentPosition!.longitude - 0.01,
      },
      {
        "id": "H2",
        "name": "Ranka Hospital",
        "address": "157 / 5, SS Dhage Rd, near Swargate, Mukund Nagar, Pune, Maharashtra 411037",
        "contact": "020 2426 1600",
        "email": "contact@rankahospital.com",
        "website": "https://rankahospital.com",
        "specialties": ["Multi-Speciality"],
        "doctors": [
          {
            "name": "Dr. R. Ranka",
            "specialization": "General Surgeon",
            "timeSlots": ["10:00 AM", "1:00 PM", "4:00 PM"],
            "fee": 600
          },
          {
            "name": "Dr. M. Patil",
            "specialization": "Orthopaedic Surgeon",
            "timeSlots": ["9:00 AM", "12:00 PM", "3:00 PM"],
            "fee": 800
          },
          {
            "name": "Dr. P. Kulkarni",
            "specialization": "ENT Specialist",
            "timeSlots": ["11:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 450
          }
        ],
        "beds": 120,
        "services": ["Surgery", "Emergency", "Outpatient Services"],
        "visitingHours": "Open 24 hours",
        "ratings": 4.3,
        "insuranceProviders": ["Provider C", "Provider D"],
        "labs": ["Lab C", "Lab D"],
        "lat": _currentPosition!.latitude - 0.01,
        "lng": _currentPosition!.longitude + 0.01,
      },
      {
        "id": "H3",
        "name": "Dugad Hospital",
        "address": "First Floor, Adinath Shopping Centre, Pune - Satara Rd, Adinath Society, Parsanees Colony, Maharshi Nagar, Pune, Maharashtra 411037",
        "contact": "089286 05525",
        "email": "contact@dugadhospital.com",
        "website": "https://dugadhospital.com",
        "specialties": ["Maternity"],
        "doctors": [
          {
            "name": "Dr. M. Dugad",
            "specialization": "Obstetrician",
            "timeSlots": ["8:00 AM", "11:00 AM", "2:00 PM"],
            "fee": 650
          },
          {
            "name": "Dr. R. Shinde",
            "specialization": "Gynecologist",
            "timeSlots": ["9:00 AM", "1:00 PM", "4:00 PM"],
            "fee": 600
          },
          {
            "name": "Dr. P. Jadhav",
            "specialization": "Pediatrician",
            "timeSlots": ["10:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 500
          }
        ],
        "beds": 80,
        "services": ["Maternity Services", "General Checkup"],
        "visitingHours": "Open 24 hours",
        "ratings": 4.2,
        "insuranceProviders": ["Provider E", "Provider F"],
        "labs": ["Lab E", "Lab F"],
        "lat": _currentPosition!.latitude + 0.01,
        "lng": _currentPosition!.longitude - 0.01,
      },
      {
        "id": "H4",
        "name": "Shraddha Hospital",
        "address": "41, Tulshibagwale Colony Road, Lakhshmi Nagar, Sahakar Nagar 2, Parvati Paytha, Pune, Maharashtra 411009",
        "contact": "020 2422 6267",
        "email": "contact@shraddhahospital.com",
        "website": "https://shraddhahospital.com",
        "specialties": ["General"],
        "doctors": [
          {
            "name": "Dr. S. Shraddha",
            "specialization": "General Physician",
            "timeSlots": ["9:00 AM", "12:00 PM", "3:00 PM"],
            "fee": 500
          },
          {
            "name": "Dr. A. N. Shinde",
            "specialization": "Cardiologist",
            "timeSlots": ["10:00 AM", "1:00 PM", "4:00 PM"],
            "fee": 700
          },
          {
            "name": "Dr. M. Kumbhar",
            "specialization": "Nephrologist",
            "timeSlots": ["11:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 750
          }
        ],
        "beds": 150,
        "services": ["General Services", "Emergency Care", "ICU"],
        "visitingHours": "Open 24 hours",
        "ratings": 4.1,
        "insuranceProviders": ["Provider G", "Provider H"],
        "labs": ["Lab G", "Lab H"],
        "lat": _currentPosition!.latitude - 0.01,
        "lng": _currentPosition!.longitude + 0.01,
      },
      {
        "id": "H5",
        "name": "Kothari Hospital",
        "address": "Satara Rd, above Cosmos Bank, Adinath Society, Parvati Industrial Estate, Parvati Paytha, Pune, Maharashtra 411009",
        "contact": "090216 64900",
        "email": "contact@kotharihospital.com",
        "website": "https://kotharihospital.com",
        "specialties": ["Orthopaedic"],
        "doctors": [
          {
            "name": "Dr. K. Kothari",
            "specialization": "Orthopaedic Surgeon",
            "timeSlots": ["10:00 AM", "1:00 PM", "4:00 PM"],
            "fee": 700
          },
          {
            "name": "Dr. S. Jadhav",
            "specialization": "Orthopedic Surgeon",
            "timeSlots": ["9:00 AM", "12:00 PM", "3:00 PM"],
            "fee": 650
          },
          {
            "name": "Dr. A. Pawar",
            "specialization": "Rheumatologist",
            "timeSlots": ["11:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 700
          }
        ],
        "beds": 100,
        "services": ["Orthopaedic Services", "Emergency Care"],
        "visitingHours": "10:00 AM - 6:00 PM",
        "ratings": 4.4,
        "insuranceProviders": ["Provider I", "Provider J"],
        "labs": ["Lab I", "Lab J"],
        "lat": _currentPosition!.latitude + 0.01,
        "lng": _currentPosition!.longitude - 0.01,
      },
      {
        "id": "H6",
        "name": "Jhamwar Hospital",
        "address": "Somshankar Chambers, Opp City Pride Cinema, Pune Satara Road, near Bhapkar Petrol Pump, Pune, Maharashtra 411009",
        "contact": "020 2422 6209",
        "email": "contact@jhamwarhospital.com",
        "website": "https://jhamwarhospital.com",
        "specialties": ["Eye Care"],
        "doctors": [
          {
            "name": "Dr. J. Jhamwar",
            "specialization": "Ophthalmologist",
            "timeSlots": ["9:00 AM", "12:00 PM", "3:00 PM"],
            "fee": 600
          },
          {
            "name": "Dr. M. P. Deshmukh",
            "specialization": "Ophthalmologist",
            "timeSlots": ["10:00 AM", "2:00 PM", "5:00 PM"],
            "fee": 550
          },
          {
            "name": "Dr. R. P. Patil",
            "specialization": "Optometrist",
            "timeSlots": ["11:00 AM", "2:00 PM", "4:00 PM"],
            "fee": 400
          }
        ],
        "beds": 70,
        "services": ["Eye Care Services", "Emergency Care"],
        "visitingHours": "10:00 AM - 8:30 PM",
        "ratings": 4.5,
        "insuranceProviders": ["Provider K", "Provider L"],
        "labs": ["Lab K", "Lab L"],
        "lat": _currentPosition!.latitude - 0.01,
        "lng": _currentPosition!.longitude + 0.01,
      },
    ];



    setState(() {
      _hospitals = hospitals;
      _filteredHospitals = List.from(_hospitals); // ✅ Update filtered list as well
      _expandedItems = List<bool>.filled(hospitals.length, false); // Initialize as collapsed

      _markers = hospitals.map((hospital) {
        return Marker(
          markerId: MarkerId(hospital["id"]),
          position: LatLng(hospital["lat"], hospital["lng"]),
          infoWindow: InfoWindow(title: hospital["name"]),
          onTap: () {
            setState(() {
              _filteredHospitals = [hospital]; // ✅ Show only the tapped hospital
              _expandedItems = [true]; // ✅ Expand the tapped hospital
            });
            _moveCameraToHospital(hospital["lat"], hospital["lng"]); // Move camera
          },
        );
      }).toSet();
    });
  }

  void _filterHospitals(String query) {
    print("Filtering hospitals with query: $query"); // Debugging
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = List.from(_hospitals);
      } else {
        _filteredHospitals = _hospitals.where((hospital) {
          bool matches = hospital["name"].toString().toLowerCase().contains(query.toLowerCase()) ||
              hospital["address"].toString().toLowerCase().contains(query.toLowerCase()) ||
              (hospital["doctors"] as List<dynamic>)
                  .map((doctor) => doctor.toString().toLowerCase())
                  .any((doctor) => doctor.contains(query.toLowerCase()));

          print("Checking hospital: ${hospital["name"]}, Matches: $matches"); // Debugging
          return matches;
        }).toList();
      }
      _expandedItems = List.generate(_filteredHospitals.length, (index) => false);
    });

    print("Filtered hospitals count: ${_filteredHospitals.length}"); // Debugging
    print("Filtered hospitals: ${_filteredHospitals.map((h) => h["name"]).toList()}"); // Debugging
  }






  // Open Hospital Details in Bottom Sheet
  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (_, controller) => Container(
            padding: EdgeInsets.all(16),
            child: ListView(
              controller: controller,
              children: [
                Text(hospital["name"], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(hospital["address"]),
              ],
            ),
          ),
        );
      },
    );
  }

  // // Search Hospitals using Google Places API
  // Future<void> _handleSearch() async {
  //   Prediction? prediction = await PlacesAutocomplete.show(
  //     context: context,
  //     apiKey: apiKey,
  //     mode: Mode.overlay,
  //     language: "en",
  //     components: [Component(Component.country, "en")],
  //   );
  //
  //   if (prediction != null) {
  //     GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: apiKey);
  //     PlacesDetailsResponse details = await places.getDetailsByPlaceId(prediction.placeId!);
  //     LatLng newPosition = LatLng(details.result.geometry!.location.lat, details.result.geometry!.location.lng);
  //
  //     // Move map to the searched location
  //     _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 14));
  //
  //     // Highlight searched hospital
  //     setState(() {
  //       _markers = {
  //         Marker(
  //           markerId: MarkerId(details.result.placeId),
  //           position: newPosition,
  //           infoWindow: InfoWindow(title: details.result.name),
  //           onTap: () => _showHospitalDetails({
  //             "id": details.result.placeId,
  //             "name": details.result.name,
  //             "address": details.result.formattedAddress ?? "",
  //             "contact": details.result.formattedPhoneNumber ?? "",
  //             "email": "",
  //             "website": details.result.website ?? "",
  //             "specialties": [],
  //             "doctors": [],
  //             "beds": 0,
  //             "services": [],
  //             "visitingHours": "",
  //             "ratings": details.result.rating ?? 0,
  //             "insuranceProviders": [],
  //             "labs": [],
  //             "lat": newPosition.latitude,
  //             "lng": newPosition.longitude,
  //           }),
  //         ),
  //       };
  //     });
  //   }
  // }
  //


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: _isLoading || _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),

          // Search Bar with TextField and IconButton
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _filterHospitals(_searchController.text); // ✅ Perform local search based on input
                    },
                    child: Icon(Icons.search, color: Colors.black54),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        print("Search query: $value"); // Debugging
                        _filterHospitals(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Search hospitals...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),

          DraggableHospitalList(
            hospitals: _filteredHospitals.isNotEmpty ? _filteredHospitals : _hospitals, // ✅ Use filtered list
            expandedItems: _expandedItems,
            onHospitalTap: (index, lat, lng) {  // ✅ Pass latitude & longitude
              setState(() {
                _expandedItems[index] = !_expandedItems[index];
                _moveCameraToHospital(lat, lng); // ✅ Move camera to the selected hospital
              });
            },
          )
        ],
      ),
    );
  }
}
