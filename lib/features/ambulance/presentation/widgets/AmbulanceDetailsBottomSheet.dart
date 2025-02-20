import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/Ambulance.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';

class AmbulanceDetailsBottomSheet extends StatelessWidget {
  final Ambulance ambulance;
  final AmbulanceService _ambulanceService = AmbulanceService(); // Initialize Service

   AmbulanceDetailsBottomSheet({
    Key? key,
    required this.ambulance,
  }) : super(key: key);

  // ✅ Call Ambulance Service (Trigger Call & SMS)
  void _callAmbulance(BuildContext context) {
    _ambulanceService.triggerAmbulanceEmergency(ambulance.contact);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ambulance Name
              Text(
                ambulance.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Availability
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Availability: ${ambulance.availability}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Contact Number
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    ambulance.contact,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Services Offered
              const Text(
                "Services Offered:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ambulance.services
                    .map((service) => Chip(
                  label: Text(service),
                  backgroundColor: Colors.blue[100],
                ))
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Call Ambulance Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _callAmbulance(context),
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text("Call Ambulance", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Close Button (Top Right Corner)
        Positioned(
          top: -50,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 24, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
