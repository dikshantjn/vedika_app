import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/JitsiMeet/JitsiMeetService.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/ErrorState.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/EmptyState.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CustomClinicAppointmentInfoDialog.dart';
import 'package:vedika_healthcare/features/orderHistory/data/reports/clinic_appointment_invoice_pdf.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/CabBookingBottomSheet.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/widgets/dialogs/RescheduleAppointmentBottomSheet.dart';

class ClinicAppointmentTab extends StatefulWidget {
  const ClinicAppointmentTab({Key? key}) : super(key: key);

  @override
  _ClinicAppointmentTabState createState() => _ClinicAppointmentTabState();
}

class _ClinicAppointmentTabState extends State<ClinicAppointmentTab> {
  late ClinicAppointmentViewModel _viewModel;
  bool _isGeneratingInvoice = false;

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
                            if (!isOnline)
                              OutlinedButton.icon(
                                icon: Icon(Icons.local_taxi_rounded),
                                label: Text('Book Cab'),
                                onPressed: () => _showCabBookingOptions(appointment),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                                  side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            if (!isOnline)
                              SizedBox(width: 12),
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
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(appointment.date);
    final doctorName = appointment.doctor?.doctorName ?? 'Unknown Doctor';
    final specialization = appointment.doctor?.specializations.isNotEmpty == true
        ? appointment.doctor!.specializations.first
        : 'Specialist';
    final consultationType = appointment.isOnline ? 'Online Consultation' : 'In-clinic Visit';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Appointment Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                        _buildStatusChip(appointment.status),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Doctor Info Card
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                if (appointment.doctor?.address != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${appointment.doctor!.address}, ${appointment.doctor!.city}, ${appointment.doctor!.state} ${appointment.doctor!.pincode}',
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
                      ),
                    ),
                    SizedBox(height: 20),

                    // Appointment Info Card
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Appointment ID', appointment.clinicAppointmentId.substring(0, 8)),
                          Divider(height: 20),
                          _buildInfoRow('Date', formattedDate),
                          Divider(height: 20),
                          _buildInfoRow('Time', appointment.time),
                          Divider(height: 20),
                          _buildInfoRow('Type', consultationType),
                          Divider(height: 20),
                          _buildInfoRow('Fee', '₹${appointment.paidAmount.toStringAsFixed(2)}', isTotal: true),
                          Divider(height: 20),
                          _buildInfoRow('Payment Status', appointment.paymentStatus.toUpperCase()),
                          if (appointment.notes != null && appointment.notes!.trim().isNotEmpty) ...[
                            Divider(height: 20),
                            _buildInfoRow('Notes', appointment.notes!.trim()),
                          ],
                          if (appointment.attachments.isNotEmpty) ...[
                            Divider(height: 20),
                            _buildInfoRowWidget(
                              'Attachments',
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: appointment.attachments
                                    .map((u) => _attachmentChip(_filenameFromUrl(u)))
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Patient Info Card
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildInfoRow('Name', appointment.user?.name ?? 'N/A'),
                          Divider(height: 20),
                          _buildInfoRow('Phone', appointment.user?.phoneNumber ?? 'N/A'),
                          if (appointment.user?.emailId != null) ...[
                            Divider(height: 20),
                            _buildInfoRow('Email', appointment.user?.emailId ?? ''),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        if (appointment.isOnline && 
                            appointment.meetingUrl != null && 
                            appointment.meetingUrl!.isNotEmpty &&
                            (appointment.status.toLowerCase() == 'confirmed'))
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.video_call),
                              label: Text('Join Meeting'),
                              onPressed: () {
                                Navigator.pop(context);
                                _joinMeeting(appointment.meetingUrl!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        if (appointment.isOnline && 
                            appointment.meetingUrl != null && 
                            appointment.meetingUrl!.isNotEmpty)
                          SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: _isGeneratingInvoice 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.download),
                            label: Text(_isGeneratingInvoice ? 'Generating...' : 'Download Invoice'),
                            onPressed: _isGeneratingInvoice 
                              ? null 
                              : () async {
                                  try {
                                    setState(() {
                                      _isGeneratingInvoice = true;
                                    });
                                    await generateAndDownloadClinicAppointmentInvoicePDF(appointment);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Invoice downloaded successfully'),
                                          backgroundColor: DoctorConsultationColorPalette.successGreen,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to download invoice'),
                                          backgroundColor: DoctorConsultationColorPalette.errorRed,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isGeneratingInvoice = false;
                                      });
                                    }
                                  }
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (appointment.status.toLowerCase() == 'pending' || 
                        appointment.status.toLowerCase() == 'confirmed') ...[
                      // Reschedule Button
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.schedule),
                            label: Text('Reschedule Appointment'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showRescheduleBottomSheet(appointment);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                              side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Cancel Button
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.cancel_outlined),
                            label: Text('Cancel Appointment'),
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmCancelAppointment(appointment.clinicAppointmentId);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DoctorConsultationColorPalette.errorRed,
                              side: BorderSide(color: DoctorConsultationColorPalette.errorRed),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    // Appointment Status Information
                    if (_hasStatusInformation(appointment)) ...[
                      Divider(height: 30),
                      Text(
                        'Appointment Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildStatusInfoCard(appointment),
                    ],

                    // Attendance Status Buttons - Show for non-completed appointments
                    if (appointment.status.toLowerCase() != 'completed') ...[
                      Divider(height: 30),
                      Text(
                        'Attendance Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.phone_disabled),
                              label: Text('No Call'),
                              onPressed: () {
                                Navigator.pop(context);
                                _updateAttendanceStatus(appointment.clinicAppointmentId, 'no_call');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange[700],
                                side: BorderSide(color: Colors.orange[700]!),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.person_off),
                              label: Text('No Show'),
                              onPressed: () {
                                Navigator.pop(context);
                                _updateAttendanceStatus(appointment.clinicAppointmentId, 'no_show');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700],
                                side: BorderSide(color: Colors.red[700]!),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal 
                ? DoctorConsultationColorPalette.primaryBlue 
                : DoctorConsultationColorPalette.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWidget(String label, Widget valueWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget,
          ),
        ),
      ],
    );
  }

  Widget _attachmentChip(String filename) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorConsultationColorPalette.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 14, color: DoctorConsultationColorPalette.textSecondary),
          const SizedBox(width: 6),
          Text(
            filename,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _filenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.contains('/')) return path.split('/').last;
      return url.split('?').first.split('#').first;
    } catch (_) {
      return url;
    }
  }

  void _joinMeeting(String meetingUrl) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
        ),
      );

      // Get the view model
      final viewModel = Provider.of<ClinicAppointmentViewModel>(context, listen: false);

      // Get user information
      final user = viewModel.getCurrentUser();
      final userName = user?.name ?? "Patient";
      final userEmail = user?.emailId;
      final userAvatarUrl = user?.photo;

      // Parse the meeting URL
      final uri = Uri.parse(meetingUrl);
      final roomName = uri.pathSegments.last;
      final jwtToken = uri.fragment.contains("jwt=")
          ? uri.fragment.split("jwt=").last
          : null;

      if (jwtToken == null || jwtToken.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid meeting URL'),
              backgroundColor: DoctorConsultationColorPalette.errorRed,
            ),
          );
        }
        return;
      }

      // Join meeting using service
      await JitsiMeetService().joinMeeting(
        roomName: roomName,
        displayName: userName,
        email: userEmail,
        avatarUrl: userAvatarUrl,
        jwtToken: jwtToken,
        isDoctor: false, // Patients are not moderators
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining meeting: $e'),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
    }
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

  void _showRescheduleBottomSheet(ClinicAppointment appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RescheduleAppointmentBottomSheet(
        appointment: appointment,
        viewModel: _viewModel,
      ),
    );
  }

  Future<void> _updateAttendanceStatus(String appointmentId, String status) async {
    try {
      final result = await _viewModel.updateAppointmentAttendance(
        appointmentId: appointmentId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] 
                ? DoctorConsultationColorPalette.successGreen 
                : DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating attendance: $e'),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
    }
  }

  bool _hasStatusInformation(ClinicAppointment appointment) {
    return appointment.cancelReason != null ||
           appointment.rescheduledBy != null ||
           appointment.rescheduledAt != null ||
           appointment.doctorAttendanceStatus != null ||
           appointment.userAttendanceStatus != null;
  }

  Widget _buildStatusInfoCard(ClinicAppointment appointment) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appointment.cancelReason != null) ...[
            _buildStatusRow(
              icon: Icons.cancel_outlined,
              label: 'Cancel Reason',
              value: appointment.cancelReason!,
              color: Colors.red[600]!,
            ),
            SizedBox(height: 12),
          ],
          if (appointment.rescheduledBy != null) ...[
            _buildStatusRow(
              icon: Icons.schedule,
              label: 'Rescheduled By',
              value: appointment.rescheduledBy!,
              color: Colors.blue[600]!,
            ),
            SizedBox(height: 12),
          ],
          if (appointment.rescheduledAt != null) ...[
            _buildStatusRow(
              icon: Icons.access_time,
              label: 'Rescheduled At',
              value: _formatDateTime(appointment.rescheduledAt!),
              color: Colors.blue[600]!,
            ),
            SizedBox(height: 12),
          ],
          if (appointment.doctorAttendanceStatus != null) ...[
            _buildStatusRow(
              icon: Icons.person,
              label: 'Doctor Status',
              value: _formatAttendanceStatus(appointment.doctorAttendanceStatus!),
              color: _getAttendanceStatusColor(appointment.doctorAttendanceStatus!),
            ),
            SizedBox(height: 12),
          ],
          if (appointment.userAttendanceStatus != null) ...[
            _buildStatusRow(
              icon: Icons.account_circle,
              label: 'User Status',
              value: _formatAttendanceStatus(appointment.userAttendanceStatus!),
              color: _getAttendanceStatusColor(appointment.userAttendanceStatus!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatAttendanceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'no_call':
        return 'No Call';
      case 'no_show':
        return 'No Show';
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      default:
        return status;
    }
  }

  Color _getAttendanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'no_call':
        return Colors.orange[600]!;
      case 'no_show':
        return Colors.red[600]!;
      case 'present':
        return Colors.green[600]!;
      case 'absent':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  void _showCabBookingOptions(ClinicAppointment appointment) {
    // Format complete address using all available fields
    final doctor = appointment.doctor!;
    final List<String> addressParts = [
      if (doctor.address.isNotEmpty) doctor.address,
      if (doctor.floor.isNotEmpty) 'Floor: ${doctor.floor}',
      if (doctor.nearbyLandmark.isNotEmpty) 'Near ${doctor.nearbyLandmark}',
      if (doctor.city.isNotEmpty) doctor.city,
      if (doctor.state.isNotEmpty) doctor.state,
      if (doctor.pincode.isNotEmpty) doctor.pincode,
    ];
    
    final formattedAddress = addressParts.where((part) => part.isNotEmpty).join(', ');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CabBookingBottomSheet(
        destinationAddress: formattedAddress,
        doctor: doctor,
      ),
    );
  }
} 