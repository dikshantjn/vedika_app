import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/EditAgencyProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/Registration/AmbulanceAgencyLocationPicker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/AmbulanceAgencyColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/DeleteFileDialog.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/EditFileDialog.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/widgets/updateProfile/FileUploadDialog.dart';

class MediaLocationSection extends StatelessWidget {
  final EditAgencyProfileViewModel viewModel;

  const MediaLocationSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.mediaLocationKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Media & Location",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(
                  label: "Driver License",
                  controller: viewModel.driverLicenseController,
                  icon: Icons.badge,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter driver license'
                      : null,
                ),
                const SizedBox(height: 20),

                // Training Certifications Section
                _buildSectionTitleRow(context,"Training Certifications", 'trainingCertifications',viewModel),

                viewModel.trainingCertifications.isNotEmpty
                    ? _buildImageGrid(viewModel.trainingCertifications, 'trainingCertifications')
                    : const Text("No certifications uploaded.", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                // Office Photos Section
                _buildSectionTitleRow(context,"Office Photos", 'officePhotos', viewModel),

                viewModel.officePhotos.isNotEmpty
                    ? _buildImageGrid(viewModel.officePhotos, 'officePhotos')
                    : const Text("No office photos uploaded.", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                // Precise Location Section
                _buildSectionTitle("Precise Location"),
                const SizedBox(height: 6),
                AmbulanceAgencyLocationPicker(
                  initialLocation: viewModel.preciseLocationController.text,
                  onLocationSelected: (newLocation) {
                    viewModel.preciseLocationController.text = newLocation;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitleRow(BuildContext context, String title, String fileType, EditAgencyProfileViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.blue),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => FileUploadDialog(
                fileType: fileType,
                viewModel: viewModel, // Pass viewModel to the dialog
              ),
            );
          },
        ),
      ],
    );
  }




  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AmbulanceAgencyColorPalette.secondaryTeal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }

  Widget _buildImageGrid(List<Map<String, String>> items, String fileType) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GridView.builder(
        itemCount: items.isEmpty ? 1 : items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8, // keep label space
        ),
        itemBuilder: (context, index) {
          final file = items[index];

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: width,
                    height: width, // 👈 square box
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: file['url'] != null && file['url']!.isNotEmpty
                                ? Image.network(
                              file['url']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(Icons.broken_image,
                                    size: 40, color: Colors.grey),
                              ),
                            )
                                : const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Row(
                            children: [
                              _buildActionIcon(Icons.edit, Colors.blue, () {
                                showDialog(
                                  context: context,
                                  builder: (_) => EditFileDialog(
                                    currentName: file['name']!,
                                    onFileSelected: (newName, pickedFile) {
                                      viewModel.replaceFile(
                                        oldName: file['name']!,
                                        newName: newName,
                                        file: File(pickedFile.path!),
                                        fileType: fileType, // ✅ pass dynamic fileType
                                      );
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(width: 6),
                              _buildActionIcon(Icons.delete, Colors.red, () {
                                showDialog(
                                  context: context,
                                  builder: (_) => DeleteFileDialog(
                                    fileName: file['name']!,
                                    onConfirm: () {
                                      viewModel.deleteFile(
                                        name: file['name']!,
                                        fileType: fileType, // ✅ pass dynamic fileType
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }



  Widget _buildEmptyPlaceholder() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1, // Makes it a square
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Icon(Icons.insert_photo, size: 40, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "No files uploaded",
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
