import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class BloodTypeSelectionDialog extends StatefulWidget {
  final List<String>? selectedBloodTypes;
  final Function(List<String>) onBloodTypesSelected;

  const BloodTypeSelectionDialog({
    Key? key,
    required this.selectedBloodTypes,
    required this.onBloodTypesSelected,
  }) : super(key: key);

  @override
  _BloodTypeSelectionDialogState createState() => _BloodTypeSelectionDialogState();
}

class _BloodTypeSelectionDialogState extends State<BloodTypeSelectionDialog> {
  List<String> _selectedBloodTypes = [];

  @override
  void initState() {
    super.initState();
    _selectedBloodTypes = widget.selectedBloodTypes ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded dialog
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Select Blood Types",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              "You can select multiple blood types.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Blood Type Selection
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"].map((bloodType) {
                final isSelected = _selectedBloodTypes.contains(bloodType);
                return ChoiceChip(
                  label: Text(
                    bloodType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.red.shade400,
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedBloodTypes.add(bloodType);
                      } else {
                        _selectedBloodTypes.remove(bloodType);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text("Cancel"),
                ),

                // Confirm Button
                ElevatedButton(
                  onPressed: () {
                    if (_selectedBloodTypes.isNotEmpty) {
                      Navigator.pop(context);
                      widget.onBloodTypesSelected(_selectedBloodTypes);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Confirm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
