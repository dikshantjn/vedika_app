import 'package:flutter/material.dart';
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
  Map<int, bool> expandedStates = {}; // Track expanded state of each lab

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _calculateInitialSize(),
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                height: 5,
                width: 50,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Nearby Diagnostic Centers",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),

              Expanded(
                child: widget.viewModel.labs.isEmpty
                    ? Center(child: Text("No diagnostic centers found nearby"))
                    : ListView.separated(
                  controller: scrollController,
                  itemCount: widget.viewModel.labs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8), // Spacing between items
                  itemBuilder: (context, index) {
                    final center = widget.viewModel.labs[index];
                    final isExpanded = expandedStates[index] ?? false;
                    
                    // Extract location coordinates if available
                    double? lat, lng;
                    try {
                      if (center.location.isNotEmpty) {
                        final parts = center.location.split(',');
                        if (parts.length == 2) {
                          lat = double.tryParse(parts[0]);
                          lng = double.tryParse(parts[1]);
                        }
                      }
                    } catch (e) {
                      // Handle parsing errors silently
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          expandedStates.forEach((key, value) => expandedStates[key] = false); // Collapse others
                          expandedStates[index] = true;
                        });

                        // Move camera to selected lab if coordinates available
                        if (lat != null && lng != null) {
                          widget.viewModel.moveCameraToLab(lat, lng, center);
                        } else {
                          // Just select the lab without moving camera
                          widget.viewModel.selectLabWithoutMovingCamera(center);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorPalette.lighterPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Center Name
                            Text(
                              center.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 5),

                            // Address
                            Text(
                              "${center.address}, ${center.city}, ${center.state} - ${center.pincode}",
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 5),

                            // Tags: Sample Collection Method
                            Row(
                              children: [
                                _buildTag(_getSampleCollectionLabel(center.sampleCollectionMethod), ColorPalette.textColor2),
                                if (center.emergencyHandlingFastTrack) ...[
                                  SizedBox(width: 8),
                                  _buildTag("Emergency Fast Track", ColorPalette.accentColor),
                                ],
                              ],
                            ),

                            // Expandable Section (Other Details)
                            if (isExpanded) ...[
                              SizedBox(height: 10),
                              Divider(),

                              _buildDetailRow("Business Hours", center.businessTimings),
                              _buildDetailRow("Business Days", center.businessDays.join(", ")),
                              _buildDetailRow("Contact", center.mainContactNumber),
                              if (center.emergencyContactNumber.isNotEmpty)
                                _buildDetailRow("Emergency Contact", center.emergencyContactNumber),
                              _buildDetailRow("Email", center.email),
                              if (center.website.isNotEmpty)
                                _buildDetailRow("Website", center.website),
                              
                              // Facilities
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Facilities",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ),
                              
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (center.parkingAvailable) _buildFacilityTag("Parking Available"),
                                  if (center.wheelchairAccess) _buildFacilityTag("Wheelchair Access"),
                                  if (center.liftAccess) _buildFacilityTag("Lift Access"),
                                  if (center.ambulanceServiceAvailable) _buildFacilityTag("Ambulance Service"),
                                ],
                              ),

                              // Test Types
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Available Tests",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: center.testTypes.map((test) => _buildTestTag(test)).toList(),
                              ),

                              SizedBox(height: 10),

                              // Book Appointment Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => widget.viewModel.bookLabAppointment(context, center),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: ColorPalette.buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.black, width: 1),
                                    ),
                                  ),
                                  child: Text("Book Appointment"),
                                ),
                              )
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  /// Creates a key-value row for details like Operating Hours & Contact
  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates rounded tags for collection methods, etc.
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  /// Creates a facility indicator
  Widget _buildFacilityTag(String facility) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text(facility, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// Creates rounded test tags
  Widget _buildTestTag(String test) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.testBoxBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorPalette.testBoxBorder, width: 1),
      ),
      child: Text(test, style: TextStyle(color: ColorPalette.testBoxText, fontWeight: FontWeight.w500)),
    );
  }

  /// Dynamically sets the initial size of the bottom sheet based on the number of labs
  double _calculateInitialSize() {
    int itemCount = widget.viewModel.labs.length;
    if (itemCount == 0) return 0.2;
    if (itemCount < 3) return 0.3;
    return 0.5;
  }
}
