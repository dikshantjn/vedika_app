import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class OnlineDoctorDetailPage extends StatefulWidget {
  final DoctorClinicProfile doctor;

  const OnlineDoctorDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  State<OnlineDoctorDetailPage> createState() => _OnlineDoctorDetailPageState();
}

class _OnlineDoctorDetailPageState extends State<OnlineDoctorDetailPage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildDoctorProfile(),
                  const SizedBox(height: 20),
                  _buildConsultationDetails(),
                  const SizedBox(height: 20),
                  _buildDatePicker(),
                  const SizedBox(height: 20),
                  _buildTimeSlots(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBookingButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DoctorConsultationColorPalette.primaryBlue,
                DoctorConsultationColorPalette.primaryBlueDark,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: DoctorConsultationColorPalette.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.doctorName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.doctor.specializations.join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(120 Reviews)',
                            style: TextStyle(
                              fontSize: 12,
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
        ),
      ],
    );
  }

  Widget _buildDoctorProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Doctor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.work,
                  title: 'Experience',
                  value: '${widget.doctor.experienceYears} years',
                ),
                const Divider(),
                _buildInfoRow(
                  icon: Icons.school,
                  title: 'Education',
                  value: widget.doctor.educationalQualifications.join(', '),
                ),
                const Divider(),
                _buildInfoRow(
                  icon: Icons.language,
                  title: 'Languages',
                  value: widget.doctor.languageProficiency.join(', '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.primaryBlueLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: DoctorConsultationColorPalette.primaryBlueLight,
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
                    fontSize: 14,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultation Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildConsultationInfoBox(
                        icon: Icons.videocam,
                        title: 'Online Consultation',
                        backgroundColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                        iconColor: DoctorConsultationColorPalette.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildConsultationInfoBox(
                        icon: Icons.payments,
                        title: '₹${widget.doctor.consultationFeesRange}',
                        description: 'Consultation Fee',
                        backgroundColor: DoctorConsultationColorPalette.successGreen.withOpacity(0.1),
                        iconColor: DoctorConsultationColorPalette.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildConsultationInfoBox(
                        icon: Icons.access_time,
                        title: '15 Minutes',
                        description: 'Consultation Duration',
                        backgroundColor: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                        iconColor: DoctorConsultationColorPalette.secondaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildConsultationInfoBox(
                        icon: Icons.calendar_today,
                        title: widget.doctor.consultationDays.join(', '),
                        description: 'Available Days',
                        backgroundColor: DoctorConsultationColorPalette.infoBlue.withOpacity(0.1),
                        iconColor: DoctorConsultationColorPalette.infoBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationInfoBox({
    required IconData icon,
    required String title,
    String? description,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // Show next 14 days
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                
                // Check if this day is in the doctor's consultation days
                final dayOfWeek = DateFormat('EEEE').format(date);
                final isAvailable = widget.doctor.consultationDays.contains(dayOfWeek);
                
                return GestureDetector(
                  onTap: isAvailable ? () {
                    setState(() {
                      _selectedDate = date;
                      _selectedTimeSlot = null; // Reset time slot when date changes
                    });
                  } : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? DoctorConsultationColorPalette.primaryBlue
                          : (isAvailable ? Colors.white : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? DoctorConsultationColorPalette.primaryBlue
                            : (isAvailable ? DoctorConsultationColorPalette.borderLight : Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : (isAvailable ? DoctorConsultationColorPalette.textSecondary : Colors.grey.shade500),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isAvailable ? DoctorConsultationColorPalette.textPrimary : Colors.grey.shade500),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isAvailable ? DoctorConsultationColorPalette.textSecondary : Colors.grey.shade500),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    // Get time slots from the doctor's profile
    final timeSlots = widget.doctor.consultationTimeSlots;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          timeSlots.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No time slots available for this day',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: timeSlots.map((slot) {
                    final timeSlot = '${slot['start']} - ${slot['end']}';
                    final isSelected = _selectedTimeSlot == timeSlot;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? DoctorConsultationColorPalette.primaryBlue 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? DoctorConsultationColorPalette.primaryBlue
                                : DoctorConsultationColorPalette.borderLight,
                          ),
                        ),
                        child: Text(
                          timeSlot,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : DoctorConsultationColorPalette.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    final bool canBook = _selectedTimeSlot != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
              Text(
                '₹${widget.doctor.consultationFeesRange}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: canBook ? () {
                // Show booking confirmation dialog
                _showBookingConfirmationDialog();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: DoctorConsultationColorPalette.buttonDisabled,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment with ${widget.doctor.doctorName} has been confirmed for ${DateFormat('EEEE, MMMM d').format(_selectedDate)} at $_selectedTimeSlot.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You will receive a notification and email with further details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to home or appointments list
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 