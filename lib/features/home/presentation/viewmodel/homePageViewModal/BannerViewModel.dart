import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/models/BannerModal.dart';
import 'package:vedika_healthcare/features/home/data/repositories/BannerRepository.dart';

class BannerViewModel extends ChangeNotifier {
  final BannerRepository _offerRepository = BannerRepository();
  List<BannerModal> _offers = [];
  int _currentIndex = 0;

  // ✅ Fix: Constructor name matches the class name
  BannerViewModel() {
    _fetchOffers();
  }

  void _fetchOffers() {
    _offers = _offerRepository.fetchOffers();
    print("Fetched Offers: ${_offers.length}"); // Debugging log
    notifyListeners();
  }

  List<BannerModal> get offers => _offers;
  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
