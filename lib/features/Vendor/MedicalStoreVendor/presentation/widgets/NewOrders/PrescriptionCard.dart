import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/NewOrders/PrescriptionPreviewScreen.dart';

class PrescriptionCard extends StatefulWidget {
  final Prescription prescription;
  final Future<Map<String, dynamic>?> Function(String) onAccept;
  final Future<Map<String, dynamic>?> Function(String) onReject;

  const PrescriptionCard({
    Key? key,
    required this.prescription,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  State<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<PrescriptionCard> {
  bool _isExpanded = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: ColorPalette.primaryColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prescription.userName ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.prescription.userPhone ?? 'No Contact number',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.prescription.userPhone != null && widget.prescription.userPhone!.isNotEmpty) ...[
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: IconButton(
                    onPressed: () => _makeCall(widget.prescription.userPhone!),
                    icon: Icon(
                      Icons.phone,
                      color: Colors.green[600],
                      size: 18,
                    ),
                    padding: EdgeInsets.all(6),
                    constraints: BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              ],
              SizedBox(width: 8),
              _buildStatusChip(),
            ],
          ),
          SizedBox(height: 12),
          _buildPrescriptionDetails(),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[500],
              ),
              SizedBox(width: 8),
              Text(
                _formatDateTime(widget.prescription.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.prescription.prescriptionFiles.isNotEmpty) ...[
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded ? 'Show Less' : 'Show More',
                        style: TextStyle(
                          color: ColorPalette.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 18,
                        color: ColorPalette.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;
    String statusText;

    switch (widget.prescription.status) {
      case 'pending':
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        statusText = 'Pending';
        break;
      case 'verified':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        statusText = 'Verified';
        break;
      case 'rejected':
        chipColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        statusText = 'Rejected';
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: ColorPalette.primaryColor,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.prescription.userName ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.prescription.userPhone ?? 'No Contact number',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (widget.prescription.userPhone != null && widget.prescription.userPhone!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: IconButton(
                onPressed: () => _makeCall(widget.prescription.userPhone!),
                icon: Icon(
                  Icons.phone,
                  color: Colors.green[600],
                  size: 18,
                ),
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.prescription.quantityPreference != null) ...[
          _buildDetailRow(
            'Quantity Preference',
            widget.prescription.quantityPreference!,
            Icons.medication,
          ),
          SizedBox(height: 12),
        ],
        if (widget.prescription.skipNotes != null) ...[
          _buildDetailRow(
            'Skip Notes',
            widget.prescription.skipNotes!,
            Icons.block,
          ),
          SizedBox(height: 12),
        ],
        if (widget.prescription.generalProduct != null && widget.prescription.generalProduct!.trim().isNotEmpty) ...[
          _buildDetailRow(
            'General Products',
            widget.prescription.generalProduct!,
            Icons.shopping_bag,
          ),
          SizedBox(height: 12),
        ],
        if (widget.prescription.prescriptionFiles.isNotEmpty)
          _buildDetailRow(
            'Files',
            '${widget.prescription.prescriptionFiles.length} prescription file(s)',
            Icons.attach_file,
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.prescription.prescriptionFiles.isNotEmpty) ...[
            Divider(color: Colors.grey[200]),
            SizedBox(height: 12),
            Text(
              'Prescription Files',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            ...widget.prescription.prescriptionFiles.map((file) => _buildFileItem(file)),
          ],
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileUrl) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image,
            color: Colors.blue[600],
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              fileUrl.split('/').last,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _viewPrescription(fileUrl),
            icon: Icon(
              Icons.visibility,
              color: ColorPalette.primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.prescription.status != 'pending') {
      return Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: widget.prescription.status == 'verified' 
                      ? Colors.green[50] 
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.prescription.status == 'verified' 
                        ? Colors.green[200]! 
                        : Colors.red[200]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.prescription.status == 'verified' 
                        ? 'Prescription Accepted' 
                        : 'Prescription Rejected',
                    style: TextStyle(
                      color: widget.prescription.status == 'verified' 
                          ? Colors.green[700] 
                          : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _rejectPrescription(),
              icon: Icon(Icons.close, size: 16),
              label: Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: Colors.red[400]!),
                foregroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _acceptPrescription(),
              icon: Icon(Icons.check, size: 16),
              label: Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewPrescription(String fileUrl) {
    final String name = Uri.tryParse(fileUrl)?.pathSegments.isNotEmpty == true
        ? Uri.parse(fileUrl).pathSegments.last
        : fileUrl.split('/').last;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionPreviewScreen(fileUrl: fileUrl, fileName: name),
      ),
    );
  }

  void _acceptPrescription() async {
    // Note is optional, can be empty string
    final note = _noteController.text.trim();
    final result = await widget.onAccept(note);
    
    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;
    
    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Prescription accepted successfully!'),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept prescription. Please try again.'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _rejectPrescription() async {
    // Note is optional, can be empty string
    final note = _noteController.text.trim();
    final result = await widget.onReject(note);
    
    // Check if widget is still mounted before showing snackbar
    if (!mounted) return;
    
    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Prescription rejected successfully!'),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject prescription. Please try again.'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not make call to $phoneNumber'),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
