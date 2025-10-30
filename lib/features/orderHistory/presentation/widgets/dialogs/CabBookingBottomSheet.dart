import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class CabBookingBottomSheet extends StatefulWidget {
  final String destinationAddress;
  final DoctorClinicProfile doctor;

  const CabBookingBottomSheet({
    Key? key,
    required this.destinationAddress,
    required this.doctor,
  }) : super(key: key);

  @override
  State<CabBookingBottomSheet> createState() => _CabBookingBottomSheetState();
}

class _CabBookingBottomSheetState extends State<CabBookingBottomSheet> {
  GoogleMapController? _mapController;
  LatLng? _destinationLatLng;

  @override
  void initState() {
    super.initState();
    _destinationLatLng = _getLatLngFromLocation(widget.doctor.location);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
    return LatLng(18.5204, 73.8567); // Default to Pune
  }

  Set<Marker> get _markers {
    if (_destinationLatLng == null) return {};
    return {
      Marker(
        markerId: MarkerId('destination'),
        position: _destinationLatLng!,
        infoWindow: InfoWindow(
          title: widget.doctor.doctorName,
          snippet: widget.destinationAddress,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      color: DoctorConsultationColorPalette.primaryBlue,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Book a Ride',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Map View
            if (_destinationLatLng != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _destinationLatLng!,
                      zoom: 15,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),

            // Destination info
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: DoctorConsultationColorPalette.primaryBlue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.doctorName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.destinationAddress,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          if (widget.doctor.floor.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              'Floor: ${widget.doctor.floor}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (widget.doctor.nearbyLandmark.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              'Landmark: ${widget.doctor.nearbyLandmark}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          SizedBox(height: 4),
                          Text(
                            '${widget.doctor.city}, ${widget.doctor.state} ${widget.doctor.pincode}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Cab options grid
          Padding(
            padding: EdgeInsets.all(24),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildCabOption(
                  context,
                  'Uber',
                  'assets/ThirdPartyLogo/uber-logo.png',
                  'com.ubercab',
                  'uber://',
                ),
                _buildCabOption(
                  context,
                  'Ola',
                  'assets/ThirdPartyLogo/ola-logo.png',
                  'com.olacabs.customer',
                  'ola://',
                ),
                _buildCabOption(
                  context,
                  'Rapido',
                  'assets/ThirdPartyLogo/rapido-logo.png',
                  'com.rapido.passenger',
                  'rapido://',
                ),
              ],
            ),
          ),

          // Note text
          Padding(
            padding: EdgeInsets.only(bottom: 24, left: 24, right: 24),
            child: Text(
              'The selected app will open with the destination address pre-filled',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabOption(
    BuildContext context,
    String name,
    String logoAsset,
    String packageName,
    String appUrl,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCabApp(context, packageName, appUrl),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  logoAsset,
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_taxi,
                      color: DoctorConsultationColorPalette.primaryBlue,
                      size: 32,
                    );
                  },
                ),
              ),
              SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCabApp(BuildContext context, String packageName, String appUrl) async {
    try {
      // If we have lat/lng coordinates, use them instead of address for better accuracy
      String dropoffParam;
      if (_destinationLatLng != null) {
        dropoffParam = '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
      } else {
        dropoffParam = Uri.encodeComponent(widget.destinationAddress);
      }
      
      final Uri uri = Uri.parse('$appUrl?dropoff=$dropoffParam');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // If can't launch the app URI, try opening the Play Store
        final playStoreUri = Uri.parse('market://details?id=$packageName');
        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri);
        } else {
          throw 'Could not launch or install the app';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open the app. Please install it from your app store.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 