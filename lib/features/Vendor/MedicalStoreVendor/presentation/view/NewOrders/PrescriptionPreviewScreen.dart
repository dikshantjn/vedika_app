import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class PrescriptionPreviewScreen extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const PrescriptionPreviewScreen({Key? key, required this.fileUrl, required this.fileName}) : super(key: key);

  bool get _isPdf => fileUrl.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          fileName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final uri = Uri.parse(fileUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            tooltip: 'Open externally',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isPdf ? _buildPdfHint(context) : _buildImagePreview(context),
    );
  }

  Widget _buildPdfHint(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red[400], size: 56),
            const SizedBox(height: 16),
            const Text(
              'PDF preview is not supported here. Tap the button below to open in your PDF viewer.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return PhotoView(
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      imageProvider: NetworkImage(fileUrl),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}


