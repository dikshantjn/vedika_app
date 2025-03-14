import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';
import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/home/presentation/view/DiscountPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HealthDaysPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/OfferPage.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/HealthDaysViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/homePageViewModal/BannerViewModel.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({Key? key}) : super(key: key);

  Color _getTextColor(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color _getLearnMoreTextColor(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : const Color(0xFFFCD100);
  }

  void _navigateToPage(BuildContext context, BannerModal offer, HealthDaysViewModel healthDayViewModel) {
    Widget page;

    if (offer.type == "health_days" && offer.healthDay != null) {
      // Check if Banner ID matches any HealthDay ID
      HealthDay? matchingHealthDay = healthDayViewModel.healthDays.firstWhere(
            (day) => day.id == offer.id, // Matching based on banner ID
        orElse: () => offer.healthDay!, // Fallback to offer's existing healthDay
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

        return Column(
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index, realIndex) {
                    final offer = offers[index];
                    Color offerColor = Color(offer.color);

                    return GestureDetector(
                      onTap: () => _navigateToPage(context, offer, healthDayViewModel),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: offerColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Flexible( // Changed Expanded to Flexible
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    offer.title,
                                    style: TextStyle(
                                      color: _getTextColor(offerColor),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible( // Keeps the description flexible
                                    child: Text(
                                      offer.description,
                                      style: TextStyle(
                                        color: _getTextColor(offerColor),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Prevent overflow
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => _navigateToPage(context, offer, healthDayViewModel),
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                offer.image,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover, // Make sure image fits properly
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
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 1.0,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    aspectRatio: 16 / 9,
                    initialPage: 0,
                    onPageChanged: (index, reason) {
                      offerViewModel.updateIndex(index);
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      offers[offerViewModel.currentIndex].type == "offer"
                          ? "Offer"
                          : offers[offerViewModel.currentIndex].type == "health_days"
                          ? "Health Day"
                          : "Discount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: offers.asMap().entries.map((entry) {
                Color indicatorColor = Color(offers[entry.key].color);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: offerViewModel.currentIndex == entry.key
                        ? indicatorColor
                        : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
