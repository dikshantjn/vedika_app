import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';

class LabBottomSheet extends StatefulWidget {
  final LabSearchViewModel viewModel;

  const LabBottomSheet({Key? key, required this.viewModel}) : super(key: key);

  @override
  _LabBottomSheetState createState() => _LabBottomSheetState();
}

class _LabBottomSheetState extends State<LabBottomSheet> {
  Map<int, bool> expandedStates = {};

  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Handle error - could show a snackbar or dialog
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _calculateInitialSize(),
      minChildSize: 0.2,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: [0.2, 0.5, 0.8],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                height: 5,
                width: 50,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.science_outlined, color: ColorPalette.primaryColor, size: 24),
                    SizedBox(width: 12),
                    Text(
                      "Nearby Diagnostic Centers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: widget.viewModel.labs.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: widget.viewModel.labs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final center = widget.viewModel.labs[index];
                          final isExpanded = expandedStates[index] ?? false;
                          
                          return _buildLabCard(center, index, isExpanded);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.science_outlined,
                size: 48,
                color: Colors.grey.withOpacity(0.5),
              ),
              SizedBox(height: 12),
              Text(
                "No diagnostic centers found nearby",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Try adjusting your search area",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabCard(DiagnosticCenter center, int index, bool isExpanded) {
    return GestureDetector(
      onTap: () => _handleLabSelection(center, index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isExpanded ? ColorPalette.primaryColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          center.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${center.address}, ${center.city}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(_getSampleCollectionLabel(center.sampleCollectionMethod)),
                      if (center.emergencyHandlingFastTrack)
                        _buildTag("Emergency Fast Track", isEmergency: true),
                    ],
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection("Business Hours", center.businessTimings),
                    _buildDetailSection("Business Days", center.businessDays.join(", ")),
                    _buildDetailSection("Contact", center.mainContactNumber),
                    if (center.emergencyContactNumber.isNotEmpty)
                      _buildDetailSection("Emergency Contact", center.emergencyContactNumber),
                    _buildDetailSection("Email", center.email),
                    if (center.website.isNotEmpty)
                      _buildDetailSection("Website", center.website),
                    
                    SizedBox(height: 16),
                    Text(
                      "Facilities",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (center.parkingAvailable) _buildFacilityTag("Parking"),
                        if (center.wheelchairAccess) _buildFacilityTag("Wheelchair Access"),
                        if (center.liftAccess) _buildFacilityTag("Lift"),
                        if (center.ambulanceServiceAvailable) _buildFacilityTag("Ambulance"),
                      ],
                    ),

                    SizedBox(height: 16),
                    Text(
                      "Available Tests",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: center.testTypes.map((test) => _buildTestTag(test)).toList(),
                    ),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.viewModel.bookLabAppointment(context, center),
                            icon: Icon(Icons.bookmark_outline_sharp, color: Colors.white),
                            label: Text("Book Appointment"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _makeCall(center.mainContactNumber),
                          icon: Icon(Icons.phone, color: Colors.white),
                          label: Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleLabSelection(DiagnosticCenter center, int index) {
    setState(() {
      // Toggle the expanded state for the clicked item
      expandedStates[index] = !(expandedStates[index] ?? false);
      
      // Collapse other items
      expandedStates.forEach((key, value) {
        if (key != index) {
          expandedStates[key] = false;
        }
      });
    });

    try {
      if (center.location.isNotEmpty) {
        final parts = center.location.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0]);
          final lng = double.tryParse(parts[1]);
          if (lat != null && lng != null) {
            widget.viewModel.moveCameraToLab(lat, lng, center);
            return;
          }
        }
      }
      widget.viewModel.selectLabWithoutMovingCamera(center);
    } catch (e) {
      widget.viewModel.selectLabWithoutMovingCamera(center);
    }
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForLabel(label),
              size: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'business hours':
        return Icons.access_time;
      case 'business days':
        return Icons.calendar_today;
      case 'contact':
        return Icons.phone;
      case 'emergency contact':
        return Icons.emergency;
      case 'email':
        return Icons.email;
      case 'website':
        return Icons.web;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildTag(String text, {bool isEmergency = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEmergency ? Colors.red.withOpacity(0.1) : ColorPalette.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency ? Colors.red.withOpacity(0.3) : ColorPalette.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmergency ? Icons.emergency : Icons.science_outlined,
            size: 14,
            color: isEmergency ? Colors.red : ColorPalette.primaryColor,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isEmergency ? Colors.red : ColorPalette.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityTag(String facility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            facility,
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTag(String test) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorPalette.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        test,
        style: TextStyle(
          color: ColorPalette.primaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getSampleCollectionLabel(String method) {
    switch (method.toLowerCase()) {
      case 'at home':
        return 'Home Collection';
      case 'at center':
        return 'At Center';
      case 'both':
        return 'Home & Center Collection';
      default:
        return method;
    }
  }

  double _calculateInitialSize() {
    int itemCount = widget.viewModel.labs.length;
    if (itemCount == 0) return 0.2;
    if (itemCount < 3) return 0.3;
    return 0.5;
  }
}
