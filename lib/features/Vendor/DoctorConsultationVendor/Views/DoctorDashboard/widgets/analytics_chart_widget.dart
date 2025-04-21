import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class AnalyticsChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isLoading;

  const AnalyticsChartWidget({
    Key? key,
    required this.data,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: DoctorConsultationColorPalette.primaryBlue,
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DoctorConsultationColorPalette.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Patient and appointment trends',
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem(
                color: DoctorConsultationColorPalette.primaryBlue,
                label: 'Patients',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                color: DoctorConsultationColorPalette.secondaryTeal,
                label: 'Appointments',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        color: DoctorConsultationColorPalette.textSecondary,
                      ),
                    ),
                  )
                : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DoctorConsultationColorPalette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    // Find the maximum value to scale the bars properly
    double maxValue = 0;
    for (var item in data) {
      if ((item['patients'] as int) > maxValue) {
        maxValue = (item['patients'] as int).toDouble();
      }
      if ((item['appointments'] as int) > maxValue) {
        maxValue = (item['appointments'] as int).toDouble();
      }
    }
    
    // Add 10% padding to the maximum value
    maxValue *= 1.1;

    return Row(
      children: data.map((item) {
        final double patientBarHeight = 
            (item['patients'] as int) / maxValue * 130;
        final double appointmentBarHeight = 
            (item['appointments'] as int) / maxValue * 130;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Y-axis label for patients
                Text(
                  '${item['patients']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                // Bars container with fixed height to prevent overflow
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Place both bars side by side
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Patient bar
                          Container(
                            height: patientBarHeight,
                            width: 8,
                            decoration: BoxDecoration(
                              color: DoctorConsultationColorPalette.primaryBlue,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // Appointment bar
                          Container(
                            height: appointmentBarHeight,
                            width: 8,
                            decoration: BoxDecoration(
                              color: DoctorConsultationColorPalette.secondaryTeal,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // X-axis label (month)
                Text(
                  item['month'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
} 