import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart'; // Import LabTestModel

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
                  "Nearby Labs",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),

              Expanded(
                child: widget.viewModel.labs.isEmpty
                    ? Center(child: Text("No labs found nearby"))
                    : ListView.separated(
                  controller: scrollController,
                  itemCount: widget.viewModel.labs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8), // Spacing between items
                  itemBuilder: (context, index) {
                    final lab = widget.viewModel.labs[index];
                    final isExpanded = expandedStates[index] ?? false;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          expandedStates.forEach((key, value) => expandedStates[key] = false); // Collapse others
                          expandedStates[index] = true;
                        });

                        // Move camera to selected lab
                        widget.viewModel.moveCameraToLab(lab.lat, lab.lng, lab);
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
                            // Lab Name
                            Text(
                              lab.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 5),

                            // Address
                            Text(
                              lab.address,
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 5),

                            // Tags: Home Collection / At Center
                            Row(
                              children: [
                                if (lab.homeCollection) _buildTag("Home Collection", ColorPalette.textColor2),
                                SizedBox(width: 8),
                                _buildTag("At Center", ColorPalette.textColor2),
                              ],
                            ),

                            // Expandable Section (Other Details)
                            if (isExpanded) ...[
                              SizedBox(height: 10),
                              Divider(),

                              _buildDetailRow("Operating Hours", lab.operatingHours),
                              _buildDetailRow("Contact", lab.contact),

                              // Lab Tests
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "Available Tests",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: lab.tests.map((LabTestModel test) => _buildTestTag(test)).toList(),
                              ),

                              SizedBox(height: 10),

                              // Book Appointment Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => widget.viewModel.bookLabAppointment(context, lab), // Pass context
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

  /// Creates rounded tags for Home Collection / At Center
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

  /// Creates rounded test tags from LabTestModel
  Widget _buildTestTag(LabTestModel test) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.testBoxBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorPalette.testBoxBorder, width: 1),
      ),
      child: Text(test.name, style: TextStyle(color: ColorPalette.testBoxText, fontWeight: FontWeight.w500)), // Use 'name' property
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
