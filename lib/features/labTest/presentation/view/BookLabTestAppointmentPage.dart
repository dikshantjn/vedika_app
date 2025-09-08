import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart' show MainScreenNavigator;
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabAppointmentPaymentService.dart';
import 'package:vedika_healthcare/features/labTest/data/services/LabTestService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart' show OrderHistoryNavigation;

class BookLabTestAppointmentPage extends StatefulWidget {
  final DiagnosticCenter center;

  const BookLabTestAppointmentPage({Key? key, required this.center}) : super(key: key);

  @override
  State<BookLabTestAppointmentPage> createState() => _BookLabTestAppointmentPageState();
}

class _BookLabTestAppointmentPageState extends State<BookLabTestAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  File? _prescriptionImage;
  bool _isSubmitting = false;
  bool _showAppBarTitle = false;
  String? _prescriptionImageUrl;
  final timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', 
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM', '06:00 PM'
  ];
  
  // Initialize services
  late LabAppointmentPaymentService _paymentService;
  final LabTestService _labTestService = LabTestService();
  final LabTestStorageService _storageService = LabTestStorageService();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializePaymentService();
  }

  void _initializePaymentService() {
    _paymentService = LabAppointmentPaymentService();
    
    // Set up payment callbacks
    _paymentService.onPaymentSuccess = _onPaymentSuccess;
    _paymentService.onPaymentError = _onPaymentError;
    _paymentService.onPaymentCancelled = _onPaymentCancelled;
    
    // Set up booking callbacks
    _paymentService.onBookingSuccess = _showBookingSuccessDialog;
    _paymentService.onBookingError = _showBookingErrorDialog;
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    print('Payment successful: ${response.paymentId}');
    
    // Payment successful, booking will be created by the payment service
    // UI updates will be handled by _showBookingSuccessDialog or _showBookingErrorDialog
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() {
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onPaymentCancelled(PaymentFailureResponse response) {
    setState(() {
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment cancelled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showBookingSuccessDialog(Map<String, dynamic> result) {
    setState(() {
      _isSubmitting = false;
    });
    
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
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Booking Successful!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result['message'] ?? 'Your lab test has been booked successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(); // Close sheet
                          Navigator.pop(parentContext); // Go back to previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(); // Close sheet
                          // Set bridge and navigate to OrderHistory -> Lab Test tab (index 3)
                          OrderHistoryNavigation.initialTab = 3;
                          Navigator.pushNamed(
                            parentContext,
                            AppRoutes.orderHistory,
                            arguments: {'initialTab': 3},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Go to Orders'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookingErrorDialog(String errorMessage) {
    setState(() {
      _isSubmitting = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Booking Failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _paymentService.clear();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.hasClients && _scrollController.offset > 120;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LabTestAppointmentViewModel>(context);

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
        slivers: [
            _buildProfileHeader(context),
          SliverToBoxAdapter(
              child: _buildBookingForm(context, viewModel),
          ),
        ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(context, viewModel),
    );
  }

  SliverAppBar _buildProfileHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: ColorPalette.primaryColor,
      elevation: 0,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: const Text(
          'Lab Appointment Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          if (MainScreenNavigator.instance.canGoBack) {
            MainScreenNavigator.instance.goBack();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Modern gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    ColorPalette.primaryColor,
                    Color.fromARGB(255, 34, 87, 122),
                    Color.fromARGB(255, 27, 67, 95),
                  ],
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              right: -20,
              top: 60,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.science_outlined,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
            // Center information with gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.center.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${widget.center.address}, ${widget.center.city}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildChip(Icons.schedule, widget.center.businessTimings),
                        const SizedBox(width: 8),
                        _buildChip(Icons.home_work, widget.center.sampleCollectionMethod),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm(BuildContext context, LabTestAppointmentViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Diagnostic Center Details', Icons.local_hospital),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.phone, 'Contact', widget.center.mainContactNumber),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.email, 'Email', widget.center.email),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.supervisor_account, 'Owner', widget.center.ownerName),
                  if (widget.center.testTypes.isNotEmpty) const Divider(height: 20),
                  if (widget.center.testTypes.isNotEmpty)
                    _buildInfoRow(
                      Icons.biotech, 
                      'Services', 
                      widget.center.testTypes.take(3).join(', ') + 
                      (widget.center.testTypes.length > 3 ? '...' : '')
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Select Tests', Icons.science),
            if (viewModel.selectedTests.isEmpty && _isSubmitting)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please select at least one test',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.center.testTypes.map((test) => _buildTestCheckbox(test, viewModel)).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Select Date & Time', Icons.event),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(context, viewModel),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Time Slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: timeSlots.map((time) => _buildTimeSlot(time, viewModel)).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Collection Method', Icons.home_work),
            _buildCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Home Sample Collection',
                    subtitle: 'Our phlebotomist will visit your home',
                    value: viewModel.homeCollectionRequired,
                    onChanged: (value) {
                      viewModel.toggleHomeSampleCollection(value);
                    },
                    icon: Icons.home,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildSwitchTile(
                    title: 'Report Delivery at Home',
                    subtitle: 'We will deliver reports to your doorstep',
                    value: viewModel.reportDeliveryAtHome,
                    onChanged: (value) {
                      viewModel.toggleReportDeliveryAtHome(value);
                    },
                    icon: Icons.local_shipping,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Upload Prescription', Icons.file_upload),
            _buildCard(
              child: _buildPrescriptionUpload(viewModel),
            ),
            
            const SizedBox(height: 70), // Space for bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: ColorPalette.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestCheckbox(String test, LabTestAppointmentViewModel viewModel) {
    final isSelected = viewModel.selectedTests.contains(test);
    
    return InkWell(
      onTap: () {
        if (isSelected) {
          viewModel.removeTest(test);
        } else {
          viewModel.addTest(test);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? ColorPalette.primaryColor.withOpacity(0.3) 
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? ColorPalette.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? ColorPalette.primaryColor : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                test,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? ColorPalette.primaryColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, LabTestAppointmentViewModel viewModel) {
    return InkWell(
      onTap: () => _selectDate(context, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: viewModel.selectedDate != null 
              ? ColorPalette.primaryColor.withOpacity(0.05) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: viewModel.selectedDate != null 
                ? ColorPalette.primaryColor.withOpacity(0.3) 
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: viewModel.selectedDate != null 
                    ? ColorPalette.primaryColor.withOpacity(0.15) 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month,
                color: viewModel.selectedDate != null 
                    ? ColorPalette.primaryColor 
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.selectedDate == null 
                        ? 'Select Appointment Date' 
                        : DateFormat('EEEE, MMM d, yyyy').format(viewModel.selectedDate!),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: viewModel.selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                      color: viewModel.selectedDate != null 
                          ? ColorPalette.primaryColor 
                          : Colors.grey.shade700,
                    ),
                  ),
                  if (viewModel.selectedDate != null)
                    const SizedBox(height: 2),
                  if (viewModel.selectedDate != null)
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time, LabTestAppointmentViewModel viewModel) {
    final isSelected = viewModel.selectedTime == time;
    
    return InkWell(
      onTap: () {
        viewModel.setTime(time);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
              ? ColorPalette.primaryColor 
              : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: ColorPalette.primaryColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value ? ColorPalette.primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value 
              ? ColorPalette.primaryColor.withOpacity(0.3) 
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value 
                  ? ColorPalette.primaryColor.withOpacity(0.15)
                  : ColorPalette.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? ColorPalette.primaryColor : Colors.grey.shade600,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: value ? ColorPalette.primaryColor : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: ColorPalette.primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0, top: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorPalette.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: ColorPalette.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorPalette.textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, LabTestAppointmentViewModel viewModel) {
    bool isFormValid = viewModel.selectedTests.isNotEmpty && 
                       viewModel.selectedDate != null && 
                       viewModel.selectedTime != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (viewModel.selectedTests.isNotEmpty)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${viewModel.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isFormValid && !_isSubmitting 
                ? () => _submitAppointment(context, viewModel) 
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isFormValid
                          ? const Icon(Icons.check_circle, size: 16)
                          : Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, LabTestAppointmentViewModel viewModel) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 30));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: ColorPalette.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setDate(picked);
    }
  }

  Future<void> _pickImage(LabTestAppointmentViewModel viewModel) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _prescriptionImage = File(image.path);
        _prescriptionImageUrl = null; // Reset URL when picking new image
      });
      viewModel.setPrescriptionImage(_prescriptionImage);
    }
  }

  Future<void> _submitAppointment(BuildContext context, LabTestAppointmentViewModel viewModel) async {
    // Validate form before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (viewModel.selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one test')),
      );
      return;
    }
    
    if (viewModel.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    
    if (viewModel.selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }
    
    // Show submitting state
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Upload prescription image if available
      if (_prescriptionImage != null && _prescriptionImageUrl == null) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading prescription image...'))
          );
          _prescriptionImageUrl = await _storageService.uploadFile(
            _prescriptionImage!,
            fileType: 'prescriptions'
          );
          print('Prescription uploaded successfully: $_prescriptionImageUrl');
        } catch (e) {
          print('Error uploading prescription: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading prescription: ${e.toString()}')),
          );
          // Continue without image if upload fails
        }
      }
      
      // Get current user ID from Firebase Authentication
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        throw Exception("User not logged in");
      }
      
      // Calculate pricing details
      double basePrice = 0.0;
      for (var test in viewModel.selectedTests) {
        // In a real app, you would get the price of each test from the backend
        basePrice += 500.0; // Assuming each test costs ₹500
      }
      
      // Home collection fee
      double reportDeliveryFees = viewModel.reportDeliveryAtHome ? 50.0 : 0.0;
      
      // Apply standard discount and GST
      double discount = basePrice * 0.05; // 5% discount
      double gst = (basePrice - discount + reportDeliveryFees) * 0.18; // 18% GST
      
      // Calculate total amount
      double totalAmount = basePrice - discount + reportDeliveryFees + gst;
      
      // Create LabTestBooking object with all required fields
      final booking = LabTestBooking(
        vendorId: widget.center.vendorId,
        userId: userId,
        selectedTests: viewModel.selectedTests,
        bookingDate: viewModel.selectedDate!.toString().split(' ')[0], // Format as YYYY-MM-DD
        bookingTime: viewModel.selectedTime,
        homeCollectionRequired: viewModel.homeCollectionRequired,
        reportDeliveryAtHome: viewModel.reportDeliveryAtHome,
        prescriptionUrl: _prescriptionImageUrl, // Use the uploaded image URL
        testFees: basePrice,
        reportDeliveryFees: reportDeliveryFees,
        discount: discount,
        gst: gst,
        totalAmount: totalAmount,
        userAddress: "123 Main Street, City", // Replace with actual user address
        userLocation: "28.6139,77.2090", // Replace with actual user location
        centerLocationUrl: widget.center.location,
        diagnosticCenter: widget.center,
        bookingStatus: 'Pending',
        paymentStatus: 'Pending',
      );
      
      // Process payment - after payment success, the booking will be created in payment service
      _paymentService.openLabAppointmentPaymentGateway(
        booking: booking,
        amount: totalAmount.round(),
        key: ApiConstants.razorpayApiKey,
        patientName: FirebaseAuth.instance.currentUser?.displayName ?? 'Patient',
        labName: widget.center.name,
        appointmentDetails: 'Lab tests: ${viewModel.selectedTests.join(", ")}',
      );
      
      // Note: We're not setting _isSubmitting = false here because
      // it will be handled in the payment callback methods
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPrescriptionUpload(LabTestAppointmentViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_prescriptionImage != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_prescriptionImage!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _prescriptionImage = null;
                      _prescriptionImageUrl = null;
                    });
                    viewModel.setPrescriptionImage(null);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ),
              if (_prescriptionImageUrl != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Uploaded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        
        if (_prescriptionImage == null)
          InkWell(
            onTap: () => _pickImage(viewModel),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorPalette.primaryColor.withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: ColorPalette.primaryColor.withOpacity(0.02),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorPalette.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
                      size: 24,
                      color: ColorPalette.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Prescription',
                    style: TextStyle(
                      color: ColorPalette.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to select an image',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

