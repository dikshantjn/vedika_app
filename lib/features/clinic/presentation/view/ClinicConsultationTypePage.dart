import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';

class ClinicConsultationTypePage extends StatelessWidget {
  final Clinic? clinic;

  const ClinicConsultationTypePage({Key? key, this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'Choose Consultation Type',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: DoctorConsultationColorPalette.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'How would you like to consult?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the type of consultation that works best for you',
                style: TextStyle(
                  fontSize: 14,
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _buildConsultationOption(
                context,
                'In-Clinic Consultation',
                'Visit the doctor in person at the clinic for a face-to-face consultation. Get a thorough check-up and personalized care.',
                Icons.local_hospital,
                'assets/images/clinic_visit.png',
                DoctorConsultationColorPalette.primaryGradient,
                () {
                  if (clinic != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.clinicSearch,
                      arguments: clinic,
                    );
                  } else {
                    Navigator.pushNamed(context, AppRoutes.clinicSearch);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildConsultationOption(
                context,
                'Online Consultation',
                'Consult with qualified doctors from the comfort of your home. Get medical advice, prescriptions, and follow-ups online.',
                Icons.videocam,
                'assets/images/video_call.png',
                DoctorConsultationColorPalette.secondaryGradient,
                () {
                  Navigator.pushNamed(context, AppRoutes.onlineDoctorConsultation);
                },
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.backgroundCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DoctorConsultationColorPalette.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: DoctorConsultationColorPalette.infoBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: DoctorConsultationColorPalette.infoBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Not sure which one to choose?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Online consultations are great for minor issues, follow-ups, and when you cannot visit the clinic. In-clinic visits are recommended for physical examinations and complex health issues.',
                      style: TextStyle(
                        fontSize: 14,
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String imagePath,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title == 'Online Consultation' ? 'Available 24/7' : 'Subject to clinic hours',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: title == 'Online Consultation' 
                                  ? DoctorConsultationColorPalette.successGreen
                                  : DoctorConsultationColorPalette.warningYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: title == 'Online Consultation'
                          ? DoctorConsultationColorPalette.secondaryTeal
                          : DoctorConsultationColorPalette.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title == 'Online Consultation' ? 'Consult Now' : 'Book Appointment',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 