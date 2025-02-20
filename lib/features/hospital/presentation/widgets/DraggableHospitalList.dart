import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';

class DraggableHospitalList extends StatelessWidget {
  final List<Map<String, dynamic>> hospitals;
  final List<bool> expandedItems;
  final Function(int, double, double) onHospitalTap;

  DraggableHospitalList({
    required this.hospitals,
    required this.expandedItems,
    required this.onHospitalTap,
  });

  Widget buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[400],
              fontSize: 14,
            ),
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

  Widget buildDoctorChip(Map<String, dynamic> doctor) {
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
            "${doctor["name"]} - ${doctor["specialization"]}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[800],
            ),
          ),
          Text(
            "Fee: ₹${doctor["fee"]} | Slots: ${doctor["timeSlots"].join(", ")}",
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
                "🏥 Nearby Hospitals",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              if (hospitals.isEmpty || hospitals.length != expandedItems.length)
                Flexible(
                  child: Center(
                    child: Text(
                      "No hospitals found nearby or matching your search.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: hospitals.length,
                    itemBuilder: (_, index) {
                      var hospital = hospitals[index];
                      bool isExpanded = expandedItems[index];

                      return GestureDetector(
                        onTap: () => onHospitalTap(index, hospital["lat"], hospital["lng"]),
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
                                      hospital["name"],
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
                              SizedBox(height: 8),
                              Text(
                                "📍 ${hospital["address"]}",
                                style: TextStyle(color: Colors.blueGrey[600], fontSize: 14),
                              ),
                              if (isExpanded) ...[
                                Divider(color: Colors.blueGrey[300]),
                                buildDetailRow("📞 Phone:", hospital["contact"]),
                                buildDetailRow("✉ Email:", hospital["email"]),
                                buildDetailRow("🌐 Website:", hospital["website"]),
                                buildDetailRow("🩺 Specialties:", hospital["specialties"].join(", ")),
                                buildDetailRow("🏥 Available Beds:", "${hospital["beds"]}"),
                                buildDetailRow("⭐ Ratings:", "${hospital["ratings"]} ⭐"),
                                buildDetailRow("🛠 Services:", hospital["services"].join(", ")),
                                buildDetailRow("⏰ Visiting Hours:", hospital["visitingHours"]),
                                buildDetailRow("🛡 Insurance:", hospital["insuranceProviders"].join(", ")),
                                buildDetailRow("🔬 Labs:", hospital["labs"].join(", ")),
                                Divider(color: Colors.blueGrey[300]),
                                SizedBox(height: 10),
                                Text(
                                  "👨‍⚕️ Doctors",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: hospital["doctors"]
                                      .map<Widget>((doctor) => buildDoctorChip(doctor))
                                      .toList(),
                                ),
                                SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.bookAppoinment,
                                      arguments: hospital,
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
