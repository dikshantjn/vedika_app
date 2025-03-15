import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Widgets/MedicalStoreRequestConfirmationDialog.dart';

class MedicalStoreInfoSection extends StatefulWidget {
  final MedicalStoreRegistrationViewModel viewModel;
  final VoidCallback onRegister;
  final VoidCallback onPrevious;

  MedicalStoreInfoSection({
    required this.viewModel,
    required this.onRegister,
    required this.onPrevious,
  });

  @override
  _MedicalStoreInfoSectionState createState() =>
      _MedicalStoreInfoSectionState();
}

class _MedicalStoreInfoSectionState extends State<MedicalStoreInfoSection> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fileNameController = TextEditingController();
  List<File> uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(widget.viewModel.medicineType, "Medicine Type",
                  ["Allopathy", "Homeopathy", "Ayurvedic", "Generic"]),
              _buildTextField(widget.viewModel.specialMedicationsController,
                  "Specialized Medications Available", Icons.medical_services),
              _buildDropdown(widget.viewModel.paymentOptions, "Payment Options",
                  ["Online", "Cash"]),
              _buildChipsSelection(),

              SizedBox(height: 20),

              // Single File Upload Field
              _buildFileUploadRow(
                "Upload Store Documents",
                _fileNameController,
                uploadedFiles,
                    (files) => setState(() => uploadedFiles = files),
              ),
              _buildFilePreview(uploadedFiles),

              SizedBox(height: 20),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button
                  IconButton(
                    onPressed: widget.onPrevious,
                    icon: Icon(Icons.arrow_back, color: Colors.teal, size: 28),
                    tooltip: "Go Back",
                  ),

                  // Make Request Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) => MedicalStoreRequestConfirmationDialog(viewModel:widget.viewModel,),
                        );
                        widget.onRegister();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      backgroundColor: Colors.teal,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Make Request",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// **Dropdown Field**
  Widget _buildDropdown(
      ValueNotifier<String?> notifier, String label, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: options
                .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (newValue) => notifier.value = newValue!,
          );
        },
      ),
    );
  }

  /// **Chips for Selection**
  Widget _buildChipsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additional Facilities",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: [
            _buildChoiceChip("Lift Access", widget.viewModel.liftAccess),
            _buildChoiceChip("Wheelchair Access", widget.viewModel.wheelchairAccess),
            _buildChoiceChip("Parking Available", widget.viewModel.parking),
          ],
        ),
      ],
    );
  }

  /// **Choice Chip Widget**
  Widget _buildChoiceChip(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isSelected, child) {
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (value) => notifier.value = value,
          selectedColor: Colors.teal.shade200,
          backgroundColor: Colors.grey.shade200,
          labelStyle:
          TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      },
    );
  }

  /// **TextField**
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFileUploadRow(
      String label,
      TextEditingController nameController,
      List<File> fileList,
      Function(List<File>) onFilesSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // File Upload Container with Border
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal, width: 1.5), // Added Border
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // File Name Input
                Expanded(
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter file name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Upload Button with Gradient
                GestureDetector(
                  onTap: () async {
                    if (nameController.text.isNotEmpty) {
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);

                      if (result != null) {
                        List<File> files =
                        result.paths.map((path) => File(path!)).toList();
                        onFilesSelected([...fileList, ...files]);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please enter a file name before uploading."),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.upload_file, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  /// **File Preview Grid**
  Widget _buildFilePreview(List<File> files) {
    if (files.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
          File file = files[index];
          bool isImage =
              file.path.toLowerCase().endsWith(".jpg") || file.path.toLowerCase().endsWith(".png");

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.insert_drive_file)),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => setState(() => files.removeAt(index)),
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
}
