import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HealthRecordItem extends StatelessWidget {
  final HealthRecord record;

  HealthRecordItem(this.record);

  void _openFile(BuildContext context, String filePath) async {
    debugPrint("Attempting to open file: $filePath");

    File file = File(filePath);
    if (!file.existsSync()) {
      debugPrint("File does not exist: $filePath");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File not found: ${record.name}")),
      );
      return;
    }

    try {
      final result = await OpenFile.open(filePath);
      debugPrint("OpenFilex Result: ${result.type}, Message: ${result.message}");

      if (result.type == ResultType.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open ${record.name}")),
        );
      }
    } catch (e) {
      debugPrint("Error opening file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening file: $e")),
      );
    }
  }

  void _showBottomSheet(BuildContext context, HealthRecordViewModel healthRecordVM) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // File Preview
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildFilePreview(),
                ),
              ),
              SizedBox(height: 18),

              // File Details
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent, size: 34),
                title: Text(
                  record.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: ${record.type}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      Text("Uploaded: ${_formatDate(record.uploadedAt)}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1.2, color: Colors.grey[300]),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: Icons.download_rounded,
                    label: "Download",
                    color: Colors.green,
                    onTap: () {
                      healthRecordVM.downloadRecord(record);
                      Navigator.pop(context);
                    },
                  ),
                  _actionButton(
                    icon: Icons.delete_rounded,
                    label: "Delete",
                    color: Colors.redAccent,
                    onTap: () => _deleteRecord(context, healthRecordVM),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }



  Widget _buildFilePreview() {
    if (record.fileUrl.endsWith(".pdf")) {
      return SfPdfViewer.file(File(record.fileUrl), canShowScrollStatus: false, canShowPaginationDialog: false);
    } else if (record.fileUrl.endsWith(".jpg") ||
        record.fileUrl.endsWith(".jpeg") ||
        record.fileUrl.endsWith(".png")) {
      return Image.file(
        File(record.fileUrl),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.error, color: Colors.red, size: 40)),
      );
    }
    return Center(child: Icon(Icons.insert_drive_file, size: 60, color: Colors.blueAccent));
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced size
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white), // Smaller icon
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13, // Smaller font size
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  void _deleteRecord(BuildContext context, HealthRecordViewModel healthRecordVM) {
    healthRecordVM.deleteRecord(record.id);

    Navigator.pop(context); // Close the bottom sheet if open

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${record.name}' deleted successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final healthRecordVM = Provider.of<HealthRecordViewModel>(context, listen: false);

    return GestureDetector(
      onTap: () => _openFile(context, record.fileUrl),
      onLongPress: () => _showBottomSheet(context, healthRecordVM),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            Expanded(
              child: IgnorePointer(
                ignoring: true,
                child: _buildFilePreview(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                record.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}