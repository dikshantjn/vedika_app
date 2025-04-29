import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HealthConcernColorPalette.dart';
import 'dart:async';

class BrandSection extends StatefulWidget {
  @override
  State<BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<BrandSection> {
  final List<Map<String, String>> brands = [
    {"name": "Cipla", "logo": "assets/brands/Cipla Icon.png"},
    {"name": "Sun Pharma", "logo": "assets/brands/SunPharma Icon.png"},
    {"name": "Dr. Reddy's", "logo": "assets/brands/Dr. Reddys Icon.png"},
    {"name": "Lupin", "logo": "assets/brands/Lupin Icon.jpg"},
    {"name": "Zydus Cadila", "logo": "assets/brands/Zydus Cadila Icon.png"},
    {"name": "Aurobindo Pharma", "logo": "assets/brands/Aurobindo Icon.png"},
    {"name": "Biocon", "logo": "assets/brands/Biocon Icon.png"},
    {"name": "Torrent Pharma", "logo": "assets/brands/Torrent Pharma Icon.png"},
    {"name": "Alkem Labs", "logo": "assets/brands/Alkem Labs Icon.png"},
    {"name": "Glenmark", "logo": "assets/brands/Glenmark Icon.png"},
    {"name": "Wockhardt", "logo": "assets/brands/Wockhardt Icon.png"},
    {"name": "Natco Pharma", "logo": "assets/brands/Natco Icon.png"},
  ];

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isScrolling && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final nextScroll = currentScroll + 200.0;
        
        if (nextScroll >= maxScroll) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            nextScroll,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HealthConcernColorPalette.lightMint,
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.teal,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Trusted Brands",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          Container(
            height: 120,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _isScrolling = true;
                } else if (scrollNotification is ScrollEndNotification) {
                  _isScrolling = false;
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    margin: EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              brands[index]["logo"]!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          brands[index]["name"]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
