import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';

class DraggableClinicList extends StatelessWidget {
  final List<Clinic> clinics;
  final List<bool> expandedItems;
  final Function(int, double, double) onClinicTap;

  DraggableClinicList({
    required this.clinics,
    required this.expandedItems,
    required this.onClinicTap,
  });

  Widget buildDetailRow(IconData icon, String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueGrey[600], size: 16),
              SizedBox(width: 8),
              Text(
                key,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorChip(Doctor doctor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${doctor.name} - ${doctor.specialization}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[800],
            ),
          ),
          Text(
            "Fee: ₹${doctor.fee} | Slots: ${doctor.timeSlots.join(", ")}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  margin: EdgeInsets.only(top: 4, bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                "Nearby Clinics",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              if (clinics.isEmpty || clinics.length != expandedItems.length)
                Flexible(
                  child: Center(
                    child: Text(
                      "No clinics found nearby or matching your search.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: clinics.length,
                    itemBuilder: (_, index) {
                      var clinic = clinics[index];
                      bool isExpanded = expandedItems[index];

                      return GestureDetector(
                        onTap: () => onClinicTap(index, clinic.lat, clinic.lng),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      clinic.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Colors.blueGrey[600],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.blueGrey[600], size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      clinic.address,
                                      style: TextStyle(color: Colors.blueGrey[600], fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                Divider(color: Colors.blueGrey[300]),
                                buildDetailRow(Icons.phone, "Phone:", clinic.contact),
                                buildDetailRow(Icons.health_and_safety, "Specialties:", clinic.specialties.join(", ")),
                                Divider(color: Colors.blueGrey[300]),
                                SizedBox(height: 10),
                                Text(
                                  "Doctors",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: clinic.doctors
                                      .map<Widget>((doctor) => buildDoctorChip(doctor))
                                      .toList(),
                                ),
                                SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Push to the Book Appointment screen with clinic data
                                    Navigator.pushNamed(
                                      context,
                                      '/bookClinicAppointment',
                                      arguments: clinic,
                                    );
                                  },
                                  icon: Icon(Icons.bookmark_outline_sharp, color: Colors.white),
                                  label: Text("Book Appointment"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
