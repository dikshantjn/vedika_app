import 'package:flutter/material.dart';
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: offers.length,
                itemBuilder: (context, index, realIndex) {
                  final offer = offers[index];
                  final gradientColors = BannerColorPalette.getGradientForType(offer.type);

                  return GestureDetector(
                    onTap: () => _navigateToPage(context, offer, healthDayViewModel),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: gradientColors,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Image with Overlay
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    offer.image,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          gradientColors[0].withOpacity(0.8),
                                          gradientColors[1].withOpacity(0.6),
                                          gradientColors[2].withOpacity(0.4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BannerColorPalette.badgeBackground,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Title with fixed height
                                      SizedBox(
                                        height: 22,
                                        child: Text(
                                          offer.title,
                                          style: TextStyle(
                                            color: BannerColorPalette.lightText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Description with fixed height
                                      SizedBox(
                                        height: 36,
                                        child: Text(
                                          offer.description,
                                          style: TextStyle(
                                            color: BannerColorPalette.lightText,
                                            fontSize: 12,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Learn More Button
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BannerColorPalette.buttonBackground,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
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
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: BannerColorPalette.buttonText,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.35),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  viewportFraction: 0.95,
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
