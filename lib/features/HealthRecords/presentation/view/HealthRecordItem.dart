import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordPreviewScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class HealthRecordItem extends StatefulWidget {
  final HealthRecord record;

  const HealthRecordItem(this.record, {Key? key}) : super(key: key);

  @override
  State<HealthRecordItem> createState() => _HealthRecordItemState();
}

class _HealthRecordItemState extends State<HealthRecordItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isLoadingPreview = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _isLoadingPreview = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _downloadFile(BuildContext context) async {
    // Store the context before starting the download
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Show downloading indicator
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Downloading file...'),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );

      // Get the download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (!await downloadDir!.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Download the file
      final response = await http.get(Uri.parse(widget.record.fileUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      // Create the file
      final fileName = '${widget.record.name}.${_getFileExtension().toLowerCase()}';
      final file = File('${downloadDir.path}/$fileName');
      
      // Save the file
      await file.writeAsBytes(response.bodyBytes);

      // Show success message
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('File downloaded to ${file.path}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              final result = await OpenFile.open(file.path);
              if (result.type != ResultType.done && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error opening file: ${result.message}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error downloading file: $e');
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _loadPreview() async {
    try {
      if (widget.record.fileUrl.endsWith(".pdf")) {
        // For PDFs, we'll consider it loaded when the file is accessible
        final file = File(widget.record.fileUrl);
        if (await file.exists()) {
          setState(() => _isLoadingPreview = false);
        }
      } else if (widget.record.fileUrl.endsWith(".jpg") ||
          widget.record.fileUrl.endsWith(".jpeg") ||
          widget.record.fileUrl.endsWith(".png")) {
        // For images, we'll load them to check if they're accessible
        final response = await http.head(Uri.parse(widget.record.fileUrl));
        if (response.statusCode == 200) {
          setState(() => _isLoadingPreview = false);
        }
      } else {
        // For other file types, we'll just set loading to false
        setState(() => _isLoadingPreview = false);
      }
    } catch (e) {
      print('Error loading preview: $e');
      setState(() => _isLoadingPreview = false);
    }
  }

  void _showBottomSheet(BuildContext context, HealthRecordViewModel healthRecordVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File Details Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorPalette.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getFileIcon(),
                              color: ColorPalette.primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.record.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.record.type,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // File Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              title: 'Uploaded On',
                              value: _formatDate(widget.record.uploadedAt),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.description,
                              title: 'File Type',
                              value: _getFileExtension(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildOutlinedButton(
                              icon: Icons.download_rounded,
                              label: "Download",
                              color: Colors.green,
                              onTap: () async {
                                Navigator.pop(context);
                                await _downloadFile(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildOutlinedButton(
                              icon: Icons.delete_rounded,
                              label: "Delete",
                              color: Colors.red,
                              onTap: () => _deleteRecord(context, healthRecordVM),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    if (widget.record.fileUrl.endsWith(".pdf")) {
      return Icons.picture_as_pdf;
    } else if (widget.record.fileUrl.endsWith(".jpg") ||
        widget.record.fileUrl.endsWith(".jpeg") ||
        widget.record.fileUrl.endsWith(".png")) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  String _getFileExtension() {
    final url = widget.record.fileUrl.toLowerCase();
    final extension = url.split('.').last.split('?').first;
    return extension.toUpperCase();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  void _deleteRecord(BuildContext context, HealthRecordViewModel healthRecordVM) async {
    try {
      // First pop the bottom sheet
      Navigator.pop(context);
      
      // Then delete the record
      await healthRecordVM.deleteRecord(widget.record.healthRecordId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("'${widget.record.name}' deleted successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting record: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthRecordVM = Provider.of<HealthRecordViewModel>(context, listen: false);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthRecordPreviewScreen(record: widget.record),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'record-${widget.record.healthRecordId}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: _buildFilePreview(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showBottomSheet(context, healthRecordVM),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey[700],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.record.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getFileIcon(),
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.record.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    if (widget.record.fileUrl.endsWith(".pdf")) {
      return Stack(
        children: [
          SfPdfViewer.network(
            widget.record.fileUrl,
            canShowScrollStatus: false,
            canShowPaginationDialog: false,
          ),
          if (_isLoadingPreview)
            Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Loading PDF...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else if (widget.record.fileUrl.endsWith(".jpg") ||
        widget.record.fileUrl.endsWith(".jpeg") ||
        widget.record.fileUrl.endsWith(".png")) {
      return Stack(
        children: [
          Image.network(
            widget.record.fileUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                setState(() => _isLoadingPreview = false);
                return child;
              }
              return Container(
                color: Colors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Loading image...",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              setState(() => _isLoadingPreview = false);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      "Error loading image",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 60, color: ColorPalette.primaryColor),
          const SizedBox(height: 8),
          Text(
            "Preview not available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}