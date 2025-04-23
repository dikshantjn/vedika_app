import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';

class CustomClinicAppointmentInfoDialog extends StatelessWidget {
  final ClinicAppointment appointment;

  const CustomClinicAppointmentInfoDialog({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(appointment.date);
    final doctorName = appointment.doctor?.doctorName ?? 'Unknown Doctor';
    final specialization = appointment.doctor?.specializations.isNotEmpty == true
        ? appointment.doctor!.specializations.first
        : 'Specialist';
    final consultationType = appointment.isOnline ? 'Online Consultation' : 'In-clinic Visit';
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DoctorConsultationColorPalette.shadowMedium,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildDoctorInfo(doctorName, specialization),
            SizedBox(height: 20),
            _buildAppointmentDetails(formattedDate, consultationType),
            SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medical_services,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(appointment.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            appointment.status.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(String doctorName, String specialization) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
          backgroundImage: appointment.doctor?.profilePicture != null && 
                          appointment.doctor!.profilePicture.isNotEmpty
              ? NetworkImage(appointment.doctor!.profilePicture)
              : null,
          child: appointment.doctor?.profilePicture == null || 
                appointment.doctor!.profilePicture.isEmpty
              ? Icon(
                  Icons.person, 
                  size: 35, 
                  color: DoctorConsultationColorPalette.primaryBlue,
                )
              : null,
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                specialization,
                style: TextStyle(
                  fontSize: 14,
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
              if (appointment.doctor?.experienceYears != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${appointment.doctor!.experienceYears} years of experience',
                    style: TextStyle(
                      fontSize: 13,
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails(String formattedDate, String consultationType) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Appointment ID:', appointment.clinicAppointmentId.substring(0, 8)),
          Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
          _buildInfoRow('Date:', formattedDate),
          Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
          _buildInfoRow('Time:', appointment.time),
          Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
          _buildInfoRow('Type:', consultationType),
          Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
          _buildInfoRow('Fee:', '₹${appointment.paidAmount}', isTotal: true),
          Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
          _buildInfoRow('Payment Status:', appointment.paymentStatus.toUpperCase()),
          if (appointment.isOnline && appointment.meetingUrl != null && appointment.meetingUrl!.isNotEmpty) ...[
            Divider(height: 20, color: DoctorConsultationColorPalette.borderLight),
            _buildInfoRow('Meeting URL:', appointment.meetingUrl!, isUrl: true),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(String key, String value, {bool isTotal = false, bool isUrl = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            key,
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal 
                  ? DoctorConsultationColorPalette.primaryBlue 
                  : isUrl 
                      ? DoctorConsultationColorPalette.infoBlue 
                      : DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    bool canCancel = appointment.status.toLowerCase() == 'pending' || 
                    appointment.status.toLowerCase() == 'confirmed';
    bool canJoin = appointment.isOnline && 
                  appointment.meetingUrl != null && 
                  appointment.meetingUrl!.isNotEmpty &&
                  (appointment.status.toLowerCase() == 'confirmed');
                  
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
          style: TextButton.styleFrom(
            foregroundColor: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
        if (canJoin)
          ElevatedButton.icon(
            icon: Icon(Icons.video_call),
            label: Text('Join Meeting'),
            onPressed: () {
              // Implementation to join the meeting
              Navigator.of(context).pop();
              // You could implement a way to launch the meeting URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorConsultationColorPalette.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        SizedBox(width: 10),
        if (canCancel)
          ElevatedButton(
            onPressed: () {
              // Show cancellation confirmation dialog
              Navigator.of(context).pop();
              _showCancellationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorConsultationColorPalette.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancel Appointment'),
          ),
      ],
    );
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add implementation for cancellation
              // This would typically call a method in your ViewModel
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: DoctorConsultationColorPalette.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DoctorConsultationColorPalette.warningYellow;
      case 'confirmed':
        return DoctorConsultationColorPalette.infoBlue;
      case 'completed':
        return DoctorConsultationColorPalette.successGreen;
      case 'cancelled':
        return DoctorConsultationColorPalette.errorRed;
      default:
        return Colors.grey;
    }
  }
} 