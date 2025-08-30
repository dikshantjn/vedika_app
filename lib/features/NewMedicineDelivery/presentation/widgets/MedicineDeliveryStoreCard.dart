import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';

class MedicineDeliveryStoreCard extends StatelessWidget {
  final VendorMedicalStoreProfile store;
  final VoidCallback onTap;

  const MedicineDeliveryStoreCard({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildDetails(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStoreAvatar(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreName(),
                SizedBox(height: 4),
                _buildStoreAddress(),
                SizedBox(height: 8),
                _buildRatingAndReviews(),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStoreAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.local_pharmacy,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildStoreName() {
    return Row(
      children: [
        Expanded(
          child: Text(
            store.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // TODO: Add verification badge when available in API
      ],
    );
  }

  Widget _buildStoreAddress() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            '${store.address}, ${store.city}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndReviews() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: Colors.amber[600],
              ),
              SizedBox(width: 2),
              Text(
                '4.5', // TODO: Get from API when available
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          '(0 reviews)', // TODO: Get from API when available
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        'Open', // TODO: Get from API when available
        style: TextStyle(
          fontSize: 10,
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildDetailItem(
            icon: Icons.access_time,
            label: 'Timing',
            value: store.storeTiming,
            color: Colors.blue,
          ),
          SizedBox(width: 16),
          _buildDetailItem(
            icon: Icons.medication,
            label: 'Type',
            value: store.medicineType,
            color: Colors.green,
          ),
          SizedBox(width: 16),
          _buildDetailItem(
            icon: Icons.phone,
            label: 'Contact',
            value: store.contactNumber,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatures(),
          ),
          SizedBox(width: 12),
          _buildOrderButton(),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (store.isOnlinePayment)
          _buildFeatureChip('Online Payment', Icons.payment, Colors.green),
        if (store.isLiftAccess)
          _buildFeatureChip('Lift Access', Icons.elevator, Colors.blue),
        if (store.isWheelchairAccess)
          _buildFeatureChip('Wheelchair', Icons.accessible, Colors.purple),
        if (store.isParkingAvailable)
          _buildFeatureChip('Parking', Icons.local_parking, Colors.orange),
        if (store.isRareMedicationsAvailable)
          _buildFeatureChip('Rare Meds', Icons.medication, Colors.red),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return Container(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          'Order Now',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
