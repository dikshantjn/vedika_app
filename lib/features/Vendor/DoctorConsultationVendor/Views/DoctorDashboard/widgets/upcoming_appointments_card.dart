import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class UpcomingAppointmentsCard extends StatelessWidget {
  final List<AppointmentData> appointments;
  final Function(String) onViewDetails;

  const UpcomingAppointmentsCard({
    Key? key,
    required this.appointments,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Appointments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: DoctorConsultationColorPalette.primaryBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all appointments
                    Navigator.pushNamed(context, '/doctor/appointments');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          appointments.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length > 3 ? 3 : appointments.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return _buildAppointmentItem(context, appointment);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming appointments',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your scheduled appointments will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, AppointmentData appointment) {
    return InkWell(
      onTap: () => onViewDetails(appointment.id),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateTimeIndicator(appointment.dateTime),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          appointment.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildAppointmentStatusChip(appointment.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appointment.age} years • ${appointment.gender}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment.consultationType,
                    style: TextStyle(
                      color: DoctorConsultationColorPalette.primaryBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle reschedule
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DoctorConsultationColorPalette.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            side: BorderSide(color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Reschedule'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle start consultation
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Start'),
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

  Widget _buildDateTimeIndicator(DateTime dateTime) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('d MMM');
    final dayFormat = DateFormat('E');
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            timeFormat.format(dateTime),
            style: TextStyle(
              color: DoctorConsultationColorPalette.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dateFormat.format(dateTime),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          dayFormat.format(dateTime),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentStatusChip(AppointmentStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case AppointmentStatus.confirmed:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case AppointmentStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum AppointmentStatus {
  confirmed,
  pending,
  cancelled,
}

class AppointmentData {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final DateTime dateTime;
  final String consultationType;
  final AppointmentStatus status;

  AppointmentData({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.dateTime,
    required this.consultationType,
    required this.status,
  });
} 