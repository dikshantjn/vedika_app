import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class HospitalInfoCard extends StatelessWidget {
  final HospitalProfile hospital;
  const HospitalInfoCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel for Hospital Images
            if (hospital.photos.isNotEmpty)
              CarouselSlider(
                items: hospital.photos.map<Widget>((photo) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: photo['url'] ?? '',
                            fit: BoxFit.cover,
                            height: 200,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
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
            // Hospital Name
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.teal, size: 28),
                SizedBox(width: 8),
                Text(hospital.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            // Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${hospital.address}, ${hospital.landmark}\n${hospital.city}, ${hospital.state} - ${hospital.pincode}',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Contact Information
            Row(
              children: [
                Icon(Icons.phone, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text("Phone: ${hospital.contactNumber}", style: TextStyle(fontSize: 16)),
              ],
            ),
            if (hospital.email.isNotEmpty) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.teal, size: 24),
                  SizedBox(width: 8),
                  Text("Email: ${hospital.email}", style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
            if (hospital.website != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.web, color: Colors.teal, size: 24),
                  SizedBox(width: 8),
                  Text("Website: ${hospital.website}", style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
            SizedBox(height: 8),
            // Specialties
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Specialties: ${hospital.specialityTypes.join(', ')}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Services
            Row(
              children: [
                Icon(Icons.medical_information, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Services: ${hospital.servicesOffered.join(', ')}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Facilities
            Wrap(
              spacing: 8,
              children: [
                if (hospital.hasLiftAccess)
                  Chip(
                    label: Text('Lift Access'),
                    backgroundColor: Colors.teal.shade50,
                  ),
                if (hospital.hasParking)
                  Chip(
                    label: Text('Parking'),
                    backgroundColor: Colors.teal.shade50,
                  ),
                if (hospital.hasWheelchairAccess)
                  Chip(
                    label: Text('Wheelchair Access'),
                    backgroundColor: Colors.teal.shade50,
                  ),
                if (hospital.providesAmbulanceService)
                  Chip(
                    label: Text('Ambulance Service'),
                    backgroundColor: Colors.teal.shade50,
                  ),
                if (hospital.providesOnlineConsultancy)
                  Chip(
                    label: Text('Online Consultancy'),
                    backgroundColor: Colors.teal.shade50,
                  ),
              ],
            ),
            SizedBox(height: 8),
            // Working Hours
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text(
                  "Working Hours: ${hospital.workingTime} (${hospital.workingDays})",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Beds Available
            Row(
              children: [
                Icon(Icons.bed, color: Colors.teal, size: 24),
                SizedBox(width: 8),
                Text(
                  "Beds Available: ${hospital.bedsAvailable}",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (hospital.insuranceCompanies.isNotEmpty) ...[
              SizedBox(height: 8),
              // Insurance Companies
              Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.teal, size: 24),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Insurance: ${hospital.insuranceCompanies.join(', ')}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
