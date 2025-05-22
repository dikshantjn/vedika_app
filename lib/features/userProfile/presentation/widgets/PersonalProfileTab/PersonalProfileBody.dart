import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';

class PersonalProfileBody extends StatelessWidget {
  final UserPersonalProfileViewModel viewModel;

  PersonalProfileBody({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Personal Information',
            icon: Icons.person_outline,
            children: [
              _buildInfoRow('Email', viewModel.personalProfile?.email, Icons.email_outlined),
              _buildInfoRow('ABHA ID', viewModel.personalProfile?.abhaId, Icons.health_and_safety_outlined),
              _buildInfoRow('Location', viewModel.personalProfile?.location, Icons.location_on_outlined),
              _buildInfoRow('Date of Birth', viewModel.formattedDateOfBirth, Icons.calendar_today_outlined),
              _buildInfoRow('Gender', viewModel.personalProfile?.gender, Icons.people_outline),
            ],
          ),
          _buildInfoCard(
            title: 'Health Information',
            icon: Icons.favorite_outline,
            children: [
              _buildInfoRow('Blood Group', viewModel.personalProfile?.bloodGroup, Icons.bloodtype_outlined),
              _buildInfoRow('Height', viewModel.personalProfile?.height != null ? "${viewModel.personalProfile!.height} cm" : null, Icons.height_outlined),
              _buildInfoRow('Weight', viewModel.personalProfile?.weight != null ? "${viewModel.personalProfile!.weight} kg" : null, Icons.monitor_weight_outlined),
            ],
          ),
          _buildInfoCard(
            title: 'Emergency Contact',
            icon: Icons.emergency_outlined,
            children: [
              _buildInfoRow('Emergency Contact', viewModel.personalProfile?.emergencyContactNumber, Icons.phone_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: ColorPalette.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}