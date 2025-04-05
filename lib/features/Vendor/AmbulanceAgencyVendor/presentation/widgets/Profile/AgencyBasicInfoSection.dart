import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyProfileViewModel.dart';

class AgencyBasicInfoSection extends StatefulWidget {
  final AmbulanceAgencyProfileViewModel viewModel;

  const AgencyBasicInfoSection({super.key, required this.viewModel});

  @override
  State<AgencyBasicInfoSection> createState() => _AgencyBasicInfoSectionState();
}

class _AgencyBasicInfoSectionState extends State<AgencyBasicInfoSection> {
  Widget _buildInfoBox(String label, String value, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureWithStatus(bool isLive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.network(
            "url",
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 64,
              height: 64,
              color: Colors.white,
              child: const Icon(Icons.person, size: 32, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isLive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final agency = viewModel.agency;

    if (agency == null) {
      return const Center(child: CircularProgressIndicator()); // Optional null check
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Card with Profile and Status Pic
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left: Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agency.agencyName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(agency.ownerName,
                            style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(agency.contactNumber,
                            style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(agency.email,
                              style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              /// Right: Profile Pic with Status
              _buildProfilePictureWithStatus(agency.isLive),
            ],
          ),
        ),


        const SizedBox(height: 20),

        /// Info Boxes
        _buildInfoBox("Website", agency.website),
        _buildInfoBox("Address", "${agency.address}, ${agency.city}, ${agency.state} - ${agency.pinCode}"),
        _buildInfoBox("Landmark", agency.landmark),
      ],
    );
  }
}
