import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

class HealthRecordPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> record;
  final String patientName;

  const HealthRecordPreviewScreen({
    Key? key,
    required this.record,
    required this.patientName,
  }) : super(key: key);

  @override
  State<HealthRecordPreviewScreen> createState() => _HealthRecordPreviewScreenState();
}

class _HealthRecordPreviewScreenState extends State<HealthRecordPreviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _fileType;
  String? _fileExtension;

  @override
  void initState() {
    super.initState();
    _determineFileType();
  }

  void _determineFileType() {
    final url = widget.record['fileUrl'].toLowerCase();
    _fileExtension = url.split('.').last.split('?').first;
    
    if (_fileExtension == 'pdf') {
      _fileType = 'pdf';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(_fileExtension)) {
      _fileType = 'image';
    } else {
      _fileType = 'unknown';
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorConsultationColorPalette.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: DoctorConsultationColorPalette.primaryBlue,
        elevation: 0,
        title: const Text(
          'Health Record Preview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DoctorConsultationColorPalette.primaryBlue,
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildPreview(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: DoctorConsultationColorPalette.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Header with record info
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DoctorConsultationColorPalette.secondaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileIcon(),
                      color: DoctorConsultationColorPalette.secondaryTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.record['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: DoctorConsultationColorPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shared by ${widget.patientName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: DoctorConsultationColorPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: DoctorConsultationColorPalette.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Uploaded on ${DateFormat('MMMM d, yyyy').format(DateTime.parse(widget.record['uploadedAt']))}',
                    style: TextStyle(
                      fontSize: 14,
                      color: DoctorConsultationColorPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Preview content
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildContentPreview(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentPreview() {
    switch (_fileType) {
      case 'pdf':
        return SfPdfViewer.network(
          widget.record['fileUrl'],
          canShowScrollStatus: false,
          canShowPaginationDialog: false,
          enableDoubleTapZooming: true,
          enableTextSelection: true,
        );
      case 'image':
        return PhotoView(
          imageProvider: NetworkImage(widget.record['fileUrl']),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null ? 0 : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
              color: DoctorConsultationColorPalette.primaryBlue,
            ),
          ),
          errorBuilder: (context, error, stackTrace) => _buildErrorView(),
        );
      default:
        return _buildErrorView();
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: DoctorConsultationColorPalette.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to preview this file',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DoctorConsultationColorPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This file type is not supported for preview',
            style: TextStyle(
              fontSize: 14,
              color: DoctorConsultationColorPalette.textSecondary,
            ),
            textAlign: TextAlign.center,
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
      default:
        return Icons.insert_drive_file;
    }
  }
} 