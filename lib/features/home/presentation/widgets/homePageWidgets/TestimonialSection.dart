import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assistant,
                  color: Colors.teal,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Advisors",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTestimonialCard(
                  'Dr. Rajesh Deshmukh',
                  'Cardiologist',
                  '15+ Years Experience',
                  'Pune',
                  'Vedika Healthcare has transformed how we manage patient care in Maharashtra. Their digital prescription system has made it easier for patients to access their medications, especially in rural areas.',
                ),
                SizedBox(width: 16),
                _buildTestimonialCard(
                  'Dr. Priya Patil',
                  'Pediatrician',
                  '12+ Years Experience',
                  'Mumbai',
                  'As a pediatrician in Pune, I\'ve seen how Vedika Healthcare has improved healthcare accessibility. Their platform makes it simple for parents to manage their children\'s prescriptions and follow-ups.',
                ),
                SizedBox(width: 16),
                _buildTestimonialCard(
                  'Dr. Vikram Joshi',
                  'Orthopedic Surgeon',
                  '18+ Years Experience',
                  'Nagpur',
                  'The integration of digital health records and prescription management has significantly improved our clinic\'s efficiency in Mumbai. Vedika Healthcare is truly revolutionizing healthcare delivery in Maharashtra.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String specialty, String experience, String location, String testimonial) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ColorPalette.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorPalette.primaryColor.withOpacity(0.2),
                  ColorPalette.primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: ColorPalette.primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 45,
              color: ColorPalette.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          // Text(
          //   name,
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: ColorPalette.primaryColor,
          //     letterSpacing: 0.3,
          //   ),
          // ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              specialty,
              style: TextStyle(
                fontSize: 14,
                color: ColorPalette.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 16,
                  color: ColorPalette.primaryColor,
                ),
                SizedBox(width: 6),
                Text(
                  experience,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorPalette.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: ColorPalette.primaryColor,
                ),
                SizedBox(width: 6),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorPalette.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 24,
                  color: ColorPalette.primaryColor.withOpacity(0.3),
                ),
                SizedBox(height: 8),
                Text(
                  testimonial,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 