import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileOpenHelper {
  static void openFile(BuildContext context, String fileUrl) async {
    final Uri uri = Uri.parse(fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open file")),
      );
    }
  }
}
