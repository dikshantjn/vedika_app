import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class DoctorSelection extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;
  final Map<String, dynamic>? selectedDoctor;
  final Function(Map<String, dynamic>) onDoctorSelected;

  const DoctorSelection({
    required this.doctors,
    required this.selectedDoctor,
    required this.onDoctorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the whole content scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          doctors.isNotEmpty
              ? SingleChildScrollView(  // Add horizontal scrolling
            scrollDirection: Axis.horizontal,  // Enable horizontal scrolling
            child: Row(
              children: doctors.map((doctor) {
                bool isSelected = selectedDoctor == doctor;

                return GestureDetector(
                  onTap: () => onDoctorSelected(doctor),
                  child: Card(
                    color: isSelected ? Colors.blue.shade50 : Colors.green.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4, // Add elevation for better card appearance
                    margin: EdgeInsets.symmetric(horizontal: 8), // Space between cards
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Doctor's Image
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            backgroundImage: doctor['imageUrl'] != null
                                ? NetworkImage(doctor['imageUrl'])
                                : null,
                            child: doctor['imageUrl'] == null
                                ? Icon(Icons.person, size: 50, color: Colors.white)
                                : null,
                          ),
                          SizedBox(height: 8),
                          // Doctor's Name
                          Text(
                            doctor['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          // Doctor's Specialization
                          Text(
                            doctor['specialization'],
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          // View Profile Button
                          ElevatedButton(
                            onPressed: () {
                              // Add your "View Profile" logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primaryColor, // Button color
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("View Profile", style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
              : Text("No doctors available", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
