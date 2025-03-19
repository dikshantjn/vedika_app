import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/FilePreviewGrid.dart';

class FileUploadSectionWidget extends StatelessWidget {
  final String label;
  final Function(List<Map<String, Object>>) onFilesSelected;
  final List<Map<String, dynamic>> files;
  final Function(int) onRemoveFile;

  const FileUploadSectionWidget({
    Key? key,
    required this.label,
    required this.onFilesSelected,
    required this.files,
    required this.onRemoveFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            // Call the file upload logic here
            List<Map<String, Object>>? selectedFiles = await _pickFiles();
            if (selectedFiles != null) {
              onFilesSelected(selectedFiles);
            }
          },
          child: Text("Upload Files"),
        ),
        const SizedBox(height: 20),
        FilePreviewGrid(
          files: files,
          onRemove: onRemoveFile,
        ),
      ],
    );
  }

  Future<List<Map<String, Object>>?> _pickFiles() async {
    // Implement file picker logic here, for example using the file_picker package
    return [];
  }
}
