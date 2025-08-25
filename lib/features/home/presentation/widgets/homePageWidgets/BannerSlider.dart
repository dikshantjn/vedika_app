import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/BannerColorPalette.dart';
import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';
import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/home/presentation/view/DiscountPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HealthDaysPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/OfferPage.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/HealthDaysViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/homePageViewModal/BannerViewModel.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({Key? key}) : super(key: key);

  void _navigateToPage(BuildContext context, BannerModal offer, HealthDaysViewModel healthDayViewModel) {
    Widget page;

    if (offer.type == "health_days" && offer.healthDay != null) {
      HealthDay? matchingHealthDay = healthDayViewModel.healthDays.firstWhere(
        (day) => day.id == offer.id,
        orElse: () => offer.healthDay!,
      );
      page = HealthDayDetailPage(healthDay: matchingHealthDay, offer: offer);
    } else {
      switch (offer.type) {
        case "offer":
          page = OfferPage(offer: offer);
          break;
        case "discount":
          page = DiscountPage(offer: offer);
          break;
        default:
          return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BannerViewModel, HealthDaysViewModel>(
      builder: (context, offerViewModel, healthDayViewModel, child) {
        final offers = offerViewModel.offers;

        if (offers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: offers.length,
                itemBuilder: (context, index, realIndex) {
                  final offer = offers[index];
                  final gradientColors = BannerColorPalette.getGradientForType(offer.type);
                  final double cardHeight = 180.0;
                  final double imageWidth = (MediaQuery.of(context).size.width * 0.24).clamp(80.0, 120.0);

                  return GestureDetector(
                    onTap: () => _navigateToPage(context, offer, healthDayViewModel),
                    child: Container(
                      height: cardHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Geometric accents (no ellipses)
                          Positioned(
                            top: 14,
                            right: 18,
                            child: Transform.rotate(
                              angle: math.pi / 4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: gradientColors[1].withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 44,
                            right: 72,
                            child: Transform.rotate(
                              angle: math.pi / 12,
                              child: Container(
                                width: 46,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      gradientColors[0].withOpacity(0.10),
                                      gradientColors[2].withOpacity(0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 26,
                            right: 24,
                            child: Transform.rotate(
                              angle: -math.pi / 8,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: gradientColors[0].withOpacity(0.18),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // PNG at bottom-right (smaller size)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              width: imageWidth as double,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                offer.image,
                                height: cardHeight - 36,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Content (clean, organized)
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                (imageWidth as double) + 24,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: BannerColorPalette.badgeBackground,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      offer.type == "offer"
                                          ? "Special Offer"
                                          : offer.type == "health_days"
                                              ? "Health Day"
                                              : "Discount",
                                      style: TextStyle(
                                        color: BannerColorPalette.badgeText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    offer.title,
                                    style: TextStyle(
                                      color: BannerColorPalette.lightText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    offer.description,
                                    style: TextStyle(
                                      color: BannerColorPalette.lightText.withOpacity(0.9),
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: BannerColorPalette.buttonBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Learn More",
                                          style: TextStyle(
                                            color: BannerColorPalette.buttonText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.arrow_forward_rounded, size: 14, color: BannerColorPalette.buttonText),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  viewportFraction: 0.85,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    offerViewModel.updateIndex(index);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Custom Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: offers.asMap().entries.map((entry) {
                  final gradientColors = BannerColorPalette.getGradientForType(offers[entry.key].type);
                  return Container(
                    width: 28.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: offerViewModel.currentIndex == entry.key
                          ? gradientColors[0]
                          : Colors.grey.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
