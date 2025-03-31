import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  final String initialMessage;
  final Widget? initialContent;

  const LoadingDialog({Key? key, required this.initialMessage, this.initialContent}) : super(key: key);

  static void show(BuildContext context, String message, {Widget? content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(initialMessage: message, initialContent: content),
    );
  }

  static void update(BuildContext context, Widget newContent) {
    if (context.mounted) {
      Navigator.of(context).pop(); // Close existing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(initialMessage: '', initialContent: newContent),
      );
    }
  }

  static void hide(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.initialContent ?? Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(widget.initialMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
