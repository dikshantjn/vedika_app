import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'EditMedicalProfileScreen.dart';

class MedicalProfileTab extends StatefulWidget {
  final UserMedicalProfileViewModel viewModel;

  const MedicalProfileTab({Key? key, required this.viewModel}) : super(key: key);

  @override
  _MedicalProfileTabState createState() => _MedicalProfileTabState();
}

class _MedicalProfileTabState extends State<MedicalProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchMedicalProfile().catchError((error) {
        // Handle the error gracefully here and ensure the fallback to "NA"
        print('Error fetching medical profile: $error');
        setState(() {
          // Optionally, set a flag or message to handle UI accordingly
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
            ),
          );
        }

        // If error message exists, it will be shown as 'Error'
        if (widget.viewModel.errorMessage?.isNotEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "Error: ${widget.viewModel.errorMessage}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          );
        }

        final medicalProfile = widget.viewModel.medicalProfile;

        // Check if medical profile is null and return "NA" for fields
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMedicalInfoCard(
                    title: 'Health Status',
                    icon: Icons.health_and_safety_outlined,
                    children: [
                      _buildInfoRow(
                        'Diabetic',
                        medicalProfile?.isDiabetic == null ? 'NA' : (medicalProfile!.isDiabetic ? 'Yes' : 'No'),
                        Icons.monitor_heart_outlined,
                        medicalProfile?.isDiabetic == true ? Colors.red : Colors.green,
                      ),
                      _buildInfoRow(
                        'Eye Power',
                        medicalProfile?.eyePower?.toString() ?? 'NA',
                        Icons.visibility_outlined,
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMedicalInfoCard(
                    title: 'Allergies & Conditions',
                    icon: Icons.warning_amber_outlined,
                    children: [
                      _buildInfoRow(
                        'Allergies',
                        (medicalProfile?.allergies?.isNotEmpty == true) ? medicalProfile!.allergies.join(', ') : 'NA',
                        Icons.warning_amber_outlined,
                        Colors.orange,
                      ),
                      _buildInfoRow(
                        'Chronic Conditions',
                        (medicalProfile?.chronicConditions?.isNotEmpty == true) ? medicalProfile!.chronicConditions.join(', ') : 'NA',
                        Icons.medical_information_outlined,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMedicalInfoCard(
                    title: 'Medications',
                    icon: Icons.medication_outlined,
                    children: [
                      _buildInfoRow(
                        'Current Medication',
                        (medicalProfile?.currentMedication?.isNotEmpty == true) ? medicalProfile!.currentMedication.join(', ') : 'NA',
                        Icons.medication_liquid_outlined,
                        Colors.teal,
                      ),
                      _buildInfoRow(
                        'Past Medication',
                        (medicalProfile?.pastMedication?.isNotEmpty == true) ? medicalProfile!.pastMedication.join(', ') : 'NA',
                        Icons.history_outlined,
                        Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMedicalInfoCard(
                    title: 'Medical History',
                    icon: Icons.history_edu_outlined,
                    children: [
                      _buildInfoRow(
                        'Injuries',
                        (medicalProfile?.injuries?.isNotEmpty == true) ? medicalProfile!.injuries.join(', ') : 'NA',
                        Icons.healing_outlined,
                        Colors.amber,
                      ),
                      _buildInfoRow(
                        'Surgeries',
                        (medicalProfile?.surgeries?.isNotEmpty == true) ? medicalProfile!.surgeries.join(', ') : 'NA',
                        Icons.medical_services_outlined,
                        Colors.indigo,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to EditMedicalProfileScreen and wait for a result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMedicalProfileScreen(viewModel: widget.viewModel),
                    ),
                  );

                  // Reload data if the result is true
                  if (result == true) {
                    widget.viewModel.fetchMedicalProfile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Medical Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicalInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: ColorPalette.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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

  Widget _buildInfoRow(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
