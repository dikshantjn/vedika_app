import 'package:vedika_healthcare/features/labTest/data/models/LabTestModel.dart';

class LabModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String contact;
  final List<LabTestModel> tests; // Updated: List of test objects
  final double price;
  final double discount;
  final String operatingHours;
  final double rating;
  final bool homeCollection;
  final List<String> images;

  LabModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.contact,
    required this.tests, // Updated field
    required this.price,
    required this.discount,
    required this.operatingHours,
    required this.rating,
    required this.homeCollection,
    required this.images,
  });
}
