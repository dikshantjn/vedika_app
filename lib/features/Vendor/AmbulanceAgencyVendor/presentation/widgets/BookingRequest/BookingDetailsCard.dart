import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
class BookingDetailsCard extends StatelessWidget {
  final AmbulanceBooking booking; // ✅ make it final

  const BookingDetailsCard({super.key, required this.booking});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Handle error - could show a snackbar or dialog
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.lighterPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow("Customer Name", booking.user.name ?? "-"),
          _buildPhoneRow("Phone", booking.user.phoneNumber!),
          _buildDetailRow("Requested On",
              DateFormat('d MMM yyyy, h:mm a').format(booking.timestamp)),
          _buildStatusRow("Status", booking.status),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String title, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phoneNumber,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _makeCall(phoneNumber),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.phone,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String title, String status) {
    final displayStatus = _getDisplayStatus(status);
    Color statusColor;
    Color backgroundColor;

    switch (status.toLowerCase()) {
      case 'paymentcompleted':
        statusColor = Colors.green;
        backgroundColor = Colors.green.shade100;
        break;
      case 'completed':
        statusColor = Colors.blue;
        backgroundColor = Colors.blue.shade100;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        backgroundColor = Colors.red.shade100;
        break;
      default:
        statusColor = Colors.orange;
        backgroundColor = Colors.orange.shade100;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              displayStatus,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'paymentcompleted':
        return 'Payment Completed';
      default:
        return status;
    }
  }
}