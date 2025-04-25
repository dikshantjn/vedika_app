import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/JitsiMeetService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Utils/MeetingRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/JitsiMeet/JitsiMeetScreen.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/ErrorState.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/EmptyState.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomClinicAppointmentInfoDialog.dart';

class ClinicAppointmentTab extends StatefulWidget {
  const ClinicAppointmentTab({Key? key}) : super(key: key);

  @override
  _ClinicAppointmentTabState createState() => _ClinicAppointmentTabState();
}

class _ClinicAppointmentTabState extends State<ClinicAppointmentTab> {
  late ClinicAppointmentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // Initialize the ViewModel
    _viewModel = Provider.of<ClinicAppointmentViewModel>(context, listen: false);
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _viewModel.fetchUserClinicAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClinicAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: _buildAppointmentContent(viewModel),
        );
      },
    );
  }

  Widget _buildAppointmentContent(ClinicAppointmentViewModel viewModel) {
    if (viewModel.fetchState == ClinicAppointmentFetchState.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: DoctorConsultationColorPalette.primaryBlue,
        ),
      );
    }

    if (viewModel.fetchState == ClinicAppointmentFetchState.error) {
      return ErrorState(
        message: viewModel.errorMessage,
        onRetry: _fetchData,
      );
    }

    if (viewModel.appointments.isEmpty) {
      return EmptyState(
        title: 'No Appointments Found',
        subtitle: 'You have not booked any clinic appointments yet.',
        iconData: Icons.medical_services_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshAppointments,
      color: DoctorConsultationColorPalette.primaryBlue,
      child: _buildAppointmentsList(viewModel.appointments),
    );
  }

  Widget _buildAppointmentsList(List<ClinicAppointment> appointments) {
    // Sort appointments by date, most recent first
    appointments.sort((a, b) => b.date.compareTo(a.date));
    
    return Container(
      color: DoctorConsultationColorPalette.backgroundPrimary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(ClinicAppointment appointment) {
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(appointment.date);
    final doctorName = appointment.doctor?.doctorName ?? 'Unknown Doctor';
    final specialty = appointment.doctor?.specializations.isNotEmpty == true
        ? appointment.doctor!.specializations.first
        : 'Specialist';
    final isOnline = appointment.isOnline;
    final isUpcoming = appointment.status.toLowerCase() == 'pending' || 
                      appointment.status.toLowerCase() == 'confirmed';
    
    // Generate appointment time display
    final timeRange = appointment.time.contains("-") 
        ? appointment.time 
        : "${appointment.time} - ${_calculateEndTime(appointment.time)}";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showAppointmentDetails(appointment),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.backgroundCard,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusChip(appointment.status),
                  ],
                ),
              ),
              
              // Doctor info
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                      backgroundImage: appointment.doctor?.profilePicture != null && 
                                      appointment.doctor!.profilePicture.isNotEmpty
                          ? NetworkImage(appointment.doctor!.profilePicture)
                          : null,
                      child: appointment.doctor?.profilePicture == null || 
                            appointment.doctor!.profilePicture.isEmpty
                          ? Icon(
                              Icons.person, 
                              size: 30, 
                              color: DoctorConsultationColorPalette.primaryBlue,
                            )
                          : null,
                    ),
                    SizedBox(width: 14),
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
                            specialty,
                            style: TextStyle(
                              fontSize: 14,
                              color: DoctorConsultationColorPalette.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isOnline ? Icons.videocam : Icons.local_hospital,
                                size: 16,
                                color: DoctorConsultationColorPalette.primaryBlue,
                              ),
                              SizedBox(width: 6),
                              Text(
                                isOnline ? 'Online Consultation' : 'In-clinic Visit',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                height: 1,
                thickness: 1,
                color: DoctorConsultationColorPalette.borderLight,
              ),
              
              // Appointment info footer
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: DoctorConsultationColorPalette.primaryBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              timeRange,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: DoctorConsultationColorPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.payment,
                              size: 16,
                              color: DoctorConsultationColorPalette.primaryBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '₹${appointment.paidAmount}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: DoctorConsultationColorPalette.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (isUpcoming)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isOnline && appointment.meetingUrl != null && appointment.meetingUrl!.isNotEmpty)
                              OutlinedButton.icon(
                                icon: Icon(Icons.video_call),
                                label: Text('Join'),
                                onPressed: () => _joinMeeting(appointment.meetingUrl!),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                                  side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            SizedBox(width: 12),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate end time based on start time (assume 30 min consultation)
  String _calculateEndTime(String startTime) {
    try {
      final format = DateFormat('HH:mm');
      final dateTime = format.parse(startTime);
      final endTime = dateTime.add(Duration(minutes: 30));
      return format.format(endTime);
    } catch (e) {
      return startTime;
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.schedule;
        break;
      case 'confirmed':
        chipColor = DoctorConsultationColorPalette.primaryBlue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'completed':
        chipColor = DoctorConsultationColorPalette.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        chipColor = DoctorConsultationColorPalette.errorRed;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(ClinicAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => CustomClinicAppointmentInfoDialog(
        appointment: appointment,
      ),
    );
  }

  void _joinMeeting(String meetingUrl) {
    // Get the view model
    final viewModel = Provider.of<ClinicAppointmentViewModel>(context, listen: false);
    
    // Get user information
    final user = viewModel.getCurrentUser();
    final userName = user?.name ?? "Patient";
    final userEmail = user?.emailId;
    final userAvatarUrl = user?.photo;
    
    // Extract room name from URL
    final roomName = meetingUrl.contains('/')
        ? meetingUrl.split('/').last
        : meetingUrl;
    
    // Navigate to the JitsiMeetScreen
    navigateToMeeting(
      context,
      JitsiMeetScreen(
        roomName: roomName,
        userDisplayName: userName,
        userEmail: userEmail,
        userAvatarUrl: userAvatarUrl,
        isDoctor: false,
        onMeetingClosed: () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meeting ended'),
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmCancelAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: DoctorConsultationColorPalette.textPrimary,
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
              _cancelAppointment(appointmentId);
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

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final success = await _viewModel.cancelAppointment(appointmentId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: DoctorConsultationColorPalette.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment'),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
    }
  }
} 