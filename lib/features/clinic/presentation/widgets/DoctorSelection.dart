import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';

class DoctorSelection extends StatelessWidget {
  final List<Doctor> doctors;  // List of doctors
  final Doctor? selectedDoctor;  // The currently selected doctor
  final Function(Doctor) onDoctorSelected;  // Callback function to handle doctor selection

  const DoctorSelection({
    Key? key,
    required this.doctors,
    this.selectedDoctor,
    required this.onDoctorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Doctor",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        // Display doctors in a ListView with modern box style
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final isSelected = selectedDoctor?.name == doctor.name;
            return GestureDetector(
              onTap: () => onDoctorSelected(doctor),  // Handle tap to select doctor
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal.shade100 : Colors.white,  // Highlight selected doctor
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Doctor's Picture (Placeholder Image)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        doctor.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Doctor's Name and Specialization
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black54 : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          doctor.specialization,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.black54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
