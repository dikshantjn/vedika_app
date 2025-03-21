import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/SectionTitle.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/widgets/UpdateProfile/UploadSectionWidget.dart';
import 'package:vedika_healthcare/shared/utils/firebase_metadata_service.dart';

class MedicalStoreRegistration extends StatelessWidget {
  final MedicalStoreVendorUpdateProfileViewModel viewModel;
  final FirebaseMetadataService metadataService = FirebaseMetadataService();

  MedicalStoreRegistration({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Registration & Licensing"),

        // Registration Certificate upload section
        UploadSectionWidget(
          label: "Upload Registration Certificate (PDF, PNG, JPG)",
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadRegistrationCertificates(files);
          },
        ),

        // Display uploaded registration certificates
        _buildUploadedFilesGrid(
          context,
          "Registration Certificates",
          viewModel.registrationCertificatesList,
              (url) => viewModel.deleteRegistrationCertificate(url),
        ),

        const SizedBox(height: 16),

        // Compliance Certificate upload section
        UploadSectionWidget(
          label: "Upload Compliance Certificate (PDF, PNG, JPG)",
          onFilesSelected: (List<Map<String, Object>> files) {
            viewModel.uploadComplianceCertificates(files);
          },
        ),

        // Display uploaded compliance certificates
        _buildUploadedFilesGrid(
          context,
          "Compliance Certificates",
          viewModel.complianceCertificatesList,
              (url) => viewModel.deleteComplianceCertificate(url),
        ),
      ],
    );
  }

  /// Function to show uploaded files in a GridView with names
  Widget _buildUploadedFilesGrid(
      BuildContext context,
      String title,
      List<String> rawFiles, // Raw list that may contain JSON-encoded URLs
      Function(String) onDelete,
      ) {
    List<String> fileUrls = rawFiles.expand((rawUrl) => _extractValidUrls(rawUrl)).toList(); // Flatten into valid URLs

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        fileUrls.isNotEmpty
            ? GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: fileUrls.length,
          itemBuilder: (context, index) {
            String fileUrl = fileUrls[index];
            print("✅ Processed File URL: $fileUrl");

            return FutureBuilder<String>(
              future: _getFileName(fileUrl),
              builder: (context, snapshot) {
                String fileName = snapshot.data ?? "Loading...";

                return Stack(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fileUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.insert_drive_file, size: 50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fileName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          onDelete(fileUrl);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 12,
                          child: Icon(Icons.delete, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        )
            : const Text("No files uploaded"),
      ],
    );
  }

  /// Fetch file name from Firebase Storage metadata
  Future<String> _getFileName(String fileUrl) async {
    try {
      FullMetadata metadata = await metadataService.getFileMetadata(fileUrl);
      return metadata.customMetadata?["description"] ?? metadata.name ?? _extractFileName(fileUrl);
    } catch (e) {
      debugPrint("❌ Error fetching file name: $e");
      return _extractFileName(fileUrl);
    }
  }

  /// Extracts file name from a URL
  String _extractFileName(String url) {
    try {
      Uri uri = Uri.parse(url);
      return Uri.decodeComponent(uri.pathSegments.last.split('?').first);
    } catch (e) {
      print("❌ Error extracting file name: $e (Input: $url)");
      return "Unknown File";
    }
  }

  /// Extracts valid URLs and filters out local file paths
  List<String> _extractValidUrls(String rawUrl) {
    try {
      if (rawUrl.trim().startsWith("[")) {
        List<dynamic> decodedList = jsonDecode(rawUrl);
        return decodedList
            .whereType<String>()
            .where((url) => url.startsWith("http")) // Only keep valid URLs
            .toList();
      }

      return rawUrl.startsWith("http") ? [rawUrl] : []; // If it's a single valid URL, return it; otherwise, return empty list
    } catch (e) {
      print("⚠️ Error extracting valid URLs: $e (Input: $rawUrl)");
      return [];
    }
  }
}
