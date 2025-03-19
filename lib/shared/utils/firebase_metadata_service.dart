import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseMetadataService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Fetch metadata from Firebase Storage for a given file URL
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      String storagePath = _getStoragePathFromUrl(fileUrl);
      Reference ref = _storage.ref(storagePath);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint("❌ Error fetching metadata: $e");
      rethrow;
    }
  }

  /// Extracts Firebase Storage path from a given URL
  String _getStoragePathFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String fullPath = Uri.decodeComponent(uri.pathSegments.last);
    return fullPath.split("?").first; // Remove query parameters
  }
}
