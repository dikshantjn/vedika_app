import 'dart:io';
import 'package:flutter/material.dart';

class FilePreviewGrid extends StatelessWidget {
  final List<Map<String, dynamic>> files;
  final Function(int) onRemove;

  const FilePreviewGrid({Key? key, required this.files, required this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85, // Ensures the grid cells don't get squished
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        File file = files[index]['file'];
        String fileName = files[index]['name'];

        bool isImage = file.path.toLowerCase().endsWith(".jpg") ||
            file.path.toLowerCase().endsWith(".png") ||
            file.path.toLowerCase().endsWith(".jpeg");

        return IntrinsicHeight( // Makes sure the Column fits within its allocated height
          child: Column(
            children: [
              Expanded( // Ensures image container takes the right amount of space
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isImage
                          ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 14,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
