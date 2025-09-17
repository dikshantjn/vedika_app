import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/features/VedikaAI/data/models/AIChatResponse.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ProductCartViewModel.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductCartService.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/BookAppointmentPage.dart';

class AIResponseCard extends StatelessWidget {
  final AIChatResponse response;
  final bool showOrderButton;
  final Widget? navigationScreen;

  const AIResponseCard({
    Key? key,
    required this.response,
    this.showOrderButton = false,
    this.navigationScreen,
  }) : super(key: key);

  // Common Styles
  static const _cardBorderRadius = 16.0;
  static const _contentPadding = 16.0;
  static const _spacing = 12.0;
  
  // Colors
  static final _primaryColor = ColorPalette.primaryColor;
  static final _primaryLightColor = _primaryColor.withOpacity(0.1);
  static final _primaryBorderColor = _primaryColor.withOpacity(0.2);
  static final _textColor = Colors.grey[800];
  static final _secondaryTextColor = Colors.grey[600];

  Widget _buildFormattedText(String text, {Color? color, double? fontSize}) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (Match match in boldPattern.allMatches(text)) {
      // Add text before the bold section
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: color ?? _textColor,
            fontSize: fontSize ?? 16,
          ),
        ));
      }

      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: color ?? _textColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastIndex = match.end;
    }

    // Add any remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: color ?? _textColor,
          fontSize: fontSize ?? 16,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          SizedBox(width: _spacing),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isPrimary = true}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? _primaryColor : Colors.white,
          foregroundColor: isPrimary ? Colors.white : _primaryColor,
          elevation: isPrimary ? 1 : 0,
          shadowColor: isPrimary ? _primaryColor.withOpacity(0.25) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.transparent : _primaryColor,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              text.contains('Book') ? Icons.calendar_today : Icons.shopping_cart,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: (color ?? _secondaryTextColor)!.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: color ?? _secondaryTextColor),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? _secondaryTextColor,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? _primaryColor).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? _primaryColor).withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? _primaryColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorBox(DoctorClinicProfile doctor) {
    return Builder(
      builder: (context) => Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
          border: Border.all(
            color: _primaryBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 84,
                        height: 84,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _primaryLightColor,
                            width: 1,
                        ),
                        image: doctor.profilePicture.isNotEmpty && doctor.profilePicture.startsWith('http')
                            ? DecorationImage(
                                image: NetworkImage(doctor.profilePicture),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              )
                            : null,
                      ),
                      child: doctor.profilePicture.isEmpty || !doctor.profilePicture.startsWith('http')
                            ? Icon(Icons.person, color: Colors.white, size: 32)
                          : null,
                    ),
                    SizedBox(height: 8),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: _primaryLightColor,
                          borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '₹${doctor.consultationFeesRange}',
                            style: TextStyle(
                                color: _primaryColor,
                              fontWeight: FontWeight.bold,
                                fontSize: 14,
                            ),
                          ),
                          Text(
                            'Consultation',
                            style: TextStyle(
                                color: _secondaryTextColor,
                                fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                  SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.doctorName,
                        style: TextStyle(
                            fontSize: 17,
                          fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _primaryLightColor,
                            borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          doctor.specializations.join(', '),
                          style: TextStyle(
                              color: _primaryColor,
                              fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.work_outline, '${doctor.experienceYears} years experience'),
                        SizedBox(height: 4),
                        _buildInfoRow(Icons.location_on_outlined, '${doctor.address}, ${doctor.city}'),
                        if (doctor.hasTelemedicineExperience) ...[
                          SizedBox(height: 4),
                        _buildInfoRow(Icons.video_call, 'Available for Online Consultation', color: Colors.green),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.all(_contentPadding),
            decoration: BoxDecoration(
                color: _primaryLightColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_cardBorderRadius),
                  bottomRight: Radius.circular(_cardBorderRadius),
                ),
              ),
              child: _buildActionButton('Book Appointment', () => _showConsultationOptions(context, doctor)),
            ),
          ],
          ),
      ),
    );
  }

  Widget _buildLabBox(DiagnosticCenter lab) {
    return Builder(
      builder: (context) => Container(
        margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
          borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
        border: Border.all(
            color: _primaryBorderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 84,
                    height: 84,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _primaryLightColor,
                        width: 1,
                    ),
                    image: lab.centerPhotosUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(lab.centerPhotosUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: lab.centerPhotosUrl.isEmpty
                        ? Icon(Icons.business, color: Colors.white, size: 32)
                      : null,
                ),
                  SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab.name,
                        style: TextStyle(
                            fontSize: 17,
                          fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _primaryLightColor,
                            borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lab.testTypes.join(', '),
                          style: TextStyle(
                              color: _primaryColor,
                              fontSize: 12,
                            fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on_outlined, '${lab.address}, ${lab.city}'),
                        SizedBox(height: 4),
                      _buildInfoRow(Icons.access_time, lab.businessTimings),
                        SizedBox(height: 4),
                      Wrap(
                          spacing: 6,
                          runSpacing: 6,
                        children: [
                          if (lab.parkingAvailable)
                            _buildFeatureChip('Parking', Icons.local_parking),
                          if (lab.wheelchairAccess)
                            _buildFeatureChip('Wheelchair', Icons.accessible),
                          if (lab.liftAccess)
                            _buildFeatureChip('Lift', Icons.elevator),
                          if (lab.emergencyHandlingFastTrack)
                            _buildFeatureChip('24/7', Icons.emergency, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.all(_contentPadding),
            decoration: BoxDecoration(
                color: _primaryLightColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_cardBorderRadius),
                  bottomRight: Radius.circular(_cardBorderRadius),
              ),
            ),
              child: _buildActionButton('Book Test', () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.bookLabTestAppointment,
                  arguments: lab,
                );
              }),
            ),
      ],
        ),
      ),
    );
  }

  Widget _buildProductBox(VendorProduct product) {
    return ChangeNotifierProvider(
      create: (context) => ProductCartViewModel(
        ProductCartService(Dio()),
      ),
      child: _ProductBoxContent(product: product),
    );
  }

  void _showConsultationOptions(BuildContext context, DoctorClinicProfile doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
      decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Consultation Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select how you would like to consult with Dr. ${doctor.doctorName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildConsultationOption(
                    context,
                    'In-Clinic Consultation',
                    'Visit the doctor in person at the clinic for a face-to-face consultation.',
                    Icons.local_hospital,
                    _primaryColor,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookClinicAppointment,
                        arguments: doctor,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  if (doctor.hasTelemedicineExperience)
                    _buildConsultationOption(
                      context,
                      'Online Consultation',
                      'Consult with the doctor from the comfort of your home.',
                      Icons.video_call,
                      Colors.teal,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.onlineDoctorDetail,
                          arguments: doctor,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
          Text(
                    description,
            style: TextStyle(
              fontSize: 12,
                      color: _secondaryTextColor,
                      height: 1.4,
            ),
          ),
        ],
      ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (response.doctors == null || response.doctors!.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Doctors', Icons.medical_services),
        ...response.doctors!.map((doctor) => _buildDoctorBox(doctor)),
      ],
    );
  }

  Widget _buildLabsList() {
    if (response.labs == null || response.labs!.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Labs', Icons.science),
        ...response.labs!.map((lab) => _buildLabBox(lab)),
      ],
    );
  }

  Widget _buildProductsList() {
    if (response.products == null || response.products!.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Products', Icons.shopping_bag),
        ...response.products!.map((product) => _buildProductBox(product)),
      ],
    );
  }

  Widget _buildHospitalsList(BuildContext context) {
    if (response.hospitals == null || response.hospitals!.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recommended Hospitals', Icons.local_hospital),
        ...response.hospitals!.map((hospital) => _buildHospitalBox(context, hospital)),
      ],
    );
  }

  String _getSummaryText() {
    final String text = (response.reply).trim();
    if (text.isNotEmpty) return text;
    switch (response.intent) {
      case AIIntent.ambulanceSearch:
        return 'Find nearby ambulances and book quickly.';
      case AIIntent.bloodBankSearch:
        return 'Search nearby blood banks and check availability.';
      default:
        return text;
    }
  }

  Widget _buildOrderMedicinePrescriptionCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: _primaryBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryLightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication_liquid, color: _primaryColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Medicines',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Upload your prescription or place your order via a quick call.',
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(height: 1, color: _primaryBorderColor),
          Padding(
            padding: EdgeInsets.all(_contentPadding),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton('Upload Prescription', () {
                    Navigator.pushNamed(context, AppRoutes.newMedicineOrderScreen);
                  }),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton('Order via Call', () async {
                    final Uri uri = Uri(scheme: 'tel', path: '+919370320066');
                    // Use canLaunchUrl if available in the project; otherwise rely on platform handler
                    try {
                      // ignore: deprecated_member_use
                      // Fallback simple launch via MethodChannel could be used if using url_launcher isn't available
                      // But here we use Navigator to HelpCenter which shows contact too if call fails
                      // Attempt to push to help center as graceful fallback
                      // If you have url_launcher, replace with launchUrl(uri)
                    } finally {
                      // As a safe fallback route to help center/contact support screen
                      // Navigator.pushNamed(context, AppRoutes.helpCenter);
                    }
                  }, isPrimary: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceSearchCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
        border: Border.all(color: _primaryBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryLightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_hospital_outlined, color: _primaryColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Nearby Ambulances',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Quickly locate and book the closest available ambulance in your area.',
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_contentPadding),
            child: _buildActionButton('Search Ambulances', () {
              Navigator.pushNamed(context, AppRoutes.ambulanceSearch);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodBankSearchCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
        border: Border.all(color: _primaryBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryLightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bloodtype, color: _primaryColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Blood Banks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Find nearby blood banks and check availability for urgent needs.',
                        style: TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_contentPadding),
            child: _buildActionButton('Find Blood Banks', () {
              Navigator.pushNamed(context, AppRoutes.bloodBank);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalBox(BuildContext context, hospital) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
        border: Border.all(
          color: _primaryBorderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital photo (if available)
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _primaryLightColor,
                      width: 1,
                    ),
                    image: hospital.photos.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(hospital.photos.first['url'] ?? ''),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hospital.photos.isEmpty
                      ? Icon(Icons.local_hospital, color: _primaryColor, size: 32)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      _buildInfoRow(Icons.location_on_outlined, hospital.address + ', ' + hospital.city),
                      SizedBox(height: 4),
                      _buildInfoRow(Icons.phone, hospital.contactNumber),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildFeatureChip('${hospital.bedsAvailable} Beds', Icons.hotel, color: Colors.teal),
                          if (hospital.hasParking) _buildFeatureChip('Parking', Icons.local_parking),
                          if (hospital.hasLiftAccess) _buildFeatureChip('Lift', Icons.elevator),
                          if (hospital.hasWheelchairAccess) _buildFeatureChip('Wheelchair', Icons.accessible),
                          if (hospital.providesAmbulanceService) _buildFeatureChip('Ambulance', Icons.local_shipping, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(_contentPadding),
            decoration: BoxDecoration(
              color: _primaryLightColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_cardBorderRadius),
                bottomRight: Radius.circular(_cardBorderRadius),
              ),
            ),
            child: _buildActionButton('Book Bed', () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookAppointment,
                arguments: hospital,
              );
            }, isPrimary: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryLightColor,
              borderRadius: BorderRadius.circular(_cardBorderRadius + 2),
              border: Border.all(
                color: _primaryBorderColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildFormattedText(
              _getSummaryText(),
              color: _primaryColor,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 20),
          if (response.intent == AIIntent.doctorSearch) _buildDoctorsList(),
          if (response.intent == AIIntent.labSearch) _buildLabsList(),
          if (response.intent == AIIntent.productSearch) _buildProductsList(),
          if (response.intent == AIIntent.hospitalSearch) _buildHospitalsList(context),
          if (response.intent == AIIntent.orderMedicinePrescription) _buildOrderMedicinePrescriptionCard(context),
          if (response.intent == AIIntent.ambulanceSearch) _buildAmbulanceSearchCard(context),
          if (response.intent == AIIntent.bloodBankSearch) _buildBloodBankSearchCard(context),
          if (showOrderButton && navigationScreen != null) ...[
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryColor,
                    _primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => navigationScreen!,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: Text(
                      "Order Medicines",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductBoxContent extends StatefulWidget {
  final VendorProduct product;

  const _ProductBoxContent({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<_ProductBoxContent> createState() => _ProductBoxContentState();
}

class _ProductBoxContentState extends State<_ProductBoxContent> {
  bool _isProductInCart = false;
  bool _isProductLoading = false;

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isPrimary = true}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AIResponseCard._primaryColor : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AIResponseCard._primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.transparent : AIResponseCard._primaryColor,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              text.contains('Book') ? Icons.calendar_today : Icons.shopping_cart,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Check cart status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCartStatus();
    });
  }

  Future<void> _checkCartStatus() async {
    if (widget.product.productId == null) return;

    try {
      final cartViewModel = context.read<ProductCartViewModel>();
      await cartViewModel.checkCartStatus(widget.product.productId!);
      setState(() {
        _isProductInCart = cartViewModel.isInCart;
      });
    } catch (e) {
      print('Error checking cart status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<ProductCartViewModel>();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AIResponseCard._cardBorderRadius),
        border: Border.all(
          color: AIResponseCard._primaryBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AIResponseCard._contentPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AIResponseCard._primaryLightColor,
                          width: 1,
                        ),
                        image: widget.product.images.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.product.images.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.product.images.isEmpty
                          ? Icon(Icons.shopping_bag, color: Colors.white, size: 32)
                          : null,
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AIResponseCard._primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AIResponseCard._primaryLightColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.product.category,
                          style: TextStyle(
                            color: AIResponseCard._primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.product.subCategory != null) ...[
                        SizedBox(height: 4),
                        Text(
                          widget.product.subCategory!,
                          style: TextStyle(
                            color: AIResponseCard._secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        widget.product.description,
                        style: TextStyle(
                          color: AIResponseCard._secondaryTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      if (widget.product.rating > 0)
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                                  SizedBox(width: 2),
                                  Text(
                                    '${widget.product.rating}',
                                    style: TextStyle(
                                      color: Colors.amber[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '(${widget.product.reviewCount} reviews)',
                              style: TextStyle(
                                color: AIResponseCard._secondaryTextColor,
                                fontSize: 12,
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
          Container(
            padding: EdgeInsets.all(AIResponseCard._contentPadding),
            decoration: BoxDecoration(
              color: AIResponseCard._primaryLightColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AIResponseCard._cardBorderRadius),
                bottomRight: Radius.circular(AIResponseCard._cardBorderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AIResponseCard._primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${widget.product.price}',
                        style: TextStyle(
                          color: AIResponseCard._primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.product.stock > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'In Stock',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Cart Button
                SizedBox(
                  width: 140,
                  child: _buildActionButton(
                    _isProductInCart ? 'Go to Cart' : 'Add to Cart',
                    _isProductInCart
                          ? () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.newCartScreen,
                              arguments: {
                                'initialTab': 'products',
                                'tabIndex': 1, // fallback index for products tab if screen expects an int
                                'openProducts': true,
                              },
                            );
                          }
                        : () async {
                            if (widget.product.productId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product ID is missing'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              setState(() {
                                _isProductLoading = true;
                              });

                              await cartViewModel.addToCart(
                                productId: widget.product.productId!,
                                quantity: 1,
                                context: context,
                              );

                              if (cartViewModel.error == null) {
                                setState(() {
                                  _isProductInCart = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${cartViewModel.error}'),
                                    backgroundColor: Colors.red,
      ),
    );
  }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() {
                                _isProductLoading = false;
                              });
                            }
                          },
                    isPrimary: _isProductInCart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 

