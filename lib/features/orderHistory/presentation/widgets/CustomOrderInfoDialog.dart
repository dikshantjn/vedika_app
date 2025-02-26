import 'package:flutter/material.dart';

class CustomOrderInfoDialog extends StatelessWidget {
  final String orderNumber;
  final List<String> imageUrls;
  final String date;
  final String status;
  final String total;
  final String items;

  const CustomOrderInfoDialog({
    Key? key,
    required this.orderNumber,
    required this.imageUrls,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Added to make the dialog scrollable if content is large
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Center(
                child: Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              Divider(height: 32.0, thickness: 1, color: Colors.grey[300]),

              // Order Details
              _buildInfoRow('Order Number:', orderNumber),
              _buildInfoRow('Date:', date),
              _buildInfoRow('Total:', total, isTotal: true),
              _buildInfoRow('Items:', items),

              SizedBox(height: 20.0),

              // Status Section with Chip
              _buildInfoRow('Status:', '', widget: _buildStatusChip(status)),

              SizedBox(height: 20.0),

              // Images Section
              Text(
                'Images:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(
                height: 200.0,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: 100.0,
                        height: 100.0,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.0),

              // Close Button
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

  // Function to build key-value rows
  Widget _buildInfoRow(String key, String value, {bool isTotal = false, Widget? widget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              ),
        ],
      ),
    );
  }

  // Function to display status with a color chip
  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'shipped':
        chipColor = Colors.orange;
        break;
      case 'processing':
        chipColor = Colors.blue;
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
