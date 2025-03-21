import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/shared/utils/firebase_metadata_service.dart';

class CertificateListBuilder {
  final FirebaseMetadataService _metadataService = FirebaseMetadataService();

  List<Widget> buildCertificateList(String encodedUrls) {
    try {
      List<String> urls = List<String>.from(jsonDecode(encodedUrls));

      return urls.map((url) {
        return FutureBuilder<FullMetadata>(
          future: _metadataService.getFileMetadata(url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
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
        const Text("Error loading certificates", style: TextStyle(color: Colors.red))
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
