import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:vedika_healthcare/features/blog/data/services/BlogService.dart';
import 'package:vedika_healthcare/features/blog/presentation/view/BlogDetailPage.dart';
import 'package:flutter_html/flutter_html.dart';

class FeaturedArticlesSection extends StatefulWidget {
  const FeaturedArticlesSection({Key? key}) : super(key: key);

  @override
  State<FeaturedArticlesSection> createState() => _FeaturedArticlesSectionState();
}

class _FeaturedArticlesSectionState extends State<FeaturedArticlesSection>
    with SingleTickerProviderStateMixin {
  final BlogService _blogService = BlogService();
  List<BlogModel> _featuredBlogs = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadFeaturedBlogs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedBlogs() async {
    try {
      final blogs = await _blogService.fetchAllBlogs();
      setState(() {
        _featuredBlogs = blogs;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 280,
        margin: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8FFF9),
              const Color(0xFFE8F5E9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading articles...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_featuredBlogs.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8FFF9),
              const Color(0xFFE8F5E9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: ColorPalette.primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Featured Articles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'Discover our latest health insights',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/blogs');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: ColorPalette.primaryColor.withOpacity(0.1),
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: ColorPalette.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _featuredBlogs.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.1;
                      final animationValue = Curves.easeOut.transform(
                        (_animationController.value - delay).clamp(0.0, 1.0),
                      );
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - animationValue)),
                        child: Opacity(
                          opacity: animationValue,
                          child: _buildFeaturedArticleCard(_featuredBlogs[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedArticleCard(BlogModel blog) {
    // Extract the first header (h1, h2, h3) from the HTML message
    final headerRegExp = RegExp(r'<h[1-3][^>]*>(.*?)<\/h[1-3]>', caseSensitive: false);
    final match = headerRegExp.firstMatch(blog.message);
    final header = match != null ? match.group(1) ?? '' : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailPage(blog: blog),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      blog.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorPalette.primaryColor.withOpacity(0.1),
                                ColorPalette.primaryColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.article_outlined,
                              size: 48,
                              color: ColorPalette.primaryColor.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge (optional - you can add category field to BlogModel)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Health & Wellness',
                        style: TextStyle(
                          color: ColorPalette.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Flexible(
                      child: Html(
                        data: header.isNotEmpty ? header : 'Health Article',
                        style: {
                          "h1": Style(
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: LineHeight(1.3),
                          ),
                          "h2": Style(
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: LineHeight(1.3),
                          ),
                          "h3": Style(
                            fontSize: FontSize(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            lineHeight: LineHeight(1.3),
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Meta information
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '5 min read',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Read More button with modern style
                        Container(
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ColorPalette.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogDetailPage(blog: blog),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Read',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}