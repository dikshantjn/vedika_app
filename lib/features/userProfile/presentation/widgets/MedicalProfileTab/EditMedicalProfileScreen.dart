import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/MedicalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';

class EditMedicalProfileScreen extends StatefulWidget {
  final UserMedicalProfileViewModel viewModel;

  EditMedicalProfileScreen({required this.viewModel});

  @override
  _EditMedicalProfileScreenState createState() => _EditMedicalProfileScreenState();
}

class _EditMedicalProfileScreenState extends State<EditMedicalProfileScreen> {
  late TextEditingController allergiesController;
  late TextEditingController currentMedController;
  late TextEditingController pastMedController;
  late TextEditingController chronicController;
  late TextEditingController injuriesController;
  late TextEditingController surgeriesController;
  bool _isDiabetic = false;
  double eyePower = 0.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    allergiesController = TextEditingController();
    currentMedController = TextEditingController();
    pastMedController = TextEditingController();
    chronicController = TextEditingController();
    injuriesController = TextEditingController();
    surgeriesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchMedicalProfile();
    });
  }

  void _saveProfile() async {
    if (!mounted) return;

    final profile = widget.viewModel.medicalProfile;
    String? userId = await StorageService.getUserId();

    final updatedProfile = MedicalProfile(
      medicalProfileId: profile?.medicalProfileId ?? '',
      userId: profile?.userId ?? userId!,
      isDiabetic: _isDiabetic,
      allergies: allergiesController.text.isNotEmpty ? allergiesController.text.split(', ') : [],
      eyePower: eyePower,
      currentMedication: currentMedController.text.isNotEmpty ? currentMedController.text.split(', ') : [],
      pastMedication: pastMedController.text.isNotEmpty ? pastMedController.text.split(', ') : [],
      chronicConditions: chronicController.text.isNotEmpty ? chronicController.text.split(', ') : [],
      injuries: injuriesController.text.isNotEmpty ? injuriesController.text.split(', ') : [],
      surgeries: surgeriesController.text.isNotEmpty ? surgeriesController.text.split(', ') : [],
    );

    bool isUpdated = false;
    try {
      if (profile?.userId != null && profile!.userId.isNotEmpty) {
        await widget.viewModel.updateMedicalProfile(updatedProfile);
        isUpdated = true;
      } else {
        await widget.viewModel.createMedicalProfile(updatedProfile);
        isUpdated = true;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                isUpdated ? 'Profile Updated Successfully' : 'Profile Saved Successfully',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to save profile: $e',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Medical Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, child) {
          final profile = widget.viewModel.medicalProfile;

          if (profile != null && !_isInitialized) {
            allergiesController.text = profile.allergies.join(', ');
            currentMedController.text = profile.currentMedication.join(', ');
            pastMedController.text = profile.pastMedication.join(', ');
            chronicController.text = profile.chronicConditions.join(', ');
            injuriesController.text = profile.injuries.join(', ');
            surgeriesController.text = profile.surgeries.join(', ');
            _isDiabetic = profile.isDiabetic;
            eyePower = profile.eyePower;
            _isInitialized = true;
          }

          return widget.viewModel.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[400]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.viewModel.errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildSection(
                        title: 'Health Status',
                        icon: Icons.health_and_safety_outlined,
                        children: [
                          _buildTextField(
                            allergiesController,
                            'Allergies',
                            'Enter allergies (comma-separated)',
                            Icons.warning_amber_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchTile(
                            'Diabetic',
                            _isDiabetic,
                            (value) => setState(() => _isDiabetic = value),
                            Icons.monitor_heart_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Medications',
                        icon: Icons.medication_outlined,
                        children: [
                          _buildTextField(
                            currentMedController,
                            'Current Medication',
                            'Enter current medications (comma-separated)',
                            Icons.medication_liquid_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            pastMedController,
                            'Past Medication',
                            'Enter past medications (comma-separated)',
                            Icons.history_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Medical History',
                        icon: Icons.history_edu_outlined,
                        children: [
                          _buildTextField(
                            chronicController,
                            'Chronic Conditions',
                            'Enter chronic conditions (comma-separated)',
                            Icons.medical_information_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            injuriesController,
                            'Injuries',
                            'Enter injuries (comma-separated)',
                            Icons.healing_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            surgeriesController,
                            'Surgeries',
                            'Enter surgeries (comma-separated)',
                            Icons.medical_services_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveProfile,
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
                            Icon(Icons.save_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSection({
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(
                icon,
                size: 20,
                color: Colors.grey[600],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ColorPalette.primaryColor,
          ),
        ],
      ),
    );
  }
}