import 'package:flutter/material.dart';

class DeleteFileDialog extends StatefulWidget {
  final String fileName;
  final VoidCallback onConfirm;

  const DeleteFileDialog({
    super.key,
    required this.fileName,
    required this.onConfirm,
  });

  @override
  _DeleteFileDialogState createState() => _DeleteFileDialogState();
}

class _DeleteFileDialogState extends State<DeleteFileDialog> {
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Text(
            "Delete File",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Text(
        "Are you sure you want to delete \"${widget.fileName}\"?",
        style: const TextStyle(fontSize: 16),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.cancel, color: Colors.grey),
          label: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          icon: isLoading
              ? const CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          )
              : const Icon(Icons.delete_forever, color: Colors.white),
          label: isLoading
              ? const SizedBox.shrink() // Remove label when loading
              : const Text("Delete"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: isLoading
              ? null
              : () async {
            setState(() => isLoading = true);
            widget.onConfirm(); // Execute the confirm action
            await Future.delayed(const Duration(seconds: 2)); // Simulate the delete action
            setState(() => isLoading = false);
            Navigator.pop(context); // Close the dialog
          },
        ),
      ],
    );
  }
}
