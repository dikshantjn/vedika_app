import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class ServiceDetailsCard extends StatelessWidget {
  final AmbulanceBooking booking;
  final bool isFilled;

  const ServiceDetailsCard({
    super.key,
    required this.booking,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFilled) {
      return Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(
            "No service details added yet.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (booking.isPaymentBypassed) ...[
          // Payment Bypass Information
          _buildInfoRow(
            "Payment Status",
            "Payment Waived",
            icon: Icons.money_off,
            valueColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Payment Waived Reason",
            booking.bypassReason ?? "N/A",
            icon: Icons.description,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Approved By",
            booking.bypassApprovedBy ?? "N/A",
            icon: Icons.person,
          ),
          if (booking.bypassDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              "Payment Waived Date",
              _formatDate(booking.bypassDate!),
              icon: Icons.calendar_today,
            ),
          ],
        ] else ...[
          // Regular Service Details
          _buildInfoRow(
            "Pickup Location",
            booking.pickupLocation,
            icon: Icons.location_on,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Drop Location",
            booking.dropLocation,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Vehicle Type",
            booking.vehicleType,
            icon: Icons.local_taxi,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Distance",
            "${booking.totalDistance} km",
            icon: Icons.route,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Cost per KM",
            "₹${booking.costPerKm}",
            icon: Icons.currency_rupee,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Base Charge",
            "₹${booking.baseCharge}",
            icon: Icons.price_change,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Total Amount",
            "₹${booking.totalAmount}",
            icon: Icons.payment,
            valueColor: Colors.green[700],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}
