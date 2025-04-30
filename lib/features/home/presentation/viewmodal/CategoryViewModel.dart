import 'package:flutter/material.dart';

class CategoryViewModel extends ChangeNotifier {
  // List of product partner categories
  final List<Map<String, dynamic>> categories = [
    {
      "name": "Medicines",
      "icon": "assets/category/Medicine Icon.png",
      "color": Color(0xFFE3F2FD),
      "subCategories": [
        "Prescription Medicines",
        "Over-the-Counter",
        "Generic Medicines",
        "Ayurvedic Medicines",
        "Homeopathic Medicines"
      ]
    },
    {
      "name": "Medical Devices",
      "icon": "assets/category/Medical Devices Icon.png",
      "color": Color(0xFFE8F5E9),
      "subCategories": [
        "Diagnostic Devices",
        "Surgical Instruments",
        "Mobility Aids",
        "First Aid Kits",
        "Medical Monitors"
      ]
    },
    {
      "name": "Health Supplements",
      "icon": "assets/category/Supplements Icon.png",
      "color": Color(0xFFFFF3E0),
      "subCategories": [
        "Vitamins",
        "Protein Supplements",
        "Herbal Supplements",
        "Sports Nutrition",
        "Weight Management"
      ]
    },
    {
      "name": "Personal Care",
      "icon": "assets/category/Personal Care Icon.png",
      "color": Color(0xFFF3E5F5),
      "subCategories": [
        "Skin Care",
        "Hair Care",
        "Oral Care",
        "Baby Care",
        "Feminine Hygiene"
      ]
    },
    {
      "name": "Fitness & Wellness",
      "icon": "assets/category/Fitness Icon.png",
      "color": Color(0xFFFCE4EC),
      "subCategories": [
        "Fitness Equipment",
        "Yoga Accessories",
        "Massage Tools",
        "Health Monitors",
        "Wellness Products"
      ]
    },
    {
      "name": "Medical Equipment",
      "icon": "assets/category/Medical Equipment Icon.png",
      "color": Color(0xFFE0F7FA),
      "subCategories": [
        "Hospital Equipment",
        "Diagnostic Tools",
        "Patient Care",
        "Emergency Care",
        "Rehabilitation"
      ]
    },
    {
      "name": "Surgical Supplies",
      "icon": "assets/category/Surgical Supplies Icon.png",
      "color": Color(0xFFE8F5E9),
      "subCategories": [
        "Surgical Instruments",
        "Disposables",
        "Wound Care",
        "Sterilization",
        "Surgical Dressings"
      ]
    },
    {
      "name": "Laboratory Equipment",
      "icon": "assets/category/Lab Equipment Icon.png",
      "color": Color(0xFFE3F2FD),
      "subCategories": [
        "Lab Instruments",
        "Testing Kits",
        "Lab Consumables",
        "Analytical Equipment",
        "Lab Safety"
      ]
    }
  ];

  // Get category by index
  Map<String, dynamic> getCategory(int index) {
    return categories[index];
  }

  // Get all categories
  List<Map<String, dynamic>> getAllCategories() {
    return categories;
  }

  // Get subcategories for a category
  List<String> getSubCategories(int categoryIndex) {
    return categories[categoryIndex]['subCategories'];
  }
} 