import 'package:flutter/material.dart';

class CustomAmbulanceOrderInfoDialog extends StatelessWidget {
  final String orderNumber;
  final List<String> imageUrls;
  final String date;
  final String status;
  final String total;
  final String serviceType;

  const CustomAmbulanceOrderInfoDialog({
    Key? key,
    required this.orderNumber,
    required this.imageUrls,
    required this.date,
    required this.status,
    required this.total,
    required this.serviceType,
  }) : super(key: key);

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
                  'Ambulance Order Details',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              Divider(height: 24.0, thickness: 1, color: Colors.grey[300]),
              _buildInfoRow('Order Number:', orderNumber),
              _buildInfoRow('Date:', date),
              _buildInfoRow('Total:', total, isTotal: true),
              _buildInfoRow('Service Type:', serviceType),
              SizedBox(height: 10.0),
              _buildInfoRow('Status:', '', widget: _buildStatusChip(status)),
              SizedBox(height: 10.0),
              if (imageUrls.isNotEmpty) ...[
                Text(
                  'Images:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 8.0),
                SizedBox(
                  height: (imageUrls.length / 3).ceil() * 100.0,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.0),
              ],
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
              ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    print("Status : $status");
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'ongoing':
        chipColor = Colors.orange;
        break;
      case 'pending':
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
