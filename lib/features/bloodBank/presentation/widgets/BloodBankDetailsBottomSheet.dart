import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/bloodBank/data/models/BloodBank.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankDetailsBottomSheet extends StatelessWidget {
  final BloodBank bloodBank;
  final Function(LatLng) onGetDirections;

  const BloodBankDetailsBottomSheet({
    Key? key,
    required this.bloodBank,
    required this.onGetDirections,
  }) : super(key: key);

  // Function to make a call
  void _callBloodBank(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch call");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(minHeight: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blood Bank Name
              Text(
                bloodBank.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bloodBank.address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Contact
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    bloodBank.contact,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Available Blood Types Section
              const Text(
                "Available Blood Types",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 6),

              // Blood Group List
              bloodBank.availableBlood.isNotEmpty
                  ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bloodBank.availableBlood.map((blood) {
                  return Chip(
                    label: Text(
                      "${blood.group}: ${blood.units} units",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.red.shade100,
                  );
                }).toList(),
              )
                  : const Text("No blood stock available.", style: TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              // Buttons (Call & Get Directions)
              Row(
                children: [
                  // Call Blood Bank Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callBloodBank(bloodBank.contact),
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text("Call Blood Bank"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Get Directions Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onGetDirections(bloodBank.location),
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text("Get Directions"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Close Button
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
