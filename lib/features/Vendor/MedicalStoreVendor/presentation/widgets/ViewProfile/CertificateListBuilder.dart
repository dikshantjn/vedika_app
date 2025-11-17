import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/shared/utils/firebase_metadata_service.dart';

class CertificateListBuilder {
  final FirebaseMetadataService _metadataService = FirebaseMetadataService();

  List<Widget> buildCertificateList(String encodedUrls) {
    try {
      // Check if the string is empty or null
      if (encodedUrls.isEmpty || encodedUrls.trim().isEmpty) {
        return [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "No files found",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ];
      }

      List<String> urls = [];
      
      // Check if it's a JSON array
      if (encodedUrls.trim().startsWith('[')) {
        try {
          urls = List<String>.from(jsonDecode(encodedUrls));
        } catch (e) {
          // Not valid JSON, treat as single URL string if it's a valid URL
          if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
            urls = [encodedUrls];
          } else {
            return [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No files found",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ];
          }
        }
      } else {
        // Not a JSON array, check if it's a valid URL
        if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
          urls = [encodedUrls];
        } else {
          // Not a valid URL, show no files message
          return [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No files found",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ];
        }
      }

      if (urls.isEmpty) {
        return [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "No files found",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ];
      }

      return urls.map((url) {
        return FutureBuilder<FullMetadata>(
          future: _metadataService.getFileMetadata(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return _buildCertificateBox("Unknown Certificate", url);
            }

            FullMetadata metadata = snapshot.data!;
            String displayName = metadata.customMetadata?["description"] ?? "Certificate"; // Get the stored title

            return _buildCertificateBox(displayName, url);
          },
        );
      }).toList();
    } catch (e) {
      debugPrint("❌ Error decoding URLs: $e");
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No files found",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ];
    }
  }

  Widget _buildCertificateBox(String label, String fileUrl) {
    print("fileUrl $fileUrl");
    return GestureDetector(
      onTap: () => _openUrl(fileUrl),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.open_in_new, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not launch URL: $url");
    }
  }
}
