import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/ClinicAppointmentViewModel.dart';

class RescheduleAppointmentBottomSheet extends StatefulWidget {
  final ClinicAppointment appointment;
  final ClinicAppointmentViewModel viewModel;

  const RescheduleAppointmentBottomSheet({
    Key? key,
    required this.appointment,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<RescheduleAppointmentBottomSheet> createState() => _RescheduleAppointmentBottomSheetState();
}

class _RescheduleAppointmentBottomSheetState extends State<RescheduleAppointmentBottomSheet> {
  final ClinicService _clinicService = ClinicService();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;
  TimeSlotsResponse? _timeSlotsResponse;
  bool _noSlotsAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlotsForSelectedDate();
  }

  Future<void> _loadTimeSlotsForSelectedDate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vendorId = widget.appointment.vendorId;
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      _timeSlotsResponse = await _clinicService.getTimeSlotsByVendorAndDate(
        vendorId: vendorId,
        date: dateString,
      );

      setState(() {
        _noSlotsAvailable = false;
        _selectedTimeSlot = null; // Clear selection when changing date
      });
    } catch (e) {
      final errorMessage = e.toString();
      
      if (errorMessage.contains('404')) {
        setState(() {
          _noSlotsAvailable = true;
        });
      } else {
        setState(() {
          _error = errorMessage;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> get _allTimeSlots {
    if (_timeSlotsResponse == null) return [];

    final allSlots = [
      ..._timeSlotsResponse!.availableSlots,
      ..._timeSlotsResponse!.bookedSlots.map((bookedSlot) => bookedSlot.time),
    ];

    // Sort time slots chronologically
    allSlots.sort((a, b) => _compareTimeSlots(a, b));
    return allSlots;
  }

  bool _isTimeSlotBooked(String timeSlot) {
    return _timeSlotsResponse?.bookedSlots.any((bookedSlot) => bookedSlot.time == timeSlot) ?? false;
  }

  bool _isTimeSlotAvailable(String timeSlot) {
    return _timeSlotsResponse?.availableSlots.contains(timeSlot) ?? false;
  }

  int _compareTimeSlots(String a, String b) {
    try {
      final timeA = DateFormat('HH:mm').parse(a);
      final timeB = DateFormat('HH:mm').parse(b);
      return timeA.compareTo(timeB);
    } catch (e) {
      return a.compareTo(b);
    }
  }

  Future<void> _rescheduleAppointment() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
      return;
    }

    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeString = _selectedTimeSlot!.split(' - ')[0]; // Extract start time

    final result = await widget.viewModel.rescheduleAppointment(
      appointmentId: widget.appointment.clinicAppointmentId,
      date: dateString,
      time: timeString,
    );

    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reschedule Appointment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoctorConsultationColorPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select a new date and time for your appointment',
                        style: TextStyle(
                          fontSize: 14,
                          color: DoctorConsultationColorPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Appointment Info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.backgroundCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${DateFormat('EEEE, MMMM d, yyyy').format(widget.appointment.date)} at ${widget.appointment.time}',
                          style: TextStyle(
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Date Selection
                  Text(
                    'Select New Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildDatePicker(),
                  
                  SizedBox(height: 24),
                  
                  // Time Slots
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DoctorConsultationColorPalette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildTimeSlots(),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedTimeSlot != null ? _rescheduleAppointment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Reschedule Appointment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show next 14 days
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null; // Clear selected time slot
              });
              _loadTimeSlotsForSelectedDate();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? DoctorConsultationColorPalette.primaryBlue
                    : DoctorConsultationColorPalette.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : DoctorConsultationColorPalette.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected
                          ? Colors.white
                          : DoctorConsultationColorPalette.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : DoctorConsultationColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_isLoading) {
      return Container(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
        ),
      );
    }

    if (_noSlotsAvailable) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.access_time,
              color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.5),
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "No time slots available",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "This doctor has no available appointments for the selected date. Please try a different date.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DoctorConsultationColorPalette.textHint,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: DoctorConsultationColorPalette.errorRed,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "Failed to load time slots",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: DoctorConsultationColorPalette.textHint,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTimeSlotsForSelectedDate,
              child: Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final timeSlots = _allTimeSlots;

    if (timeSlots.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.access_time_filled,
              color: Colors.grey.shade400,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              "No time slots available",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: timeSlots.map((timeSlot) {
        final isSelected = _selectedTimeSlot == timeSlot;
        final isBooked = _isTimeSlotBooked(timeSlot);
        final isAvailable = _isTimeSlotAvailable(timeSlot);

        return GestureDetector(
          onTap: isAvailable ? () {
            setState(() {
              _selectedTimeSlot = timeSlot;
            });
          } : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? DoctorConsultationColorPalette.primaryBlue
                  : isBooked
                      ? DoctorConsultationColorPalette.errorRed.withOpacity(0.1)
                      : DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(10),
              border: isBooked
                  ? Border.all(
                      color: DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeSlot,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isBooked
                            ? DoctorConsultationColorPalette.errorRed
                            : DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                if (isBooked) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'BOOKED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: DoctorConsultationColorPalette.errorRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
