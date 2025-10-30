import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const DocumentPreviewScreen({
    Key? key,
    required this.url,
    this.title,
  }) : super(key: key);

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  bool _isBusy = false;

  bool get _isPdf {
    try {
      final uri = Uri.parse(widget.url);
      final path = uri.path.toLowerCase();
      return path.endsWith('.pdf');
    } catch (_) {
      return widget.url.toLowerCase().contains('.pdf');
    }
  }

  bool get _isImage {
    const exts = ['.png', '.jpg', '.jpeg', '.webp', '.gif'];
    try {
      final uri = Uri.parse(widget.url);
      final path = uri.path.toLowerCase();
      return exts.any((ext) => path.endsWith(ext));
    } catch (_) {
      final urlLower = widget.url.toLowerCase();
      return exts.any((ext) => urlLower.contains(ext));
    }
  }

  String get _defaultTitle {
    try {
      final name = Uri.parse(widget.url).pathSegments.isNotEmpty
          ? Uri.parse(widget.url).pathSegments.last
          : widget.url.split('/').last;
      return name;
    } catch (_) {
      return 'Preview';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title ?? _defaultTitle),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _isBusy ? null : _shareFile,
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: _isBusy ? null : _downloadFile,
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.6),
                      Colors.purpleAccent.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildBody(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isBusy)
            Container(
              color: Colors.black.withOpacity(0.08),
              child: const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isPdf) {
      return SfPdfViewer.network(
        widget.url,
        canShowPaginationDialog: true,
        canShowScrollHead: true,
      );
    }
    if (_isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (_, __, ___) => _error(context),
          ),
        ),
      );
    }
    return _unsupported(context);
  }

  Future<void> _downloadFile() async {
    setState(() => _isBusy = true);
    try {
      final Dio dio = Dio();
      final dir = await getTemporaryDirectory();
      final filename = widget.title ?? _defaultTitle;
      final path = '${dir.path}/$filename';
      await dio.download(widget.url, path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded to $path'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              try {
                // Use share_plus preview/open via share sheet if no opener
                await Share.shareXFiles([XFile(path)], text: filename);
              } catch (_) {}
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _shareFile() async {
    setState(() => _isBusy = true);
    try {
      final Dio dio = Dio();
      final dir = await getTemporaryDirectory();
      final filename = widget.title ?? _defaultTitle;
      final path = '${dir.path}/$filename';
      await dio.download(widget.url, path);

      await Share.shareXFiles([XFile(path)], text: filename);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Widget _error(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
          const SizedBox(height: 12),
          const Text('Failed to load document'),
        ],
      ),
    );
  }

  Widget _unsupported(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Preview not supported for this file type'),
        ],
      ),
    );
  }
}


