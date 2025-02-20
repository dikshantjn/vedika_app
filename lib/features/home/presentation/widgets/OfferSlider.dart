import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OfferSlider extends StatefulWidget {
  @override
  _OfferSliderState createState() => _OfferSliderState();
}

class _OfferSliderState extends State<OfferSlider> {
  final List<Map<String, String>> offers = [
    {
      "title": "20% off on Medicines!",
      "description": "Use code MED20 for 20% off.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFF0D89C7", // #0d89c7
      "type": "discount",
    },
    {
      "title": "Buy 1 Get 1 Free on Lab Tests!",
      "description": "Get one test free on purchase.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFF0E76B5", // #0e76b5
      "type": "offer",
    },
    {
      "title": "Blood Bank Donation!",
      "description": "Donate blood, save lives.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFFFCD100", // #fcd100
      "type": "offer",
    },
    {
      "title": "Flat 15% off on Orders!",
      "description": "Get 15% off on all orders.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFFF1E398", // #f1e398
      "type": "discount",
    },
    {
      "title": "10% off on Health Checkups!",
      "description": "Book a checkup and save 10%.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFF874292", // #874292
      "type": "discount",
    },
    {
      "title": "Free Delivery on Orders!",
      "description": "Free delivery for all orders.",
      "image": "assets/offers/offer.png",  // Updated path
      "color": "0xFF6A5D7B", // #6a5d7b
      "type": "offer",
    },
  ];


  int _currentIndex = 0;

  Color _getTextColor(Color bgColor) {
    double luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Color _getLearnMoreTextColor(Color bgColor) {
    double luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Color(0xFFFCD100);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add the dynamic "Offer" or "Discount" tag at the top right
          Stack(
            children: [
              CarouselSlider.builder(
                itemCount: offers.length,
                itemBuilder: (context, index, realIndex) {
                  Color offerColor = Color(int.parse(offers[index]["color"]!));

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: offerColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Section: Title, Description, and Learn More
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                offers[index]["title"]!,
                                style: TextStyle(
                                  color: _getTextColor(offerColor),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                offers[index]["description"]!,
                                style: TextStyle(
                                  color: _getTextColor(offerColor),
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Learn More",
                                  style: TextStyle(
                                    color: _getLearnMoreTextColor(offerColor),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right Section: Image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            offers[index]["image"]!,
                            height: 120,
                            width: 120,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  viewportFraction: 1.0,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              // Positioned dynamic tag: "Offer" or "Discount"
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    offers[_currentIndex]["type"] == "offer"
                        ? "Offer"
                        : "Discount", // Show "Offer" or "Discount"
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: offers.asMap().entries.map((entry) {
              Color indicatorColor = Color(int.parse(offers[entry.key]["color"]!));
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? indicatorColor
                      : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
