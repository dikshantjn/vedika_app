import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/blog/data/models/BlogModel.dart';
import 'package:vedika_healthcare/features/blog/presentation/view/BlogDetailPage.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;

  const BlogCard({
    Key? key,
    required this.blog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract title from HTML content
    final titleRegExp = RegExp(r'<h[1-6][^>]*>(.*?)<\/h[1-6]>', caseSensitive: false);
    final match = titleRegExp.firstMatch(blog.message);
    final title = match != null ?
    match.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? 'Blog Post' :
    'Blog Post';

    // Extract plain text from HTML for excerpt
    final plainText = blog.message.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    final excerpt = plainText.length > 120 ?
    plainText.substring(0, 120) + '...' :
    plainText;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlogDetailPage(blog: blog),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with overlay gradient
                if (blog.imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.article_outlined,
                                        size: 48,
                                        color: ColorPalette.primaryColor.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Blog Article',
                                        style: TextStyle(
                                          color: ColorPalette.primaryColor.withOpacity(0.6),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Subtle gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Excerpt
                      if (excerpt.isNotEmpty && excerpt != title)
                        Text(
                          excerpt,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 16),

                      // Action buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Read article button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorPalette.primaryColor,
                                  ColorPalette.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorPalette.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlogDetailPage(blog: blog),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Read Article',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // External link button (if available)
                          // if (blog.link.isNotEmpty)
                            // Container(
                            //   decoration: BoxDecoration(
                            //     border: Border.all(
                            //       color: ColorPalette.primaryColor.withOpacity(0.3),
                            //       width: 1.5,
                            //     ),
                            //     borderRadius: BorderRadius.circular(25),
                            //   ),
                            //   child: Material(
                            //     color: Colors.transparent,
                            //     child: InkWell(
                            //       onTap: () async {
                            //         final uri = Uri.parse(blog.link);
                            //         if (await canLaunchUrl(uri)) {
                            //           await launchUrl(uri, mode: LaunchMode.externalApplication);
                            //         }
                            //       },
                            //       borderRadius: BorderRadius.circular(25),
                            //       child: Padding(
                            //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            //         child: Row(
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: [
                            //             Icon(
                            //               Icons.open_in_new_rounded,
                            //               color: ColorPalette.primaryColor,
                            //               size: 16,
                            //             ),
                            //             const SizedBox(width: 6),
                            //             Text(
                            //               'Source',
                            //               style: TextStyle(
                            //                 color: ColorPalette.primaryColor,
                            //                 fontWeight: FontWeight.w600,
                            //                 fontSize: 14,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}