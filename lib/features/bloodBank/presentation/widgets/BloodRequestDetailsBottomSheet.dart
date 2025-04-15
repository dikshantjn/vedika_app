import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import '../../../../../core/constants/colorpalette/ColorPalette.dart';

class BloodRequestDetailsBottomSheet extends StatelessWidget {
  final BloodBankBooking booking;
  final VoidCallback? onCallBloodBank;

  const BloodRequestDetailsBottomSheet({
    Key? key,
    required this.booking,
    this.onCallBloodBank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedCreatedAt = DateFormat("dd MMMM yyyy hh:mm a").format(booking.createdAt);
    final formattedScheduledDate = booking.scheduledDate != null
        ? DateFormat("dd MMMM yyyy hh:mm a").format(booking.scheduledDate!)
        : "N/A";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

              // Success Icon
              Center(
                child: Icon(Icons.bloodtype_rounded, size: 32, color: Colors.red),
              ),
              const SizedBox(height: 8),

              // Title
              Center(
                child: Text(
                  "Ongoing Blood Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              _buildInfoRow(Icons.person, "Customer Name", booking.user.name ?? "Not Mentioned"),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.bloodtype_outlined, "Blood Types", booking.bloodType.join(", ")),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.format_list_numbered, "Units Required", booking.units.toString()),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.local_hospital, "Health Issue", booking.healthIssue),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on, "Delivery Location", booking.deliveryLocation),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, "Requested On", formattedCreatedAt),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_alarm, "Scheduled For", formattedScheduledDate),
              const SizedBox(height: 24),

              _buildStatusTimeline(booking.status),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCallBloodBank,
                  icon: const Icon(Icons.call),
                  label: const Text("Call Blood Bank"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: ColorPalette.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(String status) {
    final steps = ["Pending", "Confirmed", "Dispatched", "Completed"];
    final currentIndex = steps.indexOf(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isDone = index <= currentIndex;

        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isDone ? Colors.green : Colors.grey.shade300,
              child: Icon(Icons.check, size: 14, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(step, style: TextStyle(fontSize: 12, color: isDone ? Colors.green : Colors.grey)),
          ],
        );
      }).toList(),
    );
  }
}
