import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ClinicInfoCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicInfoCard({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.shade100,  // Filled card with a soft color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel for Clinic Images
            CarouselSlider(
              items: clinic.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),  // Fetching image from the URL
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 200,
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
              ),
            ),
            SizedBox(height: 16),
            // Clinic Name
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.teal, size: 28),
                SizedBox(width: 8),
                Text(clinic.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            // Address in Italic (Allow wrapping of the address text)
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    clinic.address,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Contact Number
            Row(
              children: [
                Icon(Icons.phone, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text("Phone: ${clinic.contact}", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            // Specialties
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text("Specialties: ${clinic.specialties.join(', ')}", style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
