import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean Header Section without background
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: ColorPalette.primaryColor,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                "Healthcare Advisors",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Trusted by Healthcare Professionals",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildTestimonialCard(
                  'Dr. Vishal Bhandari',
                  'Anesthesiologist',
                  'MBBS',
                  '15 yrs exp.',
                  'Pune',
                  'Vedika Healthcare has revolutionized patient care in our region. The digital prescription system and seamless medication delivery have significantly improved patient outcomes and accessibility.',
                ),
                SizedBox(width: 16),
                _buildTestimonialCard(
                  'Dr. Piyush Lodha',
                  'Endocrinologist',
                  'MBBS, DM - Endocrinology, MD',
                  '12 Years Experience',
                  'Pune',
                  'As an endocrinologist, I appreciate how Vedika Healthcare streamlines medication management for chronic conditions. Their platform makes it easier for patients to maintain their treatment regimens.',
                ),
                SizedBox(width: 16),
                _buildTestimonialCard(
                  'Dr. Sachin Lakade',
                  'Cardiologist',
                  'MBBS, MD - Cardiology',
                  '17 Years Experience',
                  'Pune',
                  'The integration of digital health records and prescription management has enhanced our clinic\'s efficiency. Vedika Healthcare is truly transforming healthcare delivery in Maharashtra.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String specialty, String qualification, String experience, String location, String testimonial) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Section
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorPalette.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: ColorPalette.primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorPalette.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        qualification,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Experience and Location
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 14,
                        color: ColorPalette.primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        experience,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorPalette.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Testimonial Quote
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 20,
                        color: ColorPalette.primaryColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    testimonial,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < 4 ? 4 : 0),
                  child: Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}