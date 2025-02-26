import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';

class BloodTypeSelectionDialog extends StatefulWidget {
  final List<String>? selectedBloodTypes;
  final Function(List<String>) onBloodTypesSelected;
  final Function(String)? onPrescriptionSelected;
  final VoidCallback? onRequestConfirm;

  const BloodTypeSelectionDialog({
    Key? key,
    required this.selectedBloodTypes,
    required this.onBloodTypesSelected,
    this.onPrescriptionSelected,
    this.onRequestConfirm,
  }) : super(key: key);

  @override
  _BloodTypeSelectionDialogState createState() => _BloodTypeSelectionDialogState();
}

class _BloodTypeSelectionDialogState extends State<BloodTypeSelectionDialog> {
  List<String> _selectedBloodTypes = [];
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    _selectedBloodTypes = widget.selectedBloodTypes ?? [];
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _uploadedFileName = result.files.single.name;
      });

      // Trigger onPrescriptionSelected callback
      widget.onPrescriptionSelected?.call(result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                return SizedBox(
                  width: 80, // Fixed width for uniform size
                  height: 40, // Fixed height for uniform size
                  child: ChoiceChip(
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
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Upload Prescription Button (Visible after selecting a blood type)
            if (_selectedBloodTypes.isNotEmpty)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text("Upload Prescription"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (_uploadedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Uploaded: $_uploadedFileName",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
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
                  onPressed: (_selectedBloodTypes.isNotEmpty && _uploadedFileName != null)
                      ? () {
                    widget.onBloodTypesSelected(_selectedBloodTypes);
                    widget.onRequestConfirm?.call(); // Trigger onRequestConfirm
                    Navigator.pop(context);
                  }
                      : null, // Disable button if no file is uploaded
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    disabledBackgroundColor: Colors.grey,
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
