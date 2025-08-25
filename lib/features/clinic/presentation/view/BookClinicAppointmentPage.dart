import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart' show MainScreenNavigator;
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicPaymentService.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';


class BookClinicAppointmentPage extends StatefulWidget {
  final DoctorClinicProfile doctor;

  const BookClinicAppointmentPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _BookClinicAppointmentPageState createState() => _BookClinicAppointmentPageState();
}

class _BookClinicAppointmentPageState extends State<BookClinicAppointmentPage> {
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ClinicPaymentService _paymentService = ClinicPaymentService();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _selectedPatientType = "Self";
  bool _isPaymentProcessing = false;

  // Patient form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedGender = 'Male';

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful! Appointment Booked"),
        backgroundColor: DoctorConsultationColorPalette.successGreen,
      ),
    );

    _showAppointmentConfirmedDialog();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: DoctorConsultationColorPalette.errorRed,
      ),
    );
  }

  void _handlePaymentCancelled(PaymentFailureResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Cancelled"),
        backgroundColor: DoctorConsultationColorPalette.warningYellow,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _paymentService.clear();
    super.dispose();
  }

  bool get isFormComplete {
    if (_selectedTimeSlot == null) return false;

    if (_selectedPatientType == "Other") {
      if (_nameController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        return false;
      }
    }

    return true;
  }

  void _processPayment() {
    if (!isFormComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please complete all required fields"),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      // Extract consultation fee from range format (e.g., "500-700" -> 500)
      final feesRange = widget.doctor.consultationFeesRange ?? "0-0";
      final minFee = double.parse(feesRange.split('-')[0]);

      // Extract time from the selected time slot (e.g., "10:00 - 10:30" -> "10:00")
      final time = _selectedTimeSlot?.split(" - ").first ?? "00:00";

      _paymentService.openPaymentGateway(
        doctorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        isOnline: false, // This is an in-person/clinic appointment
        date: _selectedDate,
        time: time,
        amount: minFee,
        vendorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        patientName: _selectedPatientType == "Self" ? "Self" : _nameController.text,
        patientAge: _selectedPatientType == "Self" ? "" : _ageController.text,
        patientGender: _selectedPatientType == "Self" ? "" : _selectedGender,
        patientPhone: _selectedPatientType == "Self" ? "" : _phoneController.text,
        patientEmail: _selectedPatientType == "Self" ? "" : _emailController.text,
        onPaymentSuccess: _handlePaymentSuccess,
        onPaymentError: _handlePaymentError,
        onPaymentCancelled: _handlePaymentCancelled,
      );
    } catch (e) {
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
                      "Dr. ${widget.doctor.doctorName}",
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
                      "In-Person Consultation",
                      Icons.local_hospital,
                    ),
                    Divider(height: 16),
                    _buildConfirmationDetailRow(
                      "Patient",
                      _selectedPatientType == "Self" ? "Self" : _nameController.text,
                      Icons.person_outline,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Please arrive 10 minutes before your scheduled appointment time.',
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
      bottomNavigationBar: _buildConfirmButton(),
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
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () {
          // Navigate back using route stack
          if (MainScreenNavigator.instance.canGoBack) {
            MainScreenNavigator.instance.goBack();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        "Book Appointment",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
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
                    child: Text(
                      "${widget.doctor.experienceYears} yrs exp",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
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
                      "₹${widget.doctor.consultationFeesRange.split('-')[0]}",
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
          _buildPatientDetailsSection(),
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
            icon: Icons.location_on,
            title: "Location",
            value: widget.doctor.city,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
          SizedBox(width: 16),
          _buildInfoCard(
            icon: Icons.language,
            title: "Languages",
            value: "${widget.doctor.languageProficiency.length}",
            color: DoctorConsultationColorPalette.secondaryTeal,
          ),
          SizedBox(width: 16),
          _buildInfoCard(
            icon: Icons.star,
            title: "Rating",
            value: "4.8",
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
            "${widget.doctor.doctorName} is a specialist in ${widget.doctor.specializations.toString()} with ${widget.doctor.experienceYears} years of experience. They are proficient in ${widget.doctor.languageProficiency.join(', ')} and have qualifications in ${widget.doctor.educationalQualifications.join(', ')}.",
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          _buildDoctorInfoRow(Icons.medical_services, "Specializations", widget.doctor.specializations.join(', ')),
          _buildDoctorInfoRow(Icons.school, "Education", widget.doctor.educationalQualifications.join(', ')),
          _buildDoctorInfoRow(Icons.language, "Languages", widget.doctor.languageProficiency.join(', ')),
          _buildDoctorInfoRow(Icons.location_on, "Location", "${widget.doctor.city}, ${widget.doctor.state}"),
          if (widget.doctor.consultationFeesRange.isNotEmpty)
            _buildDoctorInfoRow(Icons.monetization_on, "Consultation Fee", "₹${widget.doctor.consultationFeesRange}"),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoRow(IconData icon, String title, String value) {
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

  Widget _buildPatientDetailsSection() {
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
                "Patient Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Patient Type Selection (Self / Other)
          Container(
            decoration: BoxDecoration(
              color: DoctorConsultationColorPalette.backgroundCard,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPatientType = "Self";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPatientType == "Self"
                            ? DoctorConsultationColorPalette.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Self",
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedPatientType == "Self"
                                  ? Colors.white
                                  : DoctorConsultationColorPalette.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showInfoPopup(context),
                            child: Icon(
                              Icons.info_outline,
                              color: _selectedPatientType == "Self"
                                  ? Colors.white
                                  : DoctorConsultationColorPalette.primaryBlue,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPatientType = "Other";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPatientType == "Other"
                            ? DoctorConsultationColorPalette.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Other",
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedPatientType == "Other"
                                ? Colors.white
                                : DoctorConsultationColorPalette.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Show Patient Details Form if "Other" is selected
          if (_selectedPatientType == "Other")
            Form(
              key: _patientFormKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: "Patient Name",
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: "Age",
                          icon: Icons.date_range,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid age';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedGender,
                          label: "Gender",
                          icon: Icons.people_outline,
                          items: ["Male", "Female", "Other"],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedGender = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email (Optional)",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: DoctorConsultationColorPalette.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: DoctorConsultationColorPalette.primaryBlue,
        ),
        filled: true,
        fillColor: DoctorConsultationColorPalette.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: DoctorConsultationColorPalette.errorRed,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: DoctorConsultationColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: DoctorConsultationColorPalette.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: DoctorConsultationColorPalette.primaryBlue,
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: DoctorConsultationColorPalette.textPrimary,
          fontSize: 14,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: DoctorConsultationColorPalette.primaryBlue,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton() {
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
                onPressed: isFormComplete ? () {
                  // Show booking confirmation dialog
                  _processPayment();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: isFormComplete ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Confirm Appointment",
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

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: DoctorConsultationColorPalette.primaryBlue,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "Information Shared with Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DoctorConsultationColorPalette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(color: DoctorConsultationColorPalette.borderLight),
              SizedBox(height: 10),
              _buildInfoItem("Full Name"),
              _buildInfoItem("Age & Gender"),
              _buildInfoItem("Phone Number"),
              _buildInfoItem("Address"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "Got It",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for popup items
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: DoctorConsultationColorPalette.primaryBlue,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}