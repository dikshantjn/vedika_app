import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Utils/MeetingRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/JitsiMeet/JitsiMeetScreen.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

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

          // Filter appointments by online/offline
          print('[ClinicAppointmentsScreen] Filtering appointments by online/offline status');
          print('[ClinicAppointmentsScreen] Total appointments before filtering: ${viewModel.appointments.length}');
          
          // Log all appointments before filtering
          for (var appointment in viewModel.appointments) {
            print('[ClinicAppointmentsScreen] Before filtering - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
          }
          
          final onlineAppointments = viewModel.appointments
              .where((appointment) => appointment.isOnline)
              .toList();

          final offlineAppointments = viewModel.appointments
              .where((appointment) => !appointment.isOnline)
              .toList();
              
          // Debug information
          print('[ClinicAppointmentsScreen] APPOINTMENTS IN UI:');
          print('[ClinicAppointmentsScreen]   - Total: ${viewModel.appointments.length}');
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
    
    for (var appointment in appointments) {
      print('[ClinicAppointmentsScreen] - Appointment ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
    }
    
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
            // Appointment header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.primaryBlueDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: DoctorConsultationColorPalette.primaryBlueDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Online Consultation',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(appointment.status),
                ],
              ),
            ),
            
            // Appointment details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient info row
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
                                  appointment.user?.phoneNumber ?? 'No phone number',
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
                  
                  const SizedBox(height: 20),
                  
                  // Date, time and payment info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Date and time
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: DoctorConsultationColorPalette.primaryBlueLight,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: DoctorConsultationColorPalette.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Payment info
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  color: DoctorConsultationColorPalette.successGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${appointment.paidAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.paymentStatus,
                                    style: TextStyle(
                                      color: _getPaymentStatusColor(appointment.paymentStatus),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
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
                  
                  const SizedBox(height: 14),
                  
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
                  
                  // Actions
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: ElevatedButton.icon(
                          onPressed: appointment.isOnline
                              ? () => _joinMeeting(context, appointment, viewModel)
                              : null,
                          icon: const Icon(Icons.videocam, size: 16),
                          label: const Text('Join'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appointment.isOnline
                                ? DoctorConsultationColorPalette.primaryBlue
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 140,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Patient notified about the appointment'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_outlined, size: 16),
                          label: const Text('Notify'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                            side: BorderSide(
                              color: DoctorConsultationColorPalette.primaryBlue,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
    );
  }

  void _joinMeeting(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) async {
    // Get doctor name - fallback to a generic name if doctorProfile is null
    final doctorName = viewModel.doctorProfile?.doctorName != null 
        ? "${viewModel.doctorProfile!.doctorName}"
        : "${appointment.doctor?.doctorName ?? "Doctor"}";
    
    // Get doctor email - fallback to null if not available
    final doctorEmail = viewModel.doctorProfile?.email ?? appointment.doctor?.email;
    
    // Get doctor avatar - fallback to null if not available
    final doctorAvatar = viewModel.doctorProfile?.profilePicture ?? appointment.doctor?.profilePicture;
    
    // Launch meeting with the appointment ID
    await viewModel.launchMeetingLink(
      appointment.clinicAppointmentId,
      context,
      doctorName,
      true, // isDoctor
    );
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
            // Appointment header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.backgroundCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: DoctorConsultationColorPalette.secondaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'In-Person Visit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(appointment.status),
                ],
              ),
            ),
            
            // Appointment details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient info row
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
                                  appointment.user?.phoneNumber ?? 'No phone number',
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
                  
                  const SizedBox(height: 20),
                  
                  // Date, time and payment info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Date and time
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DoctorConsultationColorPalette.secondaryTealDark.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: DoctorConsultationColorPalette.secondaryTealDark,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: DoctorConsultationColorPalette.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Payment info
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  color: DoctorConsultationColorPalette.successGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${appointment.paidAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: DoctorConsultationColorPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.paymentStatus,
                                    style: TextStyle(
                                      color: _getPaymentStatusColor(appointment.paymentStatus),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
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
                  
                  const SizedBox(height: 14),
                  
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
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appointment.isOnline
                              ? DoctorConsultationColorPalette.primaryBlueDark.withOpacity(0.1)
                              : DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          appointment.isOnline ? Icons.videocam_rounded : Icons.people_rounded,
                          color: appointment.isOnline
                              ? DoctorConsultationColorPalette.primaryBlueDark
                              : DoctorConsultationColorPalette.secondaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        appointment.isOnline ? 'Online Consultation' : 'In-Person Visit',
                        style: const TextStyle(
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
                      // Patient info section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: DoctorConsultationColorPalette.borderLight,
                            backgroundImage: appointment.user?.photo != null
                                ? NetworkImage(appointment.user!.photo!)
                                : null,
                            child: appointment.user?.photo == null
                                ? Icon(
                                    Icons.person,
                                    size: 36,
                                    color: appointment.isOnline
                                        ? DoctorConsultationColorPalette.primaryBlue
                                        : DoctorConsultationColorPalette.secondaryTeal,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.user?.name ?? 'Unknown Patient',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: DoctorConsultationColorPalette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone, 
                                      size: 16, 
                                      color: DoctorConsultationColorPalette.primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      appointment.user?.phoneNumber ?? 'No phone number',
                                      style: TextStyle(
                                        color: DoctorConsultationColorPalette.textSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                if (appointment.user?.emailId != null) ... [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.email, 
                                        size: 16, 
                                        color: DoctorConsultationColorPalette.primaryBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        appointment.user!.emailId!,
                                        style: TextStyle(
                                          color: DoctorConsultationColorPalette.textSecondary,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      
                      // Status card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(appointment.status).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getStatusColor(appointment.status).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getStatusIcon(appointment.status),
                                color: _getStatusColor(appointment.status),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: DoctorConsultationColorPalette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(appointment.status),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (appointment.isOnline && appointment.status == 'confirmed') 
                              TextButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  
                                  final viewModel = Provider.of<ClinicAppointmentViewModel>(context, listen: false);
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
                                  
                                  // Extract room name from URL
                                  final roomName = meetingUrl.contains('/')
                                      ? meetingUrl.split('/').last
                                      : 'vedika-consult-${appointment.clinicAppointmentId}';
                                      
                                  if (context.mounted) {
                                    navigateToMeeting(
                                      context,
                                      JitsiMeetScreen(
                                        roomName: roomName,
                                        displayName: doctorName,    // changed here
                                        email: doctorEmail,         // changed from userEmail to email
                                        avatarUrl: doctorAvatar,    // changed from userAvatarUrl to avatarUrl
                                        // onMeetingClosed: () {
                                        //   if (context.mounted) {
                                        //     // Mark the appointment as completed after the meeting ends
                                        //     viewModel.completeAppointmentAfterMeeting(appointment.clinicAppointmentId).then((success) {
                                        //       if (context.mounted) {
                                        //         String message = success
                                        //             ? 'Meeting ended and appointment marked as completed'
                                        //             : 'Meeting ended but failed to mark appointment as completed';
                                        //
                                        //         ScaffoldMessenger.of(context).showSnackBar(
                                        //           SnackBar(
                                        //             content: Text(message),
                                        //             backgroundColor: success
                                        //                 ? DoctorConsultationColorPalette.successGreen
                                        //                 : DoctorConsultationColorPalette.primaryBlue,
                                        //           ),
                                        //         );
                                        //       }
                                        //     });
                                        //   }
                                        // },
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.video_call, size: 18),
                                label: const Text('Join'),
                                style: TextButton.styleFrom(
                                  foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Info grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.calendar_today,
                              title: 'Date',
                              value: formattedDate,
                              color: DoctorConsultationColorPalette.primaryBlueLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time_rounded,
                              title: 'Time',
                              value: formattedTime,
                              color: DoctorConsultationColorPalette.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.payments_outlined,
                              title: 'Amount Paid',
                              value: '₹${appointment.paidAmount.toStringAsFixed(0)}',
                              color: DoctorConsultationColorPalette.successGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.payment,
                              title: 'Payment',
                              value: appointment.paymentStatus.toUpperCase(),
                              color: _getPaymentStatusColor(appointment.paymentStatus),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        icon: Icons.key,
                        title: 'Appointment ID',
                        value: appointment.clinicAppointmentId,
                        color: DoctorConsultationColorPalette.infoBlue,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      // Action buttons grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildActionButton(
                            icon: Icons.calendar_month,
                            label: 'Postpone',
                            color: DoctorConsultationColorPalette.infoBlue,
                            onTap: () {
                              Navigator.pop(context);
                              viewModel.updateAppointmentStatus(
                                appointment.clinicAppointmentId,
                                'postponed',
                              ).then((success) {
                                if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success 
                                        ? 'Appointment postponed successfully'
                                        : 'Failed to postpone appointment'),
                                      backgroundColor: success 
                                        ? DoctorConsultationColorPalette.successGreen
                                        : DoctorConsultationColorPalette.errorRed,
                                    ),
                              );
                                }
                              });
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.cancel_outlined,
                            label: 'Cancel',
                            color: DoctorConsultationColorPalette.warningYellow,
                            onTap: () {
                              Navigator.pop(context);
                              _showCancelConfirmationDialog(context, appointment, viewModel);
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.money_off,
                            label: 'Refund',
                            color: DoctorConsultationColorPalette.errorRed,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Refund feature coming soon')),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.check_circle_outline,
                            label: 'Complete',
                            color: DoctorConsultationColorPalette.successGreen,
                            onTap: () {
                              Navigator.pop(context);
                              _showCompleteConfirmationDialog(context, appointment, viewModel);
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.notifications_active_outlined,
                            label: 'Notify',
                            color: DoctorConsultationColorPalette.primaryBlue,
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Patient notified about the appointment')),
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
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
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DoctorConsultationColorPalette.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return DoctorConsultationColorPalette.successGreen;
      case 'pending':
        return DoctorConsultationColorPalette.warningYellow;
      case 'completed':
        return DoctorConsultationColorPalette.infoBlue;
      case 'cancelled':
        return DoctorConsultationColorPalette.errorRed;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.access_time_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.28,
      child: Material(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.updateAppointmentStatus(
                appointment.clinicAppointmentId,
                'cancelled',
              ).then((success) {
                if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Appointment cancelled successfully'
                        : 'Failed to cancel appointment'),
                      backgroundColor: success 
                        ? DoctorConsultationColorPalette.successGreen
                        : DoctorConsultationColorPalette.errorRed,
                ),
              );
                }
              });
            },
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmationDialog(
    BuildContext context,
    ClinicAppointment appointment,
    ClinicAppointmentViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed?'),
        content: const Text(
          'Are you sure you want to mark this appointment as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.updateAppointmentStatus(
                appointment.clinicAppointmentId, 
                'completed',
              ).then((success) {
                if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Appointment marked as completed'
                        : 'Failed to mark appointment as completed'),
                      backgroundColor: success 
                        ? DoctorConsultationColorPalette.successGreen
                        : DoctorConsultationColorPalette.errorRed,
                ),
              );
                }
              });
            },
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }
} 