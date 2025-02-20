import 'package:flutter/material.dart';

class HospitalInfoCard extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const HospitalInfoCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[100], // Light color for the card background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with hospital logo or person icon
              Row(
                children: [
                  hospital['logo'] != null
                      ? Image.network(
                    hospital['logo'], // Assuming 'logo' is a URL
                    width: 28,
                    height: 28,
                  )
                      : Icon(Icons.local_hospital, size: 28, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    hospital['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Hospital address
              Text(
                hospital['address'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),

              // Contact info
              Text(
                'Contact: ${hospital['contact']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),

              // Specialties as separate chips with background color
              Wrap(
                spacing: 8.0,
                children: List<Widget>.from(
                  (hospital['specialties'] ?? [])
                      .map<Widget>((specialty) => Chip(
                    label: Text(specialty),
                    backgroundColor: Color(0xFFB6DADA), // Light green background
                    labelStyle: TextStyle(color: Colors.black),
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
