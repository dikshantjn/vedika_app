import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class CabBookingBottomSheet extends StatelessWidget {
  final String destinationAddress;
  final DoctorClinicProfile doctor;

  const CabBookingBottomSheet({
    Key? key,
    required this.destinationAddress,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                                doctor.doctorName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                destinationAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              if (doctor.nearbyLandmark.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Landmark: ${doctor.nearbyLandmark}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
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
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logoAsset,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCabApp(BuildContext context, String packageName, String appUrl) async {
    try {
      final Uri uri = Uri.parse('$appUrl?dropoff=${Uri.encodeComponent(destinationAddress)}');
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