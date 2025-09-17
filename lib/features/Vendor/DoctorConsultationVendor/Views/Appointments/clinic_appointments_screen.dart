import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/ClinicAppointmentViewModel.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/JitsiMeet/JitsiMeetService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/HealthRecords/health_record_preview_screen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/Appointments/RescheduleAppointmentForDoctorBottomSheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;


class ClinicAppointmentsScreen extends StatefulWidget {
  const ClinicAppointmentsScreen({Key? key}) : super(key: key);

  // Static factory method to create this screen with its provider
  static Widget withProvider() {
    return ChangeNotifierProvider<ClinicAppointmentViewModel>(
      create: (_) => ClinicAppointmentViewModel(),
      child: const ClinicAppointmentsScreen(),
    );
  }

  @override
  State<ClinicAppointmentsScreen> createState() => _ClinicAppointmentsScreenState();
}

class _ClinicAppointmentsScreenState extends State<ClinicAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize view model and fetch data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentViewModel = Provider.of<ClinicAppointmentViewModel>(context, listen: false);
      // Call initialize which fetches both doctor profile and appointments
      appointmentViewModel.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Online'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Offline'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ClinicAppointmentViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.fetchState == ClinicAppointmentFetchState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: DoctorConsultationColorPalette.primaryBlue,
              ),
            );
          }

          if (viewModel.fetchState == ClinicAppointmentFetchState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: DoctorConsultationColorPalette.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading appointments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DoctorConsultationColorPalette.errorRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.errorMessage),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.fetchUserClinicAppointments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Use separate appointment lists from ViewModel
          final onlineAppointments = viewModel.onlineAppointments;
          final offlineAppointments = viewModel.offlineAppointments;
              
          // Debug information
          print('[ClinicAppointmentsScreen] APPOINTMENTS IN UI:');
          print('[ClinicAppointmentsScreen]   - Online: ${onlineAppointments.length}');
          print('[ClinicAppointmentsScreen]   - Offline: ${offlineAppointments.length}');
          
          for (var appointment in onlineAppointments) {
            print('[ClinicAppointmentsScreen]   - Online ID: ${appointment.clinicAppointmentId}, Online: ${appointment.isOnline}');
          }
          
          for (var appointment in offlineAppointments) {
            print('[ClinicAppointmentsScreen]   - Offline ID: ${appointment.clinicAppointmentId}, Online: ${appointment.isOnline}');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Online Appointments Tab
              _buildAppointmentsList(
                context,
                onlineAppointments,
                isOnline: true,
                viewModel: viewModel,
              ),

              // Offline Appointments Tab
              _buildAppointmentsList(
                context,
                offlineAppointments,
                isOnline: false,
                viewModel: viewModel,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<ClinicAppointment> appointments,
    {required bool isOnline, required ClinicAppointmentViewModel viewModel}
  ) {
    // Debug logging
    print('[ClinicAppointmentsScreen] _buildAppointmentsList called with:');
    print('[ClinicAppointmentsScreen] - isOnline: $isOnline');
    print('[ClinicAppointmentsScreen] - appointments count: ${appointments.length}');
    
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? Icons.video_call_outlined : Icons.person_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isOnline ? 'online' : 'offline'} appointments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New appointments will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAppointments(),
      color: DoctorConsultationColorPalette.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return isOnline
              ? _buildOnlineAppointmentCard(context, appointment, viewModel)
              : _buildOfflineAppointmentCard(context, appointment, viewModel);
        },
      ),
    );
  }

  Widget _buildOnlineAppointmentCard(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) {
    final dateFormat = DateFormat('EEE, MMM d');
    final formattedDate = dateFormat.format(appointment.date);
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(
      DateTime(
        2023, 1, 1,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      ),
    );

    // Always enable the join button regardless of time window
    final isUpcoming = appointment.status == 'UPCOMING' || appointment.status == 'confirmed';
    final canJoinMeeting = true; // Always enable joining

    return InkWell(
      onTap: () => _showAppointmentDetails(context, appointment, viewModel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DoctorConsultationColorPalette.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: DoctorConsultationColorPalette.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Appointment header with date, time and status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Date and time in separate rows
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusChip(appointment.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: DoctorConsultationColorPalette.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: DoctorConsultationColorPalette.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${appointment.paidAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Appointment details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient info row with call button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: DoctorConsultationColorPalette.borderLight,
                        backgroundImage: appointment.user?.photo != null
                            ? NetworkImage(appointment.user!.photo!)
                            : null,
                        child: appointment.user?.photo == null
                            ? Icon(
                                Icons.person,
                                size: 26,
                                color: DoctorConsultationColorPalette.primaryBlue,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.user?.name ?? 'Unknown Patient',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: DoctorConsultationColorPalette.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment.user?.phoneNumber ?? 'No Contact number',
                                  style: TextStyle(
                                    color: DoctorConsultationColorPalette.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => _callPatient(appointment.user?.phoneNumber, context),
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  
                  // View details tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined, 
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap for details & actions',
                          style: TextStyle(
                            fontSize: 13,
                            color: DoctorConsultationColorPalette.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinMeeting(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) async {
    try {
      // Get doctor name - fallback to a generic name if doctorProfile is null
      final doctorName = viewModel.doctorProfile?.doctorName != null 
          ? "${viewModel.doctorProfile!.doctorName}"
          : "${appointment.doctor?.doctorName ?? "Doctor"}";
      
      // Get doctor email - fallback to null if not available
      final doctorEmail = viewModel.doctorProfile?.email ?? appointment.doctor?.email;
      
      // Get doctor avatar - fallback to null if not available
      final doctorAvatar = viewModel.doctorProfile?.profilePicture ?? appointment.doctor?.profilePicture;
      
      // Generate or get meeting URL
      String? meetingUrl = appointment.meetingUrl;
      if (meetingUrl == null || meetingUrl.isEmpty) {
        meetingUrl = await viewModel.generateMeetingUrl(appointment.clinicAppointmentId);
        if (meetingUrl == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to generate meeting link'),
                backgroundColor: DoctorConsultationColorPalette.errorRed,
              ),
            );
          }
          return;
        }
      }

      // Extract room name and JWT token from meeting URL
      final uri = Uri.parse(meetingUrl);
      final roomName = uri.pathSegments.last;
      final jwtToken = uri.fragment.contains("jwt=")
          ? uri.fragment.split("jwt=").last
          : null;

      if (jwtToken == null || jwtToken.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid meeting URL'),
              backgroundColor: DoctorConsultationColorPalette.errorRed,
            ),
          );
        }
        return;
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: DoctorConsultationColorPalette.primaryBlue,
            ),
          ),
        );
      }

      // Join meeting using service
      await JitsiMeetService().joinMeeting(
        roomName: roomName,
        displayName: doctorName,
        email: doctorEmail,
        avatarUrl: doctorAvatar,
        jwtToken: jwtToken,
        isDoctor: true,
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

  bool _isWithinTimeWindow(ClinicAppointment appointment) {
    // Always return true to allow joining regardless of time
    return true;
  }

  Widget _buildOfflineAppointmentCard(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) {
    final dateFormat = DateFormat('EEE, MMM d');
    final formattedDate = dateFormat.format(appointment.date);
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(
      DateTime(
        2023, 1, 1,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      ),
    );

    return InkWell(
      onTap: () => _showAppointmentDetails(context, appointment, viewModel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DoctorConsultationColorPalette.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: DoctorConsultationColorPalette.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Appointment header with date, time and status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Date and time in separate rows
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: DoctorConsultationColorPalette.secondaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusChip(appointment.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: DoctorConsultationColorPalette.secondaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: DoctorConsultationColorPalette.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${appointment.paidAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Appointment details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient info row with call button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: DoctorConsultationColorPalette.borderLight,
                        backgroundImage: appointment.user?.photo != null
                            ? NetworkImage(appointment.user!.photo!)
                            : null,
                        child: appointment.user?.photo == null
                            ? Icon(
                                Icons.person,
                                size: 26,
                                color: DoctorConsultationColorPalette.secondaryTeal,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.user?.name ?? 'Unknown Patient',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: DoctorConsultationColorPalette.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: DoctorConsultationColorPalette.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appointment.user?.phoneNumber ?? 'No Contact number',
                                  style: TextStyle(
                                    color: DoctorConsultationColorPalette.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => _callPatient(appointment.user?.phoneNumber, context),
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  
                  // View details tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined, 
                          size: 16,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap for details & actions',
                          style: TextStyle(
                            fontSize: 13,
                            color: DoctorConsultationColorPalette.primaryBlue,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return DoctorConsultationColorPalette.successGreen;
      case 'pending':
        return DoctorConsultationColorPalette.warningYellow;
      case 'refunded':
        return DoctorConsultationColorPalette.infoBlue;
      default:
        return DoctorConsultationColorPalette.textSecondary;
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        chipColor = DoctorConsultationColorPalette.successGreen;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending':
        chipColor = DoctorConsultationColorPalette.warningYellow;
        statusIcon = Icons.access_time_rounded;
        break;
      case 'completed':
        chipColor = DoctorConsultationColorPalette.infoBlue;
        statusIcon = Icons.task_alt_rounded;
        break;
      case 'cancelled':
        chipColor = DoctorConsultationColorPalette.errorRed;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey;
        statusIcon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final formattedDate = dateFormat.format(appointment.date);
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(
      DateTime(
        2023, 1, 1,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _AppointmentDetailsSheet(
                    appointment: appointment,
                    viewModel: viewModel,
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Expanded(
            child: Text(
              key,
                                      style: TextStyle(
                                        color: DoctorConsultationColorPalette.textSecondary,
                fontSize: 13,
              ),
                            ),
                          ),
                          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                          color: DoctorConsultationColorPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  Widget _modernPrimaryCardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
                Text(
                label,
                  style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ],
            ),
          ),
      ),
    );
  }
  
  Widget _miniActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
        color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
        borderRadius: BorderRadius.circular(10),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
                Text(
                  label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DoctorConsultationColorPalette.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DoctorConsultationColorPalette.textSecondary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callPatient(String? phoneNumber, BuildContext context) async {
    try {
      if (phoneNumber == null || phoneNumber.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact number not available')),
        );
        return;
      }
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open dialer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

}

class _AppointmentDetailsSheet extends StatefulWidget {
  final ClinicAppointment appointment;
  final ClinicAppointmentViewModel viewModel;
  final String formattedDate;
  final String formattedTime;

  const _AppointmentDetailsSheet({
    Key? key,
    required this.appointment,
    required this.viewModel,
    required this.formattedDate,
    required this.formattedTime,
  }) : super(key: key);

  @override
  State<_AppointmentDetailsSheet> createState() => _AppointmentDetailsSheetState();
}

class _AppointmentDetailsSheetState extends State<_AppointmentDetailsSheet> {
  final List<String> _notes = [];
  final List<String> _files = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: DoctorConsultationColorPalette.borderLight,
              backgroundImage: widget.appointment.user?.photo != null
                  ? NetworkImage(widget.appointment.user!.photo!)
                  : null,
              child: widget.appointment.user?.photo == null
                  ? Icon(
                      Icons.person,
                      size: 22,
                      color: widget.appointment.isOnline
                          ? DoctorConsultationColorPalette.primaryBlue
                          : DoctorConsultationColorPalette.secondaryTeal,
                    )
                  : null,
            ),
            title: Text(
              widget.appointment.user?.name ?? 'Unknown Patient',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              '${widget.appointment.isOnline ? 'Online' : 'Offline'} • ${widget.appointment.status.toUpperCase()}',
              style: TextStyle(color: DoctorConsultationColorPalette.textSecondary, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: DoctorConsultationColorPalette.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildKeyValueRow('Patient', widget.appointment.user?.name ?? 'Unknown'),
                    _buildKeyValueRow('Phone', widget.appointment.user?.phoneNumber ?? 'N/A'),
                    _buildKeyValueRow('Date', widget.formattedDate),
                    _buildKeyValueRow('Time', widget.formattedTime),
                    _buildKeyValueRow('Mode', widget.appointment.isOnline ? 'Online' : 'In-Person'),
                    _buildKeyValueRow('Amount Paid', '₹${widget.appointment.paidAmount.toStringAsFixed(0)}'),
                    _buildKeyValueRow('Payment', widget.appointment.paymentStatus.toUpperCase()),
                    if (widget.appointment.cancelReason != null && widget.appointment.cancelReason!.isNotEmpty)
                      _buildKeyValueRow('Cancel Reason', widget.appointment.cancelReason!),
                    if (widget.appointment.rescheduledBy != null && widget.appointment.rescheduledBy!.isNotEmpty)
                      _buildKeyValueRow('Rescheduled By', widget.appointment.rescheduledBy!),
                    if (widget.appointment.rescheduledAt != null)
                      _buildKeyValueRow('Rescheduled At', _formatDateTimeFromDateTime(widget.appointment.rescheduledAt!)),
                    if (widget.appointment.doctorAttendanceStatus != null && widget.appointment.doctorAttendanceStatus!.isNotEmpty)
                      _buildKeyValueRow('Doctor Attendance', widget.appointment.doctorAttendanceStatus!.toUpperCase()),
                    if (widget.appointment.userAttendanceStatus != null && widget.appointment.userAttendanceStatus!.isNotEmpty)
                      _buildKeyValueRow('User Attendance', widget.appointment.userAttendanceStatus!.toUpperCase()),
                    if (_getNotesValue() != null)
                      _buildKeyValueRow('Notes', _getNotesValue()!),
                    if (_getCombinedAttachments().isNotEmpty)
                      _buildKeyValueRowWidget(
                        'Attachments',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _getCombinedAttachments()
                              .map((u) => _infoChip(icon: Icons.insert_drive_file, text: _filenameFromUrl(u)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                          child: _modernPrimaryCardButton(
                            icon: Icons.note_add_outlined,
                            label: 'Add Note',
                            color: DoctorConsultationColorPalette.infoBlue,
                            onTap: () => _showAddNoteDialog(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                          Expanded(
                          child: _modernPrimaryCardButton(
                            icon: Icons.upload_file,
                            label: 'Upload File',
                            color: DoctorConsultationColorPalette.primaryBlue,
                            onTap: () => _pickAndUploadRecord(context),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    
                    // Health Records Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showHealthRecords(context, widget.appointment, widget.viewModel),
                        icon: const Icon(Icons.medical_services_outlined, size: 18),
                        label: const Text('View Shared Health Records'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DoctorConsultationColorPalette.secondaryTeal,
                          side: BorderSide(color: DoctorConsultationColorPalette.secondaryTeal, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // More Actions Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.backgroundCard.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DoctorConsultationColorPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // First row - Call and No Call
                          Row(
                            children: [
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.call,
                                  label: 'Call',
                                  color: Colors.green[700]!,
                                  onTap: () => _callPatient(widget.appointment.user?.phoneNumber, context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.phone_disabled,
                                  label: 'No Call',
                                  color: Colors.orange[700]!,
                                  onTap: () async {
                                    Navigator.pop(context);
                                    print('[No Call Button] Starting attendance status update...');
                                    final success = await widget.viewModel.updateAttendanceStatus(
                                      widget.appointment.clinicAppointmentId,
                                      'no_call',
                                    );
                                    print('[No Call Button] Update result: $success');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success 
                                            ? 'Attendance status updated to No Call'
                                            : 'Failed to update attendance status'),
                                          backgroundColor: success 
                                            ? DoctorConsultationColorPalette.successGreen
                                            : DoctorConsultationColorPalette.errorRed,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Second row - Reschedule and Cancel
                          Row(
                            children: [
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.schedule,
                                  label: 'Reschedule',
                                  color: DoctorConsultationColorPalette.infoBlue,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showRescheduleBottomSheet(context, widget.appointment, widget.viewModel);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.cancel_outlined,
                                  label: 'Cancel',
                                  color: DoctorConsultationColorPalette.warningYellow,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showCancelAppointmentDialog(context, widget.appointment, widget.viewModel);
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Third row - Complete and Notify
                          Row(
                            children: [
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.check_circle_outline,
                                  label: 'Complete',
                                  color: DoctorConsultationColorPalette.successGreen,
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final success = await widget.viewModel.updateAppointmentStatus(
                                      widget.appointment.clinicAppointmentId,
                                      'completed',
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success 
                                            ? 'Appointment completed successfully'
                                            : 'Failed to complete appointment'),
                                          backgroundColor: success 
                                            ? DoctorConsultationColorPalette.successGreen
                                            : DoctorConsultationColorPalette.errorRed,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _bigActionButton(
                                  icon: Icons.notifications_active_outlined,
                                  label: 'Notify',
                                  color: DoctorConsultationColorPalette.primaryBlue,
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Patient notified about the appointment'),
                                        backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                                      ),
                                    );
                                  },
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
          const SizedBox(height: 10),
          ],
    );
  }
  
  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Expanded(
            child: Text(
              key,
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                  value,
                  style: const TextStyle(
                  color: DoctorConsultationColorPalette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueRowWidget(String key, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                color: DoctorConsultationColorPalette.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }
  
  List<String> _getCombinedAttachments() {
    final combined = <String>[];
    if (widget.appointment.attachments.isNotEmpty) {
      combined.addAll(widget.appointment.attachments);
    }
    if (_files.isNotEmpty) {
      combined.addAll(_files);
    }
    return combined;
  }

  String _filenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.contains('/')) {
        return path.split('/').last;
      }
      return url.split('?').first.split('#').first;
    } catch (_) {
      return url;
    }
  }

  String? _getNotesValue() {
    if (_notes.isNotEmpty) return _notes.join("\n");
    if (widget.appointment.notes != null && widget.appointment.notes!.trim().isNotEmpty) {
      return widget.appointment.notes;
    }
    return null;
  }

  String? _getAttachmentsValue() {
    final combined = <String>[];
    if (widget.appointment.attachments.isNotEmpty) {
      combined.addAll(widget.appointment.attachments);
    }
    if (_files.isNotEmpty) {
      combined.addAll(_files);
    }
    if (combined.isEmpty) return null;
    return combined.join("\n");
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatDateTimeFromDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  void _showRescheduleBottomSheet(BuildContext context, ClinicAppointment appointment, ClinicAppointmentViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RescheduleAppointmentForDoctorBottomSheet(
          appointment: appointment,
          viewModel: viewModel,
        );
      },
    );
  }

  void _showCancelAppointmentDialog(BuildContext context, ClinicAppointment appointment, ClinicAppointmentViewModel viewModel) {
    final TextEditingController reasonController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.backgroundCard.withOpacity(0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: DoctorConsultationColorPalette.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DoctorConsultationColorPalette.warningYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: DoctorConsultationColorPalette.warningYellow,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: DoctorConsultationColorPalette.textSecondary),
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appointment info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DoctorConsultationColorPalette.backgroundCard.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: DoctorConsultationColorPalette.borderLight,
                                  backgroundImage: appointment.user?.photo != null
                                      ? NetworkImage(appointment.user!.photo!)
                                      : null,
                                  child: appointment.user?.photo == null
                                      ? Icon(
                                          Icons.person,
                                          size: 20,
                                          color: appointment.isOnline
                                              ? DoctorConsultationColorPalette.primaryBlue
                                              : DoctorConsultationColorPalette.secondaryTeal,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.user?.name ?? 'Unknown Patient',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: DoctorConsultationColorPalette.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: DoctorConsultationColorPalette.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('EEE, MMM d, yyyy').format(appointment.date),
                                            style: TextStyle(
                                              color: DoctorConsultationColorPalette.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: DoctorConsultationColorPalette.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            appointment.time,
                                            style: TextStyle(
                                              color: DoctorConsultationColorPalette.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Reason input section
                      Text(
                        'Cancellation Reason',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide a reason for cancelling this appointment:',
                        style: TextStyle(
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DoctorConsultationColorPalette.borderLight),
                        ),
                        child: TextField(
                          controller: reasonController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter cancellation reason...',
                            hintStyle: TextStyle(
                              color: DoctorConsultationColorPalette.textSecondary.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: DoctorConsultationColorPalette.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: DoctorConsultationColorPalette.borderLight,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keep',
                          style: TextStyle(
                            color: DoctorConsultationColorPalette.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please enter a cancellation reason'),
                                backgroundColor: DoctorConsultationColorPalette.errorRed,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final result = await viewModel.cancelAppointmentWithReason(
                              appointmentId: appointment.clinicAppointmentId,
                              cancelReason: reason,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
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
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to cancel appointment: $e'),
                                  backgroundColor: DoctorConsultationColorPalette.errorRed,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorConsultationColorPalette.warningYellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cancelling...',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cancel Appointment',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
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

  Widget _modernPrimaryCardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                child: Icon(icon, color: color, size: 18),
                ),
              const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                  fontWeight: FontWeight.w700,
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  Widget _miniActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color, 
                    fontWeight: FontWeight.w600, 
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DoctorConsultationColorPalette.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DoctorConsultationColorPalette.textSecondary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddNoteDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      const Text('Add Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(
                        icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter note for this appointment',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                      children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final note = controller.text.trim();
                            if (note.isEmpty) return;
                            final vm = context.read<ClinicAppointmentViewModel>();
                            final ok = await vm.addAppointmentNote(widget.appointment.clinicAppointmentId, note);
                            if (!mounted) return;
                            if (ok) {
                              setState(() => _notes.add(note));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note added')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to add note'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadRecord(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(withReadStream: false, allowMultiple: true);
      if (result != null && result.files.isNotEmpty) {
        final vm = context.read<ClinicAppointmentViewModel>();
        final files = <dio.MultipartFile>[];
        for (final f in result.files) {
          if (f.bytes != null) {
            files.add(dio.MultipartFile.fromBytes(f.bytes!, filename: f.name));
          } else if (f.path != null) {
            files.add(await dio.MultipartFile.fromFile(f.path!, filename: f.name));
          }
        }
        final resp = await vm.uploadAppointmentFiles(widget.appointment.clinicAppointmentId, files);
        if (!mounted) return;
        if (resp != null && resp['files'] is List) {
          final List<dynamic> urls = resp['files'];
          setState(() => _files.addAll(urls.map((e) => e.toString())));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Files uploaded')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File upload failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _callPatient(String? phoneNumber, BuildContext context) async {
    try {
      if (phoneNumber == null || phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact number not available')),
        );
        return;
      }
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open dialer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

  void _showHealthRecords(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: DoctorConsultationColorPalette.primaryBlue,
        ),
      ),
    );

    final records = await viewModel.fetchHealthRecords(appointment.clinicAppointmentId);

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (records == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to fetch health records'),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: DoctorConsultationColorPalette.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                            Icons.medical_services_outlined,
                            color: DoctorConsultationColorPalette.secondaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                        const Text(
                          'Shared Health Records',
                          style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: DoctorConsultationColorPalette.textSecondary),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (records['healthRecords'] != null && (records['healthRecords'] as List).isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (records['healthRecords'] as List).length,
                            itemBuilder: (context, index) {
                              final record = records['healthRecords'][index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: DoctorConsultationColorPalette.borderLight,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DoctorConsultationColorPalette.shadowLight,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      record['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                                      color: DoctorConsultationColorPalette.secondaryTeal,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    record['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Uploaded on ${DateFormat('MMM d, yyyy').format(DateTime.parse(record['uploadedAt']))}',
                                        style: TextStyle(
                                          color: DoctorConsultationColorPalette.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HealthRecordPreviewScreen(
                                          record: record,
                                          patientName: appointment.user?.name ?? 'Unknown Patient',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No health records shared',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'The patient has not shared any health records yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
                                          ),
                                        );
                                      }
  }
} 