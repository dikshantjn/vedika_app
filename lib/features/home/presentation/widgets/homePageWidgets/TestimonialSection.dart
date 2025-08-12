import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({Key? key}) : super(key: key);

  // Separate data sources for mobile and tablet views
  static const List<Map<String, String>> _mobileTestimonials = [
    {
      'name': 'Dr. Vishal Bhandari',
      'specialty': 'Anesthesiologist',
      'qualification': 'MBBS, MD (Internal Medicine)',
      'experience': '15 years experience',
      'location': 'Pune',
      'testimonial':
          'A seasoned anesthesiologist renowned in Pune region for anesthesia expertise. Known for his calm presence in stressful OR and ICU settings, supporting safe surgical outcomes and patient comfort.',
      'imagePath': 'assets/doctorsPic/DrVishalBhandari.jpeg',
    },
    {
      'name': 'Dr. Piyush Lodha',
      'specialty': 'Endocrinologist',
      'qualification': 'MBBS, MD – Medicine, DM – Endocrinology',
      'experience': '12 years experience',
      'location': 'Pune',
      'testimonial':
          'A distinguished endocrinologist treating hormonal disorders across ages—from diabetes and thyroid to growth and adrenal diseases. Has strong academic credentials with award-winning conference papers and integrates advanced tools for diabetes management.',
      'imagePath': 'assets/doctorsPic/Piyush-Lodha.jpg',
    },
    {
      'name': 'Dr. Sachin Lakade',
      'specialty': 'Cardiologist',
      'qualification': 'MBBS, MD – General Medicine, DNB – Cardiology',
      'experience': '17 years experience',
      'location': 'Pune',
      'testimonial':
          'A well-established cardiologist delivering comprehensive cardiac care, from preventive screening to advanced procedures like angioplasty and pacemaker management. Known for his patient-centric approach and precision in diagnosis.',
      'imagePath': 'assets/doctorsPic/Dr.sachin-lakade.png',
    },
    {
      'name': 'Dr. Sweta Lunkad',
      'specialty': 'Haematologist',
      'qualification': 'MBBS, DNB – General Medicine, DM – Clinical Haematology',
      'experience': '17 years experience',
      'location': 'Pune',
      'testimonial':
          'A leading haematologist performing advanced bone marrow transplants including autologous, allogeneic, MUD and haploidentical types. Recognized for expertise in complex blood disorders and compassionate patient care.',
      'imagePath': 'assets/doctorsPic/Dr.-Sweta-Lunkad.webp',
    },
    {
      'name': 'Dr. Rajeev Doshi',
      'specialty': 'General Surgeon, Laparoscopic Surgeon, Proctologist',
      'qualification': 'MBBS, MS – General Surgery, DNB – General Surgery',
      'experience': '25 years experience',
      'location': 'Pune',
      'testimonial':
          'An accomplished surgeon specializing in laparoscopic, gastrointestinal, and proctology procedures. Known for precise minimally invasive techniques and a track record of effective treatment for complex surgical cases.',
      'imagePath': 'assets/doctorsPic/DrRajeevDoshi.jpeg',
    },
    {
      'name': 'Dr. Amrut Oswal',
      'specialty': 'Orthopaedic Surgeon',
      'qualification': 'MBBS, Diploma in Orthopaedics, MS – Orthopaedics',
      'experience': '36 years experience',
      'location': 'Pune',
      'testimonial':
          'A veteran orthopedic surgeon specializing in joint replacement, spinal surgeries, and complex fracture management. Recognized for surgical mastery and dedication to restoring mobility.',
      'imagePath': 'assets/doctorsPic/Dr.AmrutOswal.jpg',
    },
  ];

  static const List<Map<String, String>> _tabletTestimonials = [
    {
      'name': 'Dr. Vishal Bhandari',
      'specialty': 'Anesthesiologist',
      'qualification': 'MBBS, MD (Internal Medicine)',
      'experience': '15 years experience',
      'location': 'Pune',
      'testimonial':
          'A seasoned anesthesiologist renowned in Pune region for anesthesia expertise. Known for his calm presence in stressful OR and ICU settings, supporting safe surgical outcomes and patient comfort.',
      'imagePath': 'assets/doctorsPic/DrVishalBhandari.jpeg',
    },
    {
      'name': 'Dr. Piyush Lodha',
      'specialty': 'Endocrinologist',
      'qualification': 'MBBS, MD – Medicine, DM – Endocrinology',
      'experience': '12 years experience',
      'location': 'Pune',
      'testimonial':
          'A distinguished endocrinologist treating hormonal disorders across ages—from diabetes and thyroid to growth and adrenal diseases. Has strong academic credentials with award-winning conference papers and integrates advanced tools for diabetes management.',
      'imagePath': 'assets/doctorsPic/Piyush-Lodha.jpg',
    },
    {
      'name': 'Dr. Sachin Lakade',
      'specialty': 'Cardiologist',
      'qualification': 'MBBS, MD – General Medicine, DNB – Cardiology',
      'experience': '17 years experience',
      'location': 'Pune',
      'testimonial':
          'A well-established cardiologist delivering comprehensive cardiac care, from preventive screening to advanced procedures like angioplasty and pacemaker management. Known for his patient-centric approach and precision in diagnosis.',
      'imagePath': 'assets/doctorsPic/Dr.sachin-lakade.png',
    },
    {
      'name': 'Dr. Sweta Lunkad',
      'specialty': 'Haematologist',
      'qualification': 'MBBS, DNB – General Medicine, DM – Clinical Haematology',
      'experience': '17 years experience',
      'location': 'Pune',
      'testimonial':
          'A leading haematologist performing advanced bone marrow transplants including autologous, allogeneic, MUD and haploidentical types. Recognized for expertise in complex blood disorders and compassionate patient care.',
      'imagePath': 'assets/doctorsPic/Dr.-Sweta-Lunkad.webp',
    },
    {
      'name': 'Dr. Rajeev Doshi',
      'specialty': 'General Surgeon, Laparoscopic Surgeon, Proctologist',
      'qualification': 'MBBS, MS – General Surgery, DNB – General Surgery',
      'experience': '25 years experience',
      'location': 'Pune',
      'testimonial':
          'An accomplished surgeon specializing in laparoscopic, gastrointestinal, and proctology procedures. Known for precise minimally invasive techniques and a track record of effective treatment for complex surgical cases.',
      'imagePath': 'assets/doctorsPic/DrRajeevDoshi.jpeg',
    },
    {
      'name': 'Dr. Amrut Oswal',
      'specialty': 'Orthopaedic Surgeon',
      'qualification': 'MBBS, Diploma in Orthopaedics, MS – Orthopaedics',
      'experience': '36 years experience',
      'location': 'Pune',
      'testimonial':
          'A veteran orthopedic surgeon specializing in joint replacement, spinal surgeries, and complex fracture management. Recognized for surgical mastery and dedication to restoring mobility.',
      'imagePath': 'assets/doctorsPic/Dr.AmrutOswal.jpg',
    },
  ];

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
    final List<Widget> children = [];
    for (int i = 0; i < _mobileTestimonials.length; i++) {
      final t = _mobileTestimonials[i];
      children.add(
        _buildTestimonialCard(
          t['name']!,
          t['specialty']!,
          t['qualification']!,
          t['experience']!,
          t['location']!,
          t['testimonial']!,
          t['imagePath']!,
          cardWidth,
        ),
      );
      if (i < _mobileTestimonials.length - 1) {
        children.add(SizedBox(width: 16));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(children: children),
    );
  }


  Widget _buildTabletLayout(double cardWidth) {
    final List<Widget> children = [];
    for (int i = 0; i < _tabletTestimonials.length; i++) {
      final t = _tabletTestimonials[i];
      children.add(
        _buildTestimonialCard(
          t['name']!,
          t['specialty']!,
          t['qualification']!,
          t['experience']!,
          t['location']!,
          t['testimonial']!,
          t['imagePath']!,
          cardWidth,
        ),
      );
      if (i < _tabletTestimonials.length - 1) {
        children.add(SizedBox(width: 16));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(children: children),
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