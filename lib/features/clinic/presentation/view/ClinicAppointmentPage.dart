import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart' show MainScreenNavigator;
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicPaymentService.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart' show OrderHistoryNavigation;
import 'package:vedika_healthcare/features/HealthRecords/presentation/widgets/HealthRecordsSelectionBottomSheet.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';

class ClinicAppointmentPage extends StatefulWidget {
  final DoctorClinicProfile doctor;
  final bool isOnline;

  const ClinicAppointmentPage({
    Key? key,
    required this.doctor,
    required this.isOnline,
  }) : super(key: key);

  @override
  _ClinicAppointmentPageState createState() => _ClinicAppointmentPageState();
}

class _ClinicAppointmentPageState extends State<ClinicAppointmentPage> {
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ClinicPaymentService _paymentService = ClinicPaymentService();

  DateTime _selectedDate = DateTime.now();
  String _selectedPatientType = "Self";
  bool _isPaymentProcessing = false;
  bool _shouldRefreshTimeSlots = false;
  List<String> _selectedHealthRecordIds = [];

  // Patient form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedGender = 'Male';

  late BookClinicAppointmentViewModel _viewModel;

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not make the call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _setupPaymentCallbacks();

    // Get ViewModel from Provider
    _viewModel = Provider.of<BookClinicAppointmentViewModel>(context, listen: false);

    // Load initial time slots
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeSlotsForSelectedDate();
    });
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

    // Show initial success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful! Appointment Booked"),
        backgroundColor: DoctorConsultationColorPalette.successGreen,
      ),
    );

    // Show appointment confirmation dialog first
    _showAppointmentConfirmedDialog();

    // Refresh time slots after a brief delay to ensure dialog is shown
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _viewModel.clearAfterBooking(); // Clear selected time slot
        _loadTimeSlotsForSelectedDate(); // Refresh available slots
      }
    });

    // If time slot became unavailable, show additional info
    if (_viewModel.selectedTimeSlot == null) {
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Time slot updated. The slot you booked is now confirmed in your appointments."),
            backgroundColor: DoctorConsultationColorPalette.primaryBlue,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
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

  // Load time slots for the selected date
  void _loadTimeSlotsForSelectedDate() {
    final vendorId = widget.doctor.vendorId ?? widget.doctor.generatedId ?? '';
    if (vendorId.isNotEmpty) {
      _viewModel.loadTimeSlots(
        vendorId: vendorId,
        date: _selectedDate,
      );
    } else {
      // Show error if vendor ID is missing
      setState(() {
        _viewModel.clearData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to load time slots. Doctor information is incomplete."),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
    }
  }


  void _processPayment() {
    // Check if time slot is selected and available
    final selectedTimeSlot = _viewModel.selectedTimeSlot;
    if (selectedTimeSlot == null || !_viewModel.isTimeSlotAvailable(selectedTimeSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an available time slot"),
          backgroundColor: DoctorConsultationColorPalette.errorRed,
        ),
      );
      return;
    }

    // Check patient details if "Other" is selected
    if (_selectedPatientType == "Other") {
      if (_nameController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please complete all required fields"),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
        return;
      }
    }

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      // Extract consultation fee from range format (e.g., "500-700" -> 500)
      final feesRange = widget.doctor.consultationFeesRange ?? "0-0";
      final minFee = double.parse(feesRange.split('-')[0]);

      // Extract time from the selected time slot (e.g., "10:00 - 10:30" -> "10:00")
      final time = _viewModel.selectedTimeSlot ?? "00:00";

      _paymentService.openPaymentGateway(
        doctorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        isOnline: widget.isOnline, // Use the passed parameter
        date: _selectedDate,
        time: time,
        amount: minFee,
        vendorId: widget.doctor.vendorId ?? widget.doctor.generatedId ?? '',
        patientName: _selectedPatientType == "Self" ? "Self" : _nameController.text,
        patientAge: _selectedPatientType == "Self" ? "" : _ageController.text,
        patientGender: _selectedPatientType == "Self" ? "" : _selectedGender,
        patientPhone: _selectedPatientType == "Self" ? "" : _phoneController.text,
        patientEmail: _selectedPatientType == "Self" ? "" : _emailController.text,
        healthRecordIds: _selectedHealthRecordIds,
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

  void _showHealthRecordsSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HealthRecordsSelectionBottomSheet(
        preSelectedIds: _selectedHealthRecordIds,
        onRecordsSelected: (selectedIds) {
          setState(() {
            _selectedHealthRecordIds = selectedIds;
          });
        },
      ),
    );
  }

  void _showAppointmentConfirmedDialog() {
    final parentContext = context;
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
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
                SizedBox(height: 16),
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
                        _viewModel.selectedTimeSlot ?? "Not selected",
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
                        widget.isOnline ? "Online Consultation" : "In-Person Consultation",
                        widget.isOnline ? Icons.video_call : Icons.local_hospital,
                      ),
                      if (_selectedPatientType != "Self") ...[
                        Divider(height: 16),
                        _buildConfirmationDetailRow(
                          "Patient",
                          _nameController.text,
                          Icons.person_outline,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.isOnline
                      ? 'You will receive a notification and email with further details.'
                      : 'Please arrive 10 minutes before your scheduled appointment time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DoctorConsultationColorPalette.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Future.microtask(() {
                      // Set bridge for MainScreen-integrated OrderHistory
                      OrderHistoryNavigation.initialTab = 5;
                      Navigator.pushNamed(
                        parentContext,
                        AppRoutes.orderHistory,
                        arguments: {'initialTab': 5},
                      );
                    });
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
        );
      },
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
      bottomNavigationBar: Consumer<BookClinicAppointmentViewModel>(
        builder: (context, viewModel, child) => _buildConfirmButton(viewModel),
      ),
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
                    widget.isOnline ? Icons.video_call : Icons.healing,
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
          if (MainScreenNavigator.instance.canGoBack) {
            MainScreenNavigator.instance.goBack();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        widget.isOnline ? "Book Online Appointment" : "Book Clinic Appointment",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone, color: Colors.white),
          ),
          onPressed: () => _makeCall(widget.doctor.phoneNumber),
        ),
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
            backgroundColor: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
            child: widget.doctor.profilePicture.isNotEmpty
                ? Image.network(
                    widget.doctor.profilePicture,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: DoctorConsultationColorPalette.primaryBlue,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: DoctorConsultationColorPalette.primaryBlue,
                        size: 30,
                      );
                    },
                  )
                : Icon(
                    Icons.person,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    size: 30,
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
          if (!widget.isOnline) _buildPatientDetailsSection(),
          // Share Health Records Section - Available for both online and offline
          _buildShareHealthRecordsSection(),
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
            "${widget.doctor.doctorName} is a specialist in ${widget.doctor.specializations.join(', ')} with ${widget.doctor.experienceYears} years of experience. They are proficient in ${widget.doctor.languageProficiency.join(', ')} and have qualifications in ${widget.doctor.educationalQualifications.join(', ')}.",
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
                _viewModel.clearSelectedTimeSlot(); // Clear selected time slot
              });
              _loadTimeSlotsForSelectedDate(); // Load time slots for new date
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
    return Consumer<BookClinicAppointmentViewModel>(
      builder: (context, viewModel, child) {
        // Check if time slots need to be refreshed due to socket events
        if (viewModel.needsTimeSlotRefresh && !viewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            debugPrint('🏥 Refreshing time slots due to socket event');
            _loadTimeSlotsForSelectedDate();
            viewModel.clearRefreshFlag();
          });
        }

        if (viewModel.isLoading) {
          return Container(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                color: DoctorConsultationColorPalette.primaryBlue,
              ),
            ),
          );
        }

        if (viewModel.noSlotsAvailable) {
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTimeSlotsForSelectedDate,
                  child: Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (viewModel.error != null) {
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
                  viewModel.error!,
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

        final timeSlots = viewModel.allTimeSlots;

        if (timeSlots.isEmpty) {
          return _buildNoTimeSlotsMessage();
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((timeSlot) {
            final isSelected = viewModel.selectedTimeSlot == timeSlot;
            final isBooked = viewModel.isTimeSlotBooked(timeSlot);
            final isAvailable = viewModel.isTimeSlotAvailable(timeSlot);
            final isBookedByCurrentUser = viewModel.isTimeSlotBookedByCurrentUser(timeSlot);
            final isBookedByOtherUser = viewModel.isTimeSlotBookedByOtherUser(timeSlot);

            return GestureDetector(
              onTap: isAvailable ? () {
                viewModel.selectTimeSlot(timeSlot);
              } : null,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DoctorConsultationColorPalette.primaryBlue
                      : isBookedByCurrentUser
                          ? DoctorConsultationColorPalette.successGreen.withOpacity(0.1)
                          : isBookedByOtherUser
                              ? DoctorConsultationColorPalette.errorRed.withOpacity(0.1)
                              : DoctorConsultationColorPalette.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                  border: isBooked
                      ? Border.all(
                          color: isBookedByCurrentUser
                              ? DoctorConsultationColorPalette.successGreen.withOpacity(0.3)
                              : DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
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
                            : isBookedByCurrentUser
                                ? DoctorConsultationColorPalette.successGreen
                                : isBookedByOtherUser
                                    ? DoctorConsultationColorPalette.errorRed
                                    : DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    if (isBooked) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBookedByCurrentUser
                              ? DoctorConsultationColorPalette.successGreen.withOpacity(0.1)
                              : DoctorConsultationColorPalette.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBookedByCurrentUser
                                ? DoctorConsultationColorPalette.successGreen.withOpacity(0.3)
                                : DoctorConsultationColorPalette.errorRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isBookedByCurrentUser ? 'BOOKED BY YOU' : 'BOOKED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isBookedByCurrentUser
                                ? DoctorConsultationColorPalette.successGreen
                                : DoctorConsultationColorPalette.errorRed,
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
      },
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
            widget.isOnline
                ? "Please contact the clinic directly for online appointments"
                : "Please contact the clinic directly for appointments",
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

  Widget _buildShareHealthRecordsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DoctorConsultationColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_information,
                  color: DoctorConsultationColorPalette.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Health Records',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DoctorConsultationColorPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPatientType == "Self"
                          ? 'Help your doctor by sharing your medical records'
                          : 'Help your doctor by sharing relevant medical records',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showHealthRecordsSelectionBottomSheet,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    size: 20,
                  ),
                  label: Text(
                    _selectedHealthRecordIds.isEmpty
                        ? 'Select Health Records'
                        : '${_selectedHealthRecordIds.length} Record${_selectedHealthRecordIds.length > 1 ? 's' : ''} Selected',
                    style: TextStyle(
                      color: DoctorConsultationColorPalette.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    side: BorderSide(
                      color: DoctorConsultationColorPalette.primaryBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (_selectedHealthRecordIds.isNotEmpty) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedHealthRecordIds.clear();
                    });
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.red[600],
                  ),
                  tooltip: 'Clear Selection',
                ),
              ],
            ],
          ),
          if (_selectedHealthRecordIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DoctorConsultationColorPalette.primaryBlue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: DoctorConsultationColorPalette.primaryBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPatientType == "Self"
                          ? 'Your health records will be shared with the doctor for better consultation'
                          : 'Health records will be shared with the doctor for better consultation',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorConsultationColorPalette.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
        isExpanded: true, // Prevents overflow in Row/Expanded layouts
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: DoctorConsultationColorPalette.primaryBlue,
              width: 2,
            ),
          ),
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
            child: Text(item, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton(BookClinicAppointmentViewModel viewModel) {
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
                onPressed: (viewModel.selectedTimeSlot != null && viewModel.isTimeSlotAvailable(viewModel.selectedTimeSlot!)) && !_isPaymentProcessing ? () {
                  _processPayment();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorConsultationColorPalette.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: (viewModel.selectedTimeSlot != null && viewModel.isTimeSlotAvailable(viewModel.selectedTimeSlot!)) && !_isPaymentProcessing ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isPaymentProcessing
                      ? "Processing..."
                      : widget.isOnline
                          ? "Book Online Appointment"
                          : "Confirm Appointment",
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
