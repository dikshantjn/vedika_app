import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalBookingPaymentService.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/DatePickerWidget.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/HospitalInfoCard.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/PatientDetailsForm.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/TimeSlotSelection.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart'
    show MainScreenNavigator;

class BookAppointmentPage extends StatefulWidget {
  final HospitalProfile hospital;

  const BookAppointmentPage({Key? key, required this.hospital})
      : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();
  final HospitalService _hospitalService = HospitalService();
  bool _isBookingPending = false;
  String? _bookingStatus;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<BookAppointmentViewModel>(context, listen: false);
      viewModel.selectHospital(widget.hospital);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showTitle =
        _scrollController.hasClients && _scrollController.offset > 120;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

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
              Icon(Icons.info_outline,
                  color: ColorPalette.primaryColor, size: 50),
              SizedBox(height: 10),
              Text(
                "Information Shared with Hospital",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 10),
              _buildInfoItem("Full Name"),
              _buildInfoItem("Age & Gender"),
              _buildInfoItem("Contact Number"),
              _buildInfoItem("Address"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text("Got It",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: ColorPalette.primaryColor, size: 20),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Future<void> _handleBookingConfirmation(BuildContext context) async {
    final viewModel =
        Provider.of<BookAppointmentViewModel>(context, listen: false);

    if (viewModel.selectedPatientType == "Other" &&
        !_patientFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all patient details")),
      );
      return;
    }

    if (!viewModel.isFormComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() {
      _isBookingPending = true;
    });

    try {
      String? userId = await StorageService.getUserId();
      final result = await _hospitalService.createBedBooking(
        vendorId: widget.hospital.vendorId ?? widget.hospital.generatedId ?? '',
        userId: userId!,
        hospitalId:
            widget.hospital.vendorId ?? widget.hospital.generatedId ?? '',
        wardId: viewModel.selectedWard!.wardId,
        bedType: viewModel.selectedWard!.wardType,
        price: viewModel.selectedWard!.pricePerDay,
        paidAmount: 0.0,
        paymentStatus: 'pending',
        bookingDate: viewModel.selectedDate!,
        timeSlot: viewModel.selectedTimeSlot!,
        selectedDoctorId: viewModel.selectedDoctorId,
        status: 'pending',
      );

      setState(() {
        _isBookingPending = false;
        _bookingStatus = result['data']?['status'];
      });

      if (result['success'] == true) {
        _showBookingConfirmationDialog(context, result['message']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _isBookingPending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create booking: $e")),
      );
    }
  }

  void _showBookingConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Booking Request Sent",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Please wait for hospital approval. You will be notified once your booking is confirmed.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog first
                      // Then navigate back using MainScreenNavigator
                      if (MainScreenNavigator.instance.canGoBack) {
                        MainScreenNavigator.instance.goBack();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookAppointmentViewModel>(context);
    final razorpayService = HospitalBookingPaymentService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(context, viewModel, razorpayService),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: ColorPalette.primaryColor,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: const Text(
          'Bed Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: -50,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.local_hospital,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildHospitalHeaderInfo(),
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
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        onPressed: () {
          if (MainScreenNavigator.instance.canGoBack) {
            MainScreenNavigator.instance.goBack();
          } else {
            Navigator.pop(context);
          }
        },
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
            child: Icon(Icons.phone, color: Colors.white),
          ),
          onPressed: () => _makeCall(widget.hospital.contactNumber),
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

  Widget _buildHospitalHeaderInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 37,
            backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.local_hospital,
              size: 40,
              color: ColorPalette.primaryColor,
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
                widget.hospital.name,
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
                widget.hospital.address,
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
                      "${widget.hospital.city}",
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

  Widget _buildBody(BuildContext context, BookAppointmentViewModel viewModel,
      HospitalBookingPaymentService razorpayService) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickInfoCards(),
          _buildHospitalInfo(),
          _buildBookingSection(context, viewModel, razorpayService),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    final viewModel = Provider.of<BookAppointmentViewModel>(context);
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bed,
                    color: ColorPalette.primaryColor,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Available Beds",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${viewModel.totalAvailableBeds}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.primaryColor.withOpacity(0.08),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_services,
                    color: ColorPalette.primaryColor.withOpacity(0.8),
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${widget.hospital.servicesOffered.length}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.primaryColor.withOpacity(0.06),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: ColorPalette.primaryColor.withOpacity(0.6),
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.hospital.city,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

  Widget _buildHospitalInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info,
                  color: ColorPalette.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "About Hospital",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Welcome to ${widget.hospital.name}, a leading healthcare facility in ${widget.hospital.city}. We provide comprehensive medical services with state-of-the-art facilities and experienced medical professionals.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          _buildInfoRow(Icons.location_on, "Address",
              "${widget.hospital.address}, ${widget.hospital.city}"),
          _buildInfoRow(Icons.phone, "Contact", widget.hospital.contactNumber),
          _buildInfoRow(Icons.email, "Email", widget.hospital.email),
          _buildInfoRow(Icons.person, "Owner", widget.hospital.ownerName),
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
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ColorPalette.primaryColor,
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
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection(
      BuildContext context,
      BookAppointmentViewModel viewModel,
      HospitalBookingPaymentService razorpayService) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: ColorPalette.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Book Bed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Select Ward",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          if (viewModel.isLoading)
            Center(
              child: CircularProgressIndicator(
                color: ColorPalette.primaryColor,
              ),
            )
          else if (viewModel.error != null)
            Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchWards(),
                    child: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                    ),
                  ),
                ],
              ),
            )
          else if (viewModel.wards.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.bed_outlined, color: Colors.grey, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No wards available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: viewModel.wards.length,
              itemBuilder: (context, index) {
                final ward = viewModel.wards[index];
                final isSelected =
                    ward.wardId == viewModel.selectedWard?.wardId;

                return InkWell(
                  onTap: () => viewModel.selectWard(ward),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorPalette.primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? ColorPalette.primaryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ColorPalette.primaryColor
                                          .withOpacity(0.1)
                                      : Colors.grey.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.bed_outlined,
                                  color: isSelected
                                      ? ColorPalette.primaryColor
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  ward.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? ColorPalette.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  ward.wardType,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  '₹${ward.pricePerDay.toStringAsFixed(0)}/day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? ColorPalette.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ward.availableBeds > 0
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ward.availableBeds > 0
                                      ? '${ward.availableBeds} Available'
                                      : 'Full',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: ward.availableBeds > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: 20),
          if (viewModel.selectedWard != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorPalette.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: ColorPalette.primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Select Date & Time",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Select Date",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  DatePickerWidget(
                    selectedDate: viewModel.selectedDate,
                    onDatePicked: viewModel.selectDate,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Select Time Slot",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TimeSlotSelection(
                    timeSlots: ["Morning", "Afternoon", "Evening", "Night"],
                    selectedTimeSlot: viewModel.selectedTimeSlot,
                    onTimeSlotSelected: viewModel.selectTimeSlot,
                  ),
                ],
              ),
            ),
          ],
          if (viewModel.selectedWard != null &&
              viewModel.selectedDate != null &&
              viewModel.selectedTimeSlot != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorPalette.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: ColorPalette.primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Patient Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => viewModel.selectPatientType("Self"),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: viewModel.selectedPatientType == "Self"
                                    ? ColorPalette.primaryColor
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
                                      color: viewModel.selectedPatientType ==
                                              "Self"
                                          ? Colors.white
                                          : ColorPalette.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _showInfoPopup(context),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: viewModel.selectedPatientType ==
                                              "Self"
                                          ? Colors.white
                                          : ColorPalette.primaryColor,
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
                            onTap: () => viewModel.selectPatientType("Other"),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: viewModel.selectedPatientType == "Other"
                                    ? ColorPalette.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Other",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        viewModel.selectedPatientType == "Other"
                                            ? Colors.white
                                            : ColorPalette.primaryColor,
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
                  if (viewModel.selectedPatientType == "Other") ...[
                    SizedBox(height: 16),
                    PatientDetailsForm(formKey: _patientFormKey),
                  ],
                ],
              ),
            ),
          ],
          if (viewModel.selectedWard != null &&
              viewModel.selectedDate != null &&
              viewModel.selectedTimeSlot != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    "₹${viewModel.selectedWard!.pricePerDay.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBookingPending
                    ? null
                    : () {
                        if (_bookingStatus == 'accepted') {
                          razorpayService.openPaymentGateway(
                            viewModel.selectedWard!.pricePerDay.toInt(),
                            ApiConstants.razorpayApiKey,
                            'Bed Booking\n${viewModel.selectedWard!.wardType}',
                            'Bed booking for ${viewModel.selectedWard!.wardType}',
                          );
                        } else {
                          _handleBookingConfirmation(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isBookingPending)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        _bookingStatus == 'accepted'
                            ? Icons.payment
                            : Icons.check_circle,
                        size: 20,
                      ),
                    SizedBox(width: 12),
                    Text(
                      _isBookingPending
                          ? "Processing..."
                          : _bookingStatus == 'accepted'
                              ? "Make Payment"
                              : "Confirm Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
