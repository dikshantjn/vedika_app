import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/LabTestOrder.dart';

class CustomLabTestOrderInfoDialog extends StatelessWidget {
  final LabTestOrder order;

  const CustomLabTestOrderInfoDialog({Key? key, required this.order}) : super(key: key);

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
                  'Lab Test Order Details',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              Divider(height: 24.0, thickness: 1, color: Colors.grey[300]),
              _buildInfoRow('Order Number:', order.orderNumber),
              _buildInfoRow('Lab Name:', order.labName),
              _buildTestNames(order.testNames),
              _buildInfoRow('Date:', order.date),
              _buildInfoRow('Total:', order.total, isTotal: true),
              SizedBox(height: 10.0),
              _buildInfoRow('Status:', '', widget: _buildStatusChip(order.status)),
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
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
              Text(
                value,
                style: TextStyle(
                  fontSize: isTotal ? 18.0 : 16.0,
                  color: isTotal ? Colors.green[700] : Colors.grey[800],
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
              ),
        ],
      ),
    );
  }

  Widget _buildTestNames(List<String> testNames) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Names:',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.0),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: testNames.map((test) => _buildTestChip(test)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestChip(String testName) {
    return Chip(
      label: Text(
        testName,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blueGrey,
      shape: StadiumBorder(),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
      backgroundColor: chipColor,
      shape: StadiumBorder(),
    );
  }
}