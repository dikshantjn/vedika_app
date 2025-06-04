import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class HealthRecordPreviewScreen extends StatefulWidget {
  final HealthRecord record;

  const HealthRecordPreviewScreen({Key? key, required this.record}) : super(key: key);

  @override
  State<HealthRecordPreviewScreen> createState() => _HealthRecordPreviewScreenState();
}

class _HealthRecordPreviewScreenState extends State<HealthRecordPreviewScreen> {
  bool _isLoading = false;
  bool _isSharing = false;
  String? _fileType;
  String? _fileExtension;

  @override
  void initState() {
    super.initState();
    _determineFileType();
  }

  void _determineFileType() {
    final url = widget.record.fileUrl.toLowerCase();
    _fileExtension = url.split('.').last.split('?').first;
    
    if (_fileExtension == 'pdf') {
      _fileType = 'pdf';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(_fileExtension)) {
      _fileType = 'image';
    } else if (['doc', 'docx'].contains(_fileExtension)) {
      _fileType = 'document';
    } else if (['xls', 'xlsx'].contains(_fileExtension)) {
      _fileType = 'spreadsheet';
    } else if (['ppt', 'pptx'].contains(_fileExtension)) {
      _fileType = 'presentation';
    } else if (['txt', 'csv'].contains(_fileExtension)) {
      _fileType = 'text';
    } else {
      _fileType = 'unknown';
    }
  }

  Future<void> _downloadFile() async {
    try {
      setState(() => _isLoading = true);
      print('📤 Starting file download...');
      print('📤 File URL: ${widget.record.fileUrl}');
      
      final response = await http.get(Uri.parse(widget.record.fileUrl));
      print('📥 Download response status: ${response.statusCode}');
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${widget.record.name}.$_fileExtension';
      final file = File('${directory.path}/$fileName');
      print('📁 Saving file to: ${file.path}');
      
      await file.writeAsBytes(response.bodyBytes);
      print('✅ File saved successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded to ${file.path}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      // Try to open the file after downloading
      print('📂 Attempting to open file...');
      final result = await OpenFile.open(file.path);
      print('📂 Open file result: ${result.type} - ${result.message}');
      
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e, stackTrace) {
      print('❌ Error downloading file:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareFile() async {
    try {
      setState(() => _isSharing = true);
      print('📤 Starting file share process...');
      print('📤 File URL: ${widget.record.fileUrl}');
      
      // First download the file
      print('📥 Downloading file...');
      final response = await http.get(Uri.parse(widget.record.fileUrl));
      print('📥 Download response status: ${response.statusCode}');
      
      // Get the temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final fileName = '${widget.record.name}.$_fileExtension';
      final file = File('${directory.path}/$fileName');
      print('📁 Saving file to: ${file.path}');
      
      await file.writeAsBytes(response.bodyBytes);
      print('✅ File saved successfully');

      // Share the actual file
      print('📤 Sharing file...');
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my health record: ${widget.record.name}',
      );
      print('✅ File shared successfully');
      
      // Clean up the temporary file after sharing
      if (await file.exists()) {
        await file.delete();
        print('🧹 Temporary file cleaned up');
      }
    } catch (e, stackTrace) {
      print('❌ Error sharing file:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _openInBrowser() async {
    try {
      final Uri url = Uri.parse(widget.record.fileUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.record.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              widget.record.type,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share, color: Colors.white),
            onPressed: _isSharing ? null : _shareFile,
            tooltip: 'Share',
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _isLoading ? null : _downloadFile,
            tooltip: 'Download',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: ColorPalette.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fileExtension?.toUpperCase() ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    switch (_fileType) {
      case 'pdf':
        return SfPdfViewer.network(
          widget.record.fileUrl,
          canShowScrollStatus: false,
          canShowPaginationDialog: false,
          enableDoubleTapZooming: true,
          enableTextSelection: true,
        );
      case 'image':
        return PhotoView(
          imageProvider: NetworkImage(widget.record.fileUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null ? 0 : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => _buildErrorView(),
        );
      case 'document':
      case 'spreadsheet':
      case 'presentation':
      case 'text':
        return _buildFilePreviewCard();
      default:
        return _buildFilePreviewCard();
    }
  }

  Widget _buildFilePreviewCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(),
            size: 80,
            color: ColorPalette.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            widget.record.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_fileExtension?.toUpperCase()} File',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.download,
                label: 'Download',
                onPressed: _downloadFile,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.open_in_browser,
                label: 'Open',
                onPressed: _openInBrowser,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 60),
          const SizedBox(height: 16),
          Text(
            'Unable to preview this file',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can download or open it in browser',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.download,
                label: 'Download',
                onPressed: _downloadFile,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.open_in_browser,
                label: 'Open',
                onPressed: _openInBrowser,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    switch (_fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'text':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
} 