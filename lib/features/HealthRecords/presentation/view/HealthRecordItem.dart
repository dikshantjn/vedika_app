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
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class HealthRecordItem extends StatefulWidget {
  final HealthRecord record;
  final bool isSelected;
  final VoidCallback onSelect;
  final bool isSelectionMode;

  const HealthRecordItem(
    this.record, {
    Key? key,
    this.isSelected = false,
    required this.onSelect,
    required this.isSelectionMode,
  }) : super(key: key);

  @override
  State<HealthRecordItem> createState() => _HealthRecordItemState();
}

class _HealthRecordItemState extends State<HealthRecordItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isLoadingPreview = true;
  late HealthRecordViewModel _viewModel;

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
    _viewModel = Provider.of<HealthRecordViewModel>(context, listen: false);
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

  void _showDoctorSelectionDialog(BuildContext context, HealthRecordViewModel healthRecordVM) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Doctor to Share',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (healthRecordVM.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (healthRecordVM.ongoingMeetings.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: healthRecordVM.ongoingMeetings.length,
                          itemBuilder: (context, index) {
                            final appointment = healthRecordVM.ongoingMeetings[index];
                            final doctor = appointment.doctor;
                            if (doctor == null) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context); // Close doctor selection dialog
                                    _showShareConfirmation(context, doctor, appointment);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorPalette.primaryColor.withOpacity(0.2),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Image.network(
                                              doctor.profilePicture,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 25,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor.doctorName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                doctor.specializations.join(', '),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No ongoing appointments found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showShareConfirmation(BuildContext context, DoctorClinicProfile doctor, ClinicAppointment appointment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Share Health Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share with Dr. ${doctor.doctorName}?'),
              const SizedBox(height: 8),
              Text(
                'Appointment: ${appointment.date.toString().split(' ')[0]} at ${appointment.time}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement sharing functionality
                Navigator.pop(context); // Close share confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Health record shared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, HealthRecordViewModel healthRecordVM) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
          );
        },
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

  void _handleTap() {
    if (widget.isSelectionMode) {
      // In selection mode, tap toggles selection
      widget.onSelect();
    } else {
      // Not in selection mode, tap opens preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthRecordPreviewScreen(record: widget.record),
        ),
      );
    }
  }

  void _handleLongPress() {
    if (widget.isSelectionMode) {
      // In selection mode, long press opens preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthRecordPreviewScreen(record: widget.record),
        ),
      );
    } else {
      // Not in selection mode, long press starts selection
      widget.onSelect();
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
      onTap: _handleTap,
      onLongPress: _handleLongPress,
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
            border: widget.isSelected
                ? Border.all(
                    color: ColorPalette.primaryColor,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Column(
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
                        if (widget.isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.primaryColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print('🔍 Share icon tapped');
                                    _showShareBottomSheet(context);
                                  },
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
                                      Icons.share_rounded,
                                      color: ColorPalette.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
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
                            ],
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 40, color: ColorPalette.primaryColor),
          const SizedBox(height: 4),
          Text(
            "Preview not available",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    print('🔄 Building bottom sheet content');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Share with Doctor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: Future.delayed(Duration.zero, () {
                        return _viewModel.loadOngoingMeetings();
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final meetings = context.watch<HealthRecordViewModel>().ongoingMeetings;
                        if (meetings.isEmpty) {
                          return const Center(
                            child: Text('No ongoing appointments found'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: meetings.length,
                          itemBuilder: (context, index) {
                            final meeting = meetings[index];
                            print('👨‍⚕️ Building doctor card for: ${meeting.doctor?.doctorName}');
                            
                            // Format date and time
                            final date = meeting.date;
                            final formattedDate = '${date.day}/${date.month}/${date.year}';
                            final time = meeting.time.split(':');
                            final formattedTime = '${time[0]}:${time[1]} ${int.parse(time[0]) >= 12 ? 'PM' : 'AM'}';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    print('👆 Doctor selected: ${meeting.doctor?.doctorName}');
                                    final success = await _viewModel.shareHealthRecordsWithDoctor(
                                      clinicAppointmentId: meeting.clinicAppointmentId,
                                      healthRecordIds: [widget.record.healthRecordId],
                                    );

                                    if (success) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Shared with Dr. ${meeting.doctor?.doctorName}',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(dialogContext);
                                    } else {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to share health record'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Doctor's Profile Picture
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorPalette.primaryColor.withOpacity(0.2),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: meeting.doctor?.profilePicture != null
                                                ? Image.network(
                                                    meeting.doctor!.profilePicture!,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        color: Colors.grey[100],
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              ColorPalette.primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[100],
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: Colors.grey[400],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Colors.grey[100],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 30,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Doctor's Information
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meeting.doctor?.doctorName ?? 'Unknown Doctor',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D3142),
                                                ),
                                              ),
                                              if (meeting.doctor?.specializations != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  meeting.doctor!.specializations.join(', '),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ColorPalette.primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: ColorPalette.primaryColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        '$formattedDate at $formattedTime',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: ColorPalette.primaryColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Share Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ColorPalette.primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.share_rounded,
                                            size: 20,
                                            color: ColorPalette.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}