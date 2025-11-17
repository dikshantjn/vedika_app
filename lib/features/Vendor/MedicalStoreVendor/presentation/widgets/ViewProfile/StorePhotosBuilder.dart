import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vedika_healthcare/shared/utils/firebase_metadata_service.dart';

class StorePhotosBuilder {
  final FirebaseMetadataService _metadataService = FirebaseMetadataService();

  /// Builds the profile photo using only the **first URL** from the list
  Future<Widget> buildProfilePhoto(String encodedUrls) async {
    try {
      // Check if the string is empty or null
      if (encodedUrls.isEmpty || encodedUrls.trim().isEmpty) {
        return _buildPlaceholderIcon();
      }

      List<String> urls = [];
      
      // Check if it's a JSON array
      if (encodedUrls.trim().startsWith('[')) {
        try {
          urls = List<String>.from(jsonDecode(encodedUrls));
        } catch (e) {
          // Not valid JSON, treat as single URL string if it's a valid URL
          if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
            urls = [encodedUrls];
          } else {
            return _buildPlaceholderIcon();
          }
        }
      } else {
        // Not a JSON array, check if it's a valid URL
        if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
          urls = [encodedUrls];
        } else {
          // Not a valid URL, show placeholder
          return _buildPlaceholderIcon();
        }
      }

      if (urls.isEmpty) return _buildPlaceholderIcon(); // No images available

      String firstImageUrl = urls.first;

      try {
        FullMetadata metadata = await _metadataService.getFileMetadata(firstImageUrl);
        String description = metadata.customMetadata?["description"] ?? "Store Image";
        return _buildPhotoBox(firstImageUrl, description, size: 80);
      } catch (e) {
        // If metadata fetch fails, still try to show the image
        return _buildPhotoBox(firstImageUrl, "Store Image", size: 80);
      }
    } catch (e) {
      debugPrint("❌ Error fetching profile photo: $e");
      return _buildPlaceholderIcon();
    }
  }

  /// Builds the store photos grid from all URLs
  List<Widget> buildStorePhotos(String encodedUrls) {
    try {
      // Check if the string is empty or null
      if (encodedUrls.isEmpty || encodedUrls.trim().isEmpty) {
        return [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No photos found",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ];
      }

      List<String> urls = [];
      
      // Check if it's a JSON array
      if (encodedUrls.trim().startsWith('[')) {
        try {
          urls = List<String>.from(jsonDecode(encodedUrls));
        } catch (e) {
          // Not valid JSON, treat as single URL string if it's a valid URL
          if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
            urls = [encodedUrls];
          } else {
            return [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No photos found",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ];
          }
        }
      } else {
        // Not a JSON array, check if it's a valid URL
        if (encodedUrls.startsWith('http://') || encodedUrls.startsWith('https://')) {
          urls = [encodedUrls];
        } else {
          // Not a valid URL, show no photos message
          return [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No photos found",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ];
        }
      }

      if (urls.isEmpty) {
        return [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No photos found",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ];
      }

      // Return a list containing the GridView widget
      return [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: urls.length,
          itemBuilder: (context, index) {
            String url = urls[index];
            return FutureBuilder<FullMetadata>(
              future: _metadataService.getFileMetadata(url),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return _buildPhotoBox(url, "Unknown Image");
                }

                FullMetadata metadata = snapshot.data!;
                String description = metadata.customMetadata?["description"] ?? "Store Image";

                return _buildPhotoBox(url, description);
              },
            );
          },
        ),
      ];
    } catch (e) {
      debugPrint("❌ Error decoding store photo URLs: $e");
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "No photos found",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ];
    }
  }



  /// Builds a single photo box with label
  Widget _buildPhotoBox(String imageUrl, String label, {double size = 100}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: size,
              width: size,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  /// Placeholder for missing images
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.storefront, size: 40, color: Colors.white),
    );
  }
}
