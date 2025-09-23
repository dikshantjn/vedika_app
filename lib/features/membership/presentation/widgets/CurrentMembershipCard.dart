import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import '../../data/models/MembershipPlan.dart';

class CurrentMembershipCard extends StatelessWidget {
  final UserMembership membership;

  const CurrentMembershipCard({
    Key? key,
    required this.membership,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon = membership.daysRemaining <= 30 && membership.daysRemaining > 0;
    final isExpired = membership.isExpired;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExpired
              ? [Colors.grey[400]!, Colors.grey[600]!]
              : isExpiringSoon
                  ? [Colors.orange[400]!, Colors.orange[600]!]
                  : [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isExpired 
                ? Colors.grey 
                : isExpiringSoon 
                    ? Colors.orange 
                    : Colors.green)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          _buildStatusInfo(),
          SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            membership.isExpired 
                ? Icons.cancel
                : Icons.verified_user,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Current Plan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                membership.planName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isExpired = membership.isExpired;
    final isExpiringSoon = membership.daysRemaining <= 30 && membership.daysRemaining > 0;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isExpired) {
      badgeColor = Colors.red;
      badgeText = 'Expired';
      badgeIcon = Icons.cancel;
    } else if (isExpiringSoon) {
      badgeColor = Colors.orange;
      badgeText = 'Expiring Soon';
      badgeIcon = Icons.warning;
    } else {
      badgeColor = Colors.green;
      badgeText = 'Active';
      badgeIcon = Icons.check_circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    final isExpired = membership.isExpired;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Plan Start Date',
            _formatDate(membership.startDate),
            Icons.calendar_today,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Plan End Date',
            _formatDate(membership.endDate),
            Icons.event,
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            isExpired ? 'Expired' : 'Days Remaining',
            isExpired ? '${DateTime.now().difference(membership.endDate).inDays} days ago' : '${membership.daysRemaining} days',
            isExpired ? Icons.cancel : Icons.access_time,
          ),
          if (membership.lastPaymentDate != null) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              'Last Payment',
              _formatDate(membership.lastPaymentDate!),
              Icons.payment,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isExpired = membership.isExpired;
    final isExpiringSoon = membership.daysRemaining <= 30 && membership.daysRemaining > 0;

    return Row(
      children: [
        if (isExpired || isExpiringSoon)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showRenewalDialog(context),
              icon: Icon(Icons.refresh, size: 18),
              label: Text(isExpired ? 'Renew Plan' : 'Renew Early'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ColorPalette.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (isExpired || isExpiringSoon) SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showMembershipDetails(context),
            icon: Icon(Icons.info_outline, size: 18),
            label: Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.8)),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRenewalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renew Membership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to renew your ${membership.planName}?'),
            SizedBox(height: 16),
            Text(
              'Benefits:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Extended coverage for another year'),
            Text('• Continue enjoying all plan benefits'),
            Text('• No interruption in services'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPaymentMethodDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primaryColor,
            ),
            child: Text('Renew Now'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Credit/Debit Card'),
              onTap: () {
                Navigator.of(context).pop();
                _processRenewal(context, 'card');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('UPI Payment'),
              onTap: () {
                Navigator.of(context).pop();
                _processRenewal(context, 'upi');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Net Banking'),
              onTap: () {
                Navigator.of(context).pop();
                _processRenewal(context, 'netbanking');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processRenewal(BuildContext context, String paymentMethod) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing renewal...'),
          ],
        ),
      ),
    );

    // Simulate processing
    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membership renewed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showMembershipDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Membership Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Plan Name', membership.planName),
              _buildDetailRow('Status', membership.status.toUpperCase()),
              _buildDetailRow('Start Date', _formatDate(membership.startDate)),
              _buildDetailRow('End Date', _formatDate(membership.endDate)),
              _buildDetailRow('Amount Paid', '₹${membership.amountPaid.toStringAsFixed(0)}'),
              _buildDetailRow('Payment Method', membership.paymentMethod.toUpperCase()),
              if (membership.lastPaymentDate != null)
                _buildDetailRow('Last Payment', _formatDate(membership.lastPaymentDate!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
