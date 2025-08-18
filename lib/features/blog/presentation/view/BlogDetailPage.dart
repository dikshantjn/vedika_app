import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/blog/presentation/viewmodel/BlogViewModel.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class BlogDetailPage extends StatefulWidget {
  final BlogModel blog;
  const BlogDetailPage({Key? key, required this.blog}) : super(key: key);

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // TTS and highlighting
  final FlutterTts _flutterTts = FlutterTts();
  final ItemScrollController _itemScrollController = ItemScrollController();
  List<String> _paragraphs = [];
  int _currentParagraph = 0;
  bool _isPlaying = false;
  double _progress = 0.0;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Split HTML into paragraphs (strip tags for TTS, keep HTML for display)
    _paragraphs = widget.blog.message.split(RegExp(r'</p>|<br ?/?>', caseSensitive: false))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
    _flutterTts.setCompletionHandler(_onTtsComplete);
  }

  Future<void> _startTts() async {
    setState(() {
      _isPlaying = true;
      _currentParagraph = 0;
      _progress = 0.0;
    });
    await _speakCurrentParagraph();
  }

  Future<void> _speakCurrentParagraph() async {
    if (_currentParagraph < _paragraphs.length) {
      final plainText = _paragraphs[_currentParagraph].replaceAll(RegExp(r'<[^>]*>'), '');
      await _flutterTts.speak(plainText);
      _itemScrollController.scrollTo(index: _currentParagraph, duration: Duration(milliseconds: 400));
      setState(() {
        _progress = (_currentParagraph + 1) / _paragraphs.length;
      });
    } else {
      setState(() {
        _isPlaying = false;
        _progress = 1.0;
      });
    }
  }

  void _onTtsComplete() {
    if (_isPlaying && _currentParagraph < _paragraphs.length - 1) {
      setState(() {
        _currentParagraph++;
        _progress = (_currentParagraph + 1) / _paragraphs.length;
      });
      _speakCurrentParagraph();
    } else {
      setState(() {
        _isPlaying = false;
        _progress = 1.0;
      });
    }
  }

  Future<void> _pauseTts() async {
    await _flutterTts.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _currentParagraph = 0;
      _progress = 0.0;
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate reading time (assuming 200 words per minute)
    final plainText = widget.blog.message.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    final wordCount = plainText.split(RegExp(r'\s+')).length;
    final readingTime = (wordCount / 200).ceil();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Health Blogs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              final url = 'http://localhost:3000/health-blogs/${widget.blog.blogPostId}';
              await Share.share(url);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image with responsive 16:9 ratio for phones/tablets
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/Blogs/dummyBlogImage.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Article Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.blog.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Article Meta Information
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.blog.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Icon(
                          Icons.timer_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$readingTime min read',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.shade300,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Audio controls and progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade200,
                    color: ColorPalette.primaryColor,
                    minHeight: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 36, color: ColorPalette.primaryColor),
                        onPressed: () {
                          if (_isPlaying) {
                            _pauseTts();
                          } else {
                            _startTts();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle, size: 32, color: Colors.redAccent),
                        onPressed: _stopTts,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isPlaying ? 'Reading...' : 'Tap play to listen',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main HTML content (no highlighting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Html(
                data: widget.blog.message,
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.7),
                    color: Colors.black87,
                    margin: Margins.only(bottom: 8),
                    padding: HtmlPaddings.zero,
                  ),
                  "h1": Style(
                    fontSize: FontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    margin: Margins.only(top: 24, bottom: 16),
                  ),
                  "h2": Style(
                    fontSize: FontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    margin: Margins.only(top: 20, bottom: 12),
                  ),
                  "h3": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    margin: Margins.only(top: 18, bottom: 10),
                  ),
                  "p": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.7),
                    color: Colors.black87,
                    margin: Margins.only(bottom: 8),
                  ),
                  "a": Style(
                    color: ColorPalette.primaryColor,
                    textDecoration: TextDecoration.underline,
                  ),
                  "blockquote": Style(
                    border: Border(
                      left: BorderSide(
                        color: ColorPalette.primaryColor,
                        width: 4,
                      ),
                    ),
                    margin: Margins.only(left: 0, top: 16, bottom: 16),
                    padding: HtmlPaddings.only(left: 16),
                    backgroundColor: Colors.grey.shade50,
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 16),
                  ),
                  "ol": Style(
                    margin: Margins.only(bottom: 16),
                  ),
                  "li": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.7),
                    margin: Margins.only(bottom: 8),
                  ),
                },
              ),
            ),
            // Bottom spacing
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}