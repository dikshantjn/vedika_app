import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/MedicalStoreVendorColorPalette.dart';

class FilePreviewGrid extends StatelessWidget {
  final List<Map<String, dynamic>> files; // Store file + name
  final Function(int) onRemove;

  const FilePreviewGrid({Key? key, required this.files, required this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView( // Wrap the entire GridView with SingleChildScrollView
      scrollDirection: Axis.vertical,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          File file = files[index]['file'];
          String fileName = files[index]['name'];

          bool isImage = file.path.toLowerCase().endsWith(".jpg") ||
              file.path.toLowerCase().endsWith(".png") ||
              file.path.toLowerCase().endsWith(".jpeg");

          return Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isImage
                        ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: 80)
                        : Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                fileName,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
