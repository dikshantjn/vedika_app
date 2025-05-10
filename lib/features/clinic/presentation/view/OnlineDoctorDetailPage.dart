import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicPaymentService.dart';

class OnlineDoctorDetailPage extends StatefulWidget {
  final DoctorClinicProfile doctor;

  const OnlineDoctorDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _OnlineDoctorDetailPageState createState() => _OnlineDoctorDetailPageState();
}

class _OnlineDoctorDetailPageState extends State<OnlineDoctorDetailPage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  final ScrollController _scrollController = ScrollController();
  final ClinicPaymentService _paymentService = ClinicPaymentService();
  bool _isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupPaymentCallbacks();
  }

  void _setupPaymentCallbacks() {
    _paymentService.onPaymentSuccess = _handlePaymentSuccess;
    _paymentService.onPaymentError = _handlePaymentError;
    _paymentService.onPaymentCancelled = _handlePaymentCancelled;
  }

  void _handlePaymentSuccess(Map<String, dynamic> response) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    print('Payment successful: ${response['transactionId']}');
    
    // Show success dialog
    _showAppointmentConfirmedDialog();
    
    // Navigate to order history after a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushNamed(context, AppRoutes.orderHistory);
    });
  }

  void _handlePaymentError(String error) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    print('Payment failed: $error');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: $error"),
        backgroundColor: DoctorConsultationColorPalette.errorRed,
      ),
    );
  }

  void _handlePaymentCancelled(String reason) {
    setState(() {
      _isPaymentProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Cancelled: $reason"),
        backgroundColor: DoctorConsultationColorPalette.warningYellow,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _paymentService.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: DoctorConsultationColorPalette.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: DoctorConsultationColorPalette.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: -50,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.healing,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildDoctorHeaderInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, color: Colors.white),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {},
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDoctorHeaderInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 37,
            backgroundImage: NetworkImage(
              widget.doctor.profilePicture,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.doctor.doctorName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.doctor.specializations.join(', '),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${widget.doctor.experienceYears} yrs exp",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoCards(),
          _buildDoctorInfo(),
          _buildAppointmentSection(),
          SizedBox(height: 100), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildInfoCard(
            icon: Icons.monetization_on,
            title: "Consultation",
            value: "₹${widget.doctor.consultationFeesRange.split('-')[0]}",
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
          SizedBox(width: 16),
          _buildInfoCard(
            icon: Icons.access_time,
            title: "Available",
            value: "${widget.doctor.consultationDays.length} days",
            color: DoctorConsultationColorPalette.secondaryTeal,
          ),
          SizedBox(width: 16),
          _buildInfoCard(
            icon: Icons.language,
            title: "Languages",
            value: "${widget.doctor.languageProficiency.length}",
            color: DoctorConsultationColorPalette.secondaryTealDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "About Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "${widget.doctor.doctorName} is a specialist in ${widget.doctor.specializations.first} with ${widget.doctor.experienceYears} years of experience. They are proficient in ${widget.doctor.languageProficiency.join(', ')} and have qualifications in ${widget.doctor.educationalQualifications.join(', ')}.",
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          _buildInfoRow(Icons.medical_services, "Specializations", widget.doctor.specializations.join(', ')),
          _buildInfoRow(Icons.school, "Education", widget.doctor.educationalQualifications.join(', ')),
          _buildInfoRow(Icons.language, "Languages", widget.doctor.languageProficiency.join(', ')),
          _buildInfoRow(Icons.location_on, "Location", "${widget.doctor.city}, ${widget.doctor.state}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: DoctorConsultationColorPalette.primaryBlue,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DoctorConsultationColorPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Book Appointment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Select Date",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          _buildDatePicker(),
          SizedBox(height: 16),
          Text(
            "Available Time Slots",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          _buildTimeSlots(),
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
          
          // Check if this day is in the doctor's consultation days
          final day = DateFormat('EEEE').format(date);
          final isAvailable = widget.doctor.consultationDays.any(
            (consultationDay) => consultationDay.toLowerCase() == day.toLowerCase()
          );

          return GestureDetector(
            onTap: isAvailable ? () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null; // Reset time slot when date changes
              });
            } : null,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? DoctorConsultationColorPalette.primaryBlue
                    : isAvailable
                        ? DoctorConsultationColorPalette.backgroundCard
                        : Colors.grey.shade200,
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
                          : isAvailable
                              ? DoctorConsultationColorPalette.textPrimary
                              : Colors.grey.shade500,
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
                          : isAvailable
                              ? DoctorConsultationColorPalette.textPrimary
                              : Colors.grey.shade500,
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
                          : isAvailable
                              ? DoctorConsultationColorPalette.textSecondary
                              : Colors.grey.shade500,
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
    // Get the consultation time slots from the doctor model
    final timeSlots = widget.doctor.consultationTimeSlots;
    
    if (timeSlots.isEmpty) {
      return _buildNoTimeSlotsMessage();
    }
    
    // Check if we have the new format
    bool isNewFormat = timeSlots.isNotEmpty && 
        (timeSlots.first.containsKey('startTime') || timeSlots.first.containsKey('endTime'));
    
    // Get all 30-minute slots for all timeSlots
    List<String> thirtyMinuteSlots = [];
    
    for (var slot in timeSlots) {
      String startTimeStr = isNewFormat ? slot['startTime'] ?? '' : slot['start'] ?? '';
      String endTimeStr = isNewFormat ? slot['endTime'] ?? '' : slot['end'] ?? '';
      
      // Skip if start or end time is empty
      if (startTimeStr.isEmpty || endTimeStr.isEmpty) continue;
      
      // Parse the times
      List<String> startComponents = startTimeStr.split(':');
      List<String> endComponents = endTimeStr.split(':');
      
      if (startComponents.length < 2 || endComponents.length < 2) continue;
      
      int startHour = int.tryParse(startComponents[0]) ?? 0;
      int startMinute = int.tryParse(startComponents[1]) ?? 0;
      int endHour = int.tryParse(endComponents[0]) ?? 0;
      int endMinute = int.tryParse(endComponents[1]) ?? 0;
      
      // Create DateTime objects for easier manipulation
      DateTime startTime = DateTime(2022, 1, 1, startHour, startMinute);
      DateTime endTime = DateTime(2022, 1, 1, endHour, endMinute);
      
      // Generate 30-minute slots
      DateTime currentSlot = startTime;
      while (currentSlot.isBefore(endTime)) {
        DateTime nextSlot = currentSlot.add(Duration(minutes: 30));
        
        // Make sure we don't go past the end time
        if (nextSlot.isAfter(endTime)) {
          nextSlot = endTime;
        }
        
        // Format the times
        String formattedCurrentSlot = DateFormat('HH:mm').format(currentSlot);
        String formattedNextSlot = DateFormat('HH:mm').format(nextSlot);
        
        // Only add if it's at least a 5-minute slot
        if (nextSlot.difference(currentSlot).inMinutes >= 5) {
          thirtyMinuteSlots.add('$formattedCurrentSlot - $formattedNextSlot');
        }
        
        // Move to next slot
        currentSlot = nextSlot;
      }
    }
    
    if (thirtyMinuteSlots.isEmpty) {
      return _buildNoTimeSlotsMessage();
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: thirtyMinuteSlots.map((timeSlot) {
        final isSelected = _selectedTimeSlot == timeSlot;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTimeSlot = timeSlot;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? DoctorConsultationColorPalette.primaryBlue
                  : DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(10),
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
            child: Text(
              timeSlot,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : DoctorConsultationColorPalette.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildNoTimeSlotsMessage() {
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
          SizedBox(height: 8),
          Text(
            "Please contact the clinic directly for appointments",
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

  Widget _buildBookingButton() {
    final bool canBook = _selectedTimeSlot != null;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Consultation Fee",
                style: TextStyle(
                  fontSize: 14,
                  color: DoctorConsultationColorPalette.textSecondary,
                ),
              ),
              Text(
                "₹${widget.doctor.consultationFeesRange.split('-')[0]}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: _isPaymentProcessing || !canBook ? null : () {
                  if (canBook) {
                    setState(() {
                      _isPaymentProcessing = true;
                    });
                    
                    // Process payment directly
                    _processPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: canBook && !_isPaymentProcessing ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isPaymentProcessing 
                      ? "Processing..." 
                      : "Book Appointment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a time slot"),
          backgroundColor: DoctorConsultationColorPalette.warningYellow,
        ),
      );
      return;
    }

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      // Extract fee amount as double
      final feeString = widget.doctor.consultationFeesRange.split('-')[0];
      final double amount = double.tryParse(feeString) ?? 500.0;
      
      // Extract time from the selected time slot (e.g., "10:00 - 10:30" -> "10:00")
      final time = _selectedTimeSlot?.split(" - ").first ?? "00:00";

      // Initialize SDK with correct parameters
      await _paymentService.initializePhonePe();
      
      // Process payment
      await _paymentService.openPaymentGateway(
        doctorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        isOnline: true,
        date: _selectedDate,
        time: time,
        amount: amount,
        vendorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        patientPhone: "", // Add patient phone if available
        patientEmail: "", // Add patient email if available
        onPaymentSuccess: _handlePaymentSuccess,
        onPaymentError: _handlePaymentError,
        onPaymentCancelled: _handlePaymentCancelled,
        onRefreshData: () {
          setState(() {});
        },
      );
    } catch (e) {
      print('❌ Error processing payment: $e');
      setState(() {
        _isPaymentProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing payment: $e"),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
    }
  }

  void _showAppointmentConfirmedDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  size: 48,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildConfirmationDetailRow(
                      "Doctor",
                      widget.doctor.doctorName,
                      Icons.person,
                    ),
                    Divider(height: 16),
                    _buildConfirmationDetailRow(
                      "Date",
                      DateFormat('EEEE, MMMM d').format(_selectedDate),
                      Icons.calendar_today,
                    ),
                    Divider(height: 16),
                    _buildConfirmationDetailRow(
                      "Time",
                      _selectedTimeSlot!,
                      Icons.access_time,
                    ),
                    Divider(height: 16),
                    _buildConfirmationDetailRow(
                      "Fee",
                      "₹${widget.doctor.consultationFeesRange.split('-')[0]}",
                      Icons.monetization_on,
                    ),
                    Divider(height: 16),
                    _buildConfirmationDetailRow(
                      "Mode",
                      "Online Consultation",
                      Icons.video_call,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'You will receive a notification and email with further details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DoctorConsultationColorPalette.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.orderHistory);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'View My Appointments',
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

  Widget _buildConfirmationDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: DoctorConsultationColorPalette.primaryBlue,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: DoctorConsultationColorPalette.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: DoctorConsultationColorPalette.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 