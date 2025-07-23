import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
            ColorPalette.primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header Section
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorPalette.primaryColor.withOpacity(0.1),
                  ColorPalette.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPalette.primaryColor,
                        ColorPalette.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.assistant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Advisors",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "Trusted by Healthcare Professionals",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTestimonialCard(
                  'Dr. Rajesh Deshmukh',
                  'Cardiologist',
                  '15+ Years Experience',
                  'Pune',
                  'Vedika Healthcare has transformed how we manage patient care in Maharashtra. Their digital prescription system has made it easier for patients to access their medications, especially in rural areas.',
                ),
                SizedBox(width: 20),
                _buildTestimonialCard(
                  'Dr. Priya Patil',
                  'Pediatrician',
                  '12+ Years Experience',
                  'Mumbai',
                  'As a pediatrician in Pune, I\'ve seen how Vedika Healthcare has improved healthcare accessibility. Their platform makes it simple for parents to manage their children\'s prescriptions and follow-ups.',
                ),
                SizedBox(width: 20),
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
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.12),
            spreadRadius: 0,
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: ColorPalette.primaryColor.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColorPalette.primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Enhanced Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.15),
                          ColorPalette.primaryColor.withOpacity(0.25),
                          ColorPalette.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: ColorPalette.primaryColor.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: ColorPalette.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Name (commented out as in original)
                  // Text(
                  //   name,
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: ColorPalette.primaryColor,
                  //     letterSpacing: 0.3,
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  // Enhanced Specialty Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.15),
                          ColorPalette.primaryColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ColorPalette.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorPalette.primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Enhanced Experience Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.12),
                          ColorPalette.primaryColor.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ColorPalette.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.work_outline,
                            size: 16,
                            color: ColorPalette.primaryColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          experience,
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorPalette.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Enhanced Location Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.12),
                          ColorPalette.primaryColor.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ColorPalette.primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 16,
                            color: ColorPalette.primaryColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorPalette.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Enhanced Testimonial Quote
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.06),
                          ColorPalette.primaryColor.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColorPalette.primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ColorPalette.primaryColor.withOpacity(0.15),
                                    ColorPalette.primaryColor.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.format_quote,
                                size: 20,
                                color: ColorPalette.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          testimonial,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.7,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Enhanced Star Rating
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorPalette.primaryColor.withOpacity(0.1),
                          ColorPalette.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                            (index) => Padding(
                          padding: EdgeInsets.only(right: index < 4 ? 4 : 0),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.star,
                              size: 18,
                              color: ColorPalette.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}