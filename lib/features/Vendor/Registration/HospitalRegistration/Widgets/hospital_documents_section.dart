import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/hospital_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/hospital_model.dart';

class HospitalDocumentsSection extends StatefulWidget {
  final HospitalRegistrationViewModel viewModel;
  final VoidCallback onPrevious;
  final VoidCallback onRegister;

  HospitalDocumentsSection({
    required this.viewModel,
    required this.onPrevious,
    required this.onRegister,
  });

  @override
  _HospitalDocumentsSectionState createState() =>
      _HospitalDocumentsSectionState();
}

class _HospitalDocumentsSectionState extends State<HospitalDocumentsSection> {
  final TextEditingController _certificateDescriptionController =
  TextEditingController();
  final TextEditingController _imageDescriptionController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Registration Certificates Section
        Text("Registration Certificates", style: _sectionTitleStyle),
        SizedBox(height: 8),

        // Name and Upload Fields for Registration Certificate
        _buildCertificateField(
          onTap: () => _pickFile(isForCertificates: true),
          controller: _certificateDescriptionController,
          label: widget.viewModel.registrationCertificates.isNotEmpty
              ? "${widget.viewModel.registrationCertificates.length} files selected"
              : "Upload",
          isForCertificates: true,
        ),
        SizedBox(height: 12),

        // Only show the file grid for registration certificates if files are selected
        if (widget.viewModel.registrationCertificates.isNotEmpty)
          _buildFileGrid(
            widget.viewModel.registrationCertificates,
            widget.viewModel.removeRegistrationCertificate,
            isForCertificates: true,
          ),

        // Hospital Images Section (only shown if files are selected)
        if (widget.viewModel.registrationCertificates.isNotEmpty)
          Text("Hospital Images", style: _sectionTitleStyle),
        SizedBox(height: 8),

        // Name and Upload Fields for Hospital Images
        _buildCertificateField(
          onTap: () => _pickFile(isForCertificates: false),
          controller: _imageDescriptionController,
          label: widget.viewModel.imageUrls.isNotEmpty
              ? "${widget.viewModel.imageUrls.length} images selected"
              : "Upload",
          isForCertificates: false,
        ),
        SizedBox(height: 12),

        // Show preview for hospital images if files are selected
        if (widget.viewModel.imageUrls.isNotEmpty)
          _buildFileGrid(
            widget.viewModel.imageUrls,
            widget.viewModel.removeImage,
            isForCertificates: false,
          ),
        SizedBox(height: 20),

        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Arrow Icon for Previous
            IconButton(
              onPressed: widget.onPrevious,
              icon: Icon(Icons.arrow_circle_left, color: Colors.grey, size: 40),
              tooltip: "Previous",
            ),
            ElevatedButton(
              onPressed: widget.onRegister,
              style: _buttonStyle(Colors.teal),
              child: Text("Register", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }


  /// **Text Style for Section Titles**
  final TextStyle _sectionTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.blueGrey,
  );

  Widget _buildCertificateField({
    required VoidCallback onTap,
    required TextEditingController controller,
    required String label,
    required bool isForCertificates,
  }) {
    return Row(
      children: [
        // Name Field for Certificate/Image
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Certificate/Image",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                // Disable the upload field if the name is empty
              });
            },
          ),
        ),
        SizedBox(width: 8),
        // File Picker for Upload (Enabled if name is provided)
        GestureDetector(
          onTap: controller.text.isNotEmpty ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                  color: controller.text.isNotEmpty
                      ? Colors.teal
                      : Colors.grey,
                  width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.teal),
                SizedBox(width: 10),
                // Removed the Expanded widget here to avoid layout issues
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **Grid for Displaying Selected Files (Images & Documents)**
  Widget _buildFileGrid(List<dynamic> files, Function(dynamic) onRemove, {required bool isForCertificates}) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          var file = files[index];

          // Handle Hospital Image or Registration Certificate
          bool isImage = false;
          String description = '';

          if (isForCertificates) {
            // If it's a certificate, check for its description
            description = file is RegistrationCertificate
                ? file.certificateName
                : 'No description';
          } else {
            // If it's a hospital image, check if it's an image type
            isImage = file is HospitalImage &&
                (file.imageUrl.toLowerCase().endsWith('.jpg') ||
                    file.imageUrl.toLowerCase().endsWith('.png'));
            description = file is HospitalImage ? file.imageDescription : 'No description';
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isImage
                    ? Image.file(File(file.imageUrl), fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.insert_drive_file, size: 40, color: Colors.grey[600]),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  padding: EdgeInsets.all(6),
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    description.isNotEmpty ? description : 'No description',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => onRemove(file), // This will now work with dynamic type
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 12,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  /// **File Picker for Multiple Files**
  Future<void> _pickFile({required bool isForCertificates}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'], // Allow PDFs for certificates
      allowMultiple: true,
    );

    if (result != null) {
      List<String> selectedPaths = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();

      if (selectedPaths.isNotEmpty) {
        if (isForCertificates) {
          // Creating RegistrationCertificate objects from selected paths
          List<RegistrationCertificate> newCertificates = selectedPaths.map((path) {
            return RegistrationCertificate(
              certificateUrl: path,
              certificateName: _certificateDescriptionController.text,
            );
          }).toList();

          // Updating the ViewModel with the new certificates
          widget.viewModel.setRegistrationCertificates([
            ...widget.viewModel.registrationCertificates,
            ...newCertificates,
          ]);

          // Erase certificate description after upload
          _certificateDescriptionController.clear();
        } else {
          // Creating HospitalImage objects from selected paths
          List<HospitalImage> newHospitalImages = selectedPaths.map((path) {
            return HospitalImage(
              imageUrl: path,
              imageDescription: _imageDescriptionController.text,
            );
          }).toList();

          // Updating the ViewModel with the new hospital images
          widget.viewModel.setHospitalImages([
            ...widget.viewModel.imageUrls,
            ...newHospitalImages,
          ]);

          // Erase image description after upload
          _imageDescriptionController.clear();
        }
      }
    }
  }


  /// **Button Styling**
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
