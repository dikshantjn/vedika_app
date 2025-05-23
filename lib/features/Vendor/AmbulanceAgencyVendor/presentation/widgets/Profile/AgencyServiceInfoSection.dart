import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyProfileViewModel.dart';

class AgencyServiceInfoSection extends StatelessWidget {
  final AmbulanceAgencyProfileViewModel viewModel;

  const AgencyServiceInfoSection({super.key, required this.viewModel});

  Widget _buildServiceCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {Color? backgroundColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: textColor ?? Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agency = viewModel.agency;

    if (agency == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildServiceCard('Service Areas', agency.operationalAreas.join(', '), Icons.location_on_outlined),
        _buildServiceCard('24x7 Service', agency.is24x7Available ? 'Available' : 'Not Available', Icons.access_time_outlined),
        _buildServiceCard('Distance Limit', '${agency.distanceLimit} km', Icons.route_outlined),
        _buildServiceCard('GPS Tracking', agency.gpsTrackingAvailable ? 'Available' : 'Not Available', Icons.gps_fixed_outlined),
        _buildServiceCard('Driver KYC', agency.driverKYC ? 'Completed' : 'Pending', Icons.person_outline),
        _buildServiceCard('Driver Training', agency.driverTrained ? 'Completed' : 'Pending', Icons.school_outlined),
        const SizedBox(height: 24),
        Text(
          'Fleet Information',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total Ambulances: ${agency.numOfAmbulances}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: agency.ambulanceTypes.map((type) => _buildTag(type)).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Equipment',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: agency.ambulanceEquipment.map((equipment) => 
            _buildTag(equipment, backgroundColor: Colors.green.shade50, textColor: Colors.green[700])
          ).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Languages',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: agency.languageProficiency.map((language) => 
            _buildTag(language, backgroundColor: Colors.purple.shade50, textColor: Colors.purple[700])
          ).toList(),
        ),
      ],
    );
  }
}
