import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/FilePreviewGrid.dart';

class UploadSectionWidget extends StatefulWidget {
  final String label;
  final Function(List<Map<String, Object>>) onFilesSelected; // Ensure File & String type

  const UploadSectionWidget({
    Key? key,
    required this.label,
    required this.onFilesSelected,
  }) : super(key: key);

  @override
  _UploadSectionWidgetState createState() => _UploadSectionWidgetState();
}

class _UploadSectionWidgetState extends State<UploadSectionWidget> {
  final TextEditingController _fileNameController = TextEditingController();
  List<Map<String, Object>> selectedFiles = []; // Store only File & String
  bool _isUploadEnabled = false; // Track button state

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_updateUploadButtonState);
  }

  @override
  void dispose() {
    _fileNameController.removeListener(_updateUploadButtonState);
    _fileNameController.dispose();
    super.dispose();
  }

  /// Enable upload button only when text is entered
  void _updateUploadButtonState() {
    setState(() {
      _isUploadEnabled = _fileNameController.text.isNotEmpty;
    });
  }

  /// Pick files and update the list
  Future<void> _pickFiles() async {
    if (!_isUploadEnabled) return; // Prevent picking if button is disabled

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          selectedFiles.add({
            'file': File(file.path!), // Store as File
            'name': _fileNameController.text, // Use entered name
          });
        }
        _fileNameController.clear();
        _isUploadEnabled = false; // Reset button state
      });

      widget.onFilesSelected(selectedFiles);
    }
  }

  /// Remove a selected file
  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(selectedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MedicalStoreVendorColorPalette.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MedicalStoreVendorColorPalette.secondaryColor, width: 1.5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                      hintText: "Enter file name",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: MedicalStoreVendorColorPalette.textColor.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isUploadEnabled ? _pickFiles : null, // Disable when empty
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isUploadEnabled
                        ? MedicalStoreVendorColorPalette.primaryColor
                        : Colors.grey, // Change color when disabled
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.upload_file, size: 18, color: Colors.white),
                  label: const Text(
                    "Pick Files",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (selectedFiles.isNotEmpty)
            FilePreviewGrid(
              files: selectedFiles,
              onRemove: _removeFile,
            ),
        ],
      ),
    );
  }
}
