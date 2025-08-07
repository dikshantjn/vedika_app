import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine if it's a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Common breakpoint for tablets
    
    // Calculate responsive card width
    final cardWidth = isTablet ? (screenWidth - 80) / 2 : screenWidth - 40; // 2 cards on tablet, 1 on mobile

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
          isTablet 
            ? _buildTabletLayout(cardWidth)
            : _buildMobileLayout(cardWidth),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(double cardWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTestimonialCard(
            'Dr. Vishal Bhandari',
            'Anesthesiologist',
            'MBBS, MD (Internal Medicine)',
            '15 years experience',
            'Pune',
            'A seasoned anesthesiologist renowned in Pune region for anesthesia expertise. Known for his calm presence in stressful OR and ICU settings, supporting safe surgical outcomes and patient comfort.',
            'assets/doctorsPic/DrVishalBhandari.jpeg',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Piyush Lodha',
            'Endocrinologist',
            'MBBS, MD – Medicine, DM – Endocrinology',
            '12 years experience',
            'Pune',
            'A distinguished endocrinologist treating hormonal disorders across ages—from diabetes and thyroid to growth and adrenal diseases. Has strong academic credentials with award-winning conference papers and integrates advanced tools for diabetes management.',
            'assets/doctorsPic/Piyush-Lodha.jpg',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Sachin Lakade',
            'Cardiologist',
            'MBBS, MD – General Medicine, DNB – Cardiology',
            '17 years experience',
            'Pune',
            'A well-established cardiologist currently consulting at Bhakare Super Speciality and VishwaRaj Hospital. Delivers full suite of cardiac services from preventive care to angioplasty and pacemaker management.',
            'assets/doctorsPic/Dr.sachin-lakade.png',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Sweta Lunkad',
            'Haematologist',
            'MBBS, DNB – General Medicine, DM – Clinical Haematology',
            '17 years experience',
            'Pune',
            'A leading haematologist heading hematology and bone marrow transplant services at Lakshya Cancer Care and Jupiter Hospital. Performs complex BMTs including autologous, allogeneic, MUD and haploidentical transplants.',
            'assets/doctorsPic/Dr.-Sweta-Lunkad.webp',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Rajeev Joshi',
            'Orthopaedic Surgeon',
            'MBBS, MS – Orthopaedics',
            '33 years experience',
            'Pune',
            'A senior orthopedic surgeon at Sancheti Hospital, renowned for hip and knee replacement surgeries. With over three decades of surgical practice, handles complex reconstructive cases and trauma-related joint repairs.',
            'assets/doctorsPic/DrRajivJoshi.jpeg',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Amrut Oswal',
            'Orthopaedic Surgeon',
            'MBBS, Diploma in Orthopaedics, MS – Orthopaedics',
            '36 years experience',
            'Pune',
            'A veteran orthopedic surgeon at KEM Hospital Pune specializing in hip/knee replacements, spinal procedures, and complex fracture care. With broad surgical mastery across joint reconstruction and trauma.',
            'assets/doctorsPic/Dr.AmrutOswal.jpg',
            cardWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double cardWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTestimonialCard(
            'Dr. Vishal Bhandari',
            'Anesthesiologist',
            'MBBS, MD (Internal Medicine)',
            '15 years experience',
            'Pune',
            'A seasoned anesthesiologist renowned in Pune region for anesthesia expertise. Known for his calm presence in stressful OR and ICU settings, supporting safe surgical outcomes and patient comfort.',
            'assets/doctorsPic/Dr. Vishal Bhandari.jpg',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Piyush Lodha',
            'Endocrinologist',
            'MBBS, MD – Medicine, DM – Endocrinology',
            '12 years experience',
            'Pune',
            'A distinguished endocrinologist treating hormonal disorders across ages—from diabetes and thyroid to growth and adrenal diseases. Has strong academic credentials with award-winning conference papers and integrates advanced tools for diabetes management.',
            'assets/doctorsPic/Piyush-Lodha.jpg',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Sachin Lakade',
            'Cardiologist',
            'MBBS, MD – General Medicine, DNB – Cardiology',
            '17 years experience',
            'Pune',
            'A well-established cardiologist currently consulting at Bhakare Super Speciality and VishwaRaj Hospital. Delivers full suite of cardiac services from preventive care to angioplasty and pacemaker management.',
            'assets/doctorsPic/Dr.sachin-lakade.png',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Sweta Lunkad',
            'Haematologist',
            'MBBS, DNB – General Medicine, DM – Clinical Haematology',
            '17 years experience',
            'Pune',
            'A leading haematologist heading hematology and bone marrow transplant services at Lakshya Cancer Care and Jupiter Hospital. Performs complex BMTs including autologous, allogeneic, MUD and haploidentical transplants.',
            'assets/doctorsPic/Dr.-Sweta-Lunkad.webp',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Rajeev Joshi',
            'Orthopaedic Surgeon',
            'MBBS, MS – Orthopaedics',
            '33 years experience',
            'Pune',
            'A senior orthopedic surgeon at Sancheti Hospital, renowned for hip and knee replacement surgeries. With over three decades of surgical practice, handles complex reconstructive cases and trauma-related joint repairs.',
            'assets/doctorsPic/Dr. Rajeev Joshi.jfif',
            cardWidth,
          ),
          SizedBox(width: 16),
          _buildTestimonialCard(
            'Dr. Amrut Oswal',
            'Orthopaedic Surgeon',
            'MBBS, Diploma in Orthopaedics, MS – Orthopaedics',
            '36 years experience',
            'Pune',
            'A veteran orthopedic surgeon at KEM Hospital Pune specializing in hip/knee replacements, spinal procedures, and complex fracture care. With broad surgical mastery across joint reconstruction and trauma.',
            'assets/doctorsPic/Dr. Amrut Oswal.jfif',
            cardWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String specialty, String qualification, String experience, String location, String testimonial, String imagePath, double cardWidth) {
    return Container(
      width: cardWidth,
      height: 380, // Fixed height for consistent card sizes
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
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 30,
                          color: ColorPalette.primaryColor,
                        );
                      },
                    ),
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
            
            // Testimonial Quote - Fixed height with Expanded and no ellipsis
            Expanded(
              child: Container(
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
                    Expanded(
                      child: Text(
                        testimonial,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.justify,
                      ),
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
}