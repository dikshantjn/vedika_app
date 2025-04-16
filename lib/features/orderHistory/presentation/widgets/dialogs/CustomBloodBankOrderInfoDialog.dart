import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';

class CustomBloodBankOrderInfoDialog extends StatelessWidget {
  final BloodBankBooking booking;

  const CustomBloodBankOrderInfoDialog({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 12,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Blood Bank Booking Details',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              const Divider(height: 24.0, thickness: 1, color: Colors.grey),
              _buildInfoRow('Booking ID:', booking.bookingId ?? 'N/A'),
              _buildInfoRow('Blood Type:', booking.bloodType.join(", ")),
              _buildInfoRow('Units Required:', booking.units.toString()),
              _buildInfoRow('Date:', booking.createdAt.toString().split(' ')[0]),
              _buildInfoRow('Total Amount:', '₹${booking.totalAmount.toStringAsFixed(2)}', isTotal: true),
              if (booking.discount != null && booking.discount! > 0)
                _buildInfoRow('Discount:', '₹${booking.discount!.toStringAsFixed(2)}'),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildInfoRow('Notes:', booking.notes!),
              const SizedBox(height: 10.0),
              _buildInfoRow('Status:', '', widget: _buildStatusChip(booking.status)),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String key, String value, {bool isTotal = false, Widget? widget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          widget ??
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isTotal ? 18.0 : 16.0,
                      color: isTotal ? Colors.green[700] : Colors.grey[800],
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
      backgroundColor: chipColor,
      shape: const StadiumBorder(),
    );
  }
}
