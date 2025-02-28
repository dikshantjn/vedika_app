import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/DeliveryPartner/DeliveryPartnerService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'dart:math';

class DeliveryPartnerViewModel extends ChangeNotifier {
  List<DeliveryPartner> _partners = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DeliveryPartner> get partners => _partners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchNearbyPartners(BuildContext context) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _partners = DeliveryPartnerService().getNearbyDeliveryPartners(context);
      print("_partners : ${_partners.first.name}");
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radius of the Earth in km
    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in km
  }

  double calculateDeliveryCharges(BuildContext context, DeliveryPartner partner) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return 0.0; // Return 0 if the location isn't available
    }

    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);
    LatLng partnerLocation = LatLng(partner.latitude, partner.longitude);

    double distance = calculateDistance(userLocation, partnerLocation);
    double charges = distance * partner.chargesPerKm;
    print("charge : $charges");

    return charges;
  }
}
