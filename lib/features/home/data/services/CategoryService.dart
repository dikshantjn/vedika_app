import 'package:flutter/material.dart';

class CategoryService {
  // Mock data for categories
  static final List<Map<String, dynamic>> _categories = [
    {
      "name": "Dental Care",
      "icon": Icons.medical_services_outlined,
      "color": Color(0xFFE3F2FD),
      "subCategories": [
        "Toothpaste",
        "Toothbrushes",
        "Mouthwash",
        "Dental Floss",
        "Dental Kits"
      ]
    },
    {
      "name": "Genetic Testing",
      "icon": Icons.science_outlined,
      "color": Color(0xFFE8F5E9),
      "subCategories": [
        "DNA Testing",
        "Health Risk Assessment",
        "Ancestry Testing",
        "Carrier Status",
        "Wellness Reports"
      ]
    },
    {
      "name": "Heart Care",
      "icon": Icons.favorite_outline,
      "color": Color(0xFFFFEBEE),
      "subCategories": [
        "Heart Monitors",
        "Blood Pressure Devices",
        "ECG Monitors",
        "Heart Medications",
        "Heart Health Supplements"
      ]
    },
    {
      "name": "Baby Care",
      "icon": Icons.child_care_outlined,
      "color": Color(0xFFF3E5F5),
      "subCategories": [
        "Baby Food",
        "Diapers",
        "Baby Skincare",
        "Baby Healthcare",
        "Baby Accessories"
      ]
    },
    {
      "name": "Elder Care",
      "icon": Icons.elderly_outlined,
      "color": Color(0xFFFFF3E0),
      "subCategories": [
        "Mobility Aids",
        "Daily Living Aids",
        "Health Monitors",
        "Elderly Nutrition",
        "Comfort Products"
      ]
    },
    {
      "name": "Women Care",
      "icon": Icons.woman_outlined,
      "color": Color(0xFFFCE4EC),
      "subCategories": [
        "Feminine Hygiene",
        "Women's Health",
        "Pregnancy Care",
        "Menstrual Care",
        "Women's Supplements"
      ]
    },
    {
      "name": "Digital Health Tracker",
      "icon": Icons.watch_outlined,
      "color": Color(0xFFE0F7FA),
      "subCategories": [
        "Fitness Trackers",
        "Smart Watches",
        "Health Apps",
        "Activity Monitors",
        "Sleep Trackers"
      ]
    },
    {
      "name": "Digital Health Ring",
      "icon": Icons.ring_volume_outlined,
      "color": Color(0xFFE8F5E9),
      "subCategories": [
        "Smart Rings",
        "Health Monitoring",
        "Sleep Tracking",
        "Activity Tracking",
        "Vital Signs"
      ]
    },
    {
      "name": "Epilepsy Care",
      "icon": Icons.medical_information_outlined,
      "color": Color(0xFFE3F2FD),
      "subCategories": [
        "Seizure Monitors",
        "Medication Management",
        "Emergency Alerts",
        "Care Products",
        "Support Devices"
      ]
    },
    {
      "name": "UTI Test Kit",
      "icon": Icons.science_outlined,
      "color": Color(0xFFF3E5F5),
      "subCategories": [
        "Home Test Kits",
        "Urine Analysis",
        "Test Strips",
        "Digital Readers",
        "Testing Supplies"
      ]
    },
    {
      "name": "Wellness Care Kit",
      "icon": Icons.health_and_safety_outlined,
      "color": Color(0xFFFFF3E0),
      "subCategories": [
        "First Aid Kits",
        "Wellness Supplements",
        "Health Monitors",
        "Self-Care Products",
        "Emergency Kits"
      ]
    },
    {
      "name": "Pregnancy Care",
      "icon": Icons.pregnant_woman_outlined,
      "color": Color(0xFFFCE4EC),
      "subCategories": [
        "Prenatal Vitamins",
        "Pregnancy Tests",
        "Maternity Care",
        "Baby Planning",
        "Pregnancy Monitors"
      ]
    },
    {
      "name": "Wound Care",
      "icon": Icons.healing_outlined,
      "color": Color(0xFFE0F7FA),
      "subCategories": [
        "Bandages",
        "Antiseptics",
        "Wound Dressings",
        "First Aid",
        "Healing Products"
      ]
    },
    {
      "name": "Portable ECG",
      "icon": Icons.monitor_heart_outlined,
      "color": Color(0xFFE8F5E9),
      "subCategories": [
        "ECG Monitors",
        "Heart Rate Monitors",
        "Cardiac Devices",
        "Health Tracking",
        "Emergency Alerts"
      ]
    },
    {
      "name": "Period Care",
      "icon": Icons.calendar_today_outlined,
      "color": Color(0xFFF3E5F5),
      "subCategories": [
        "Sanitary Products",
        "Menstrual Cups",
        "Period Tracking",
        "Pain Relief",
        "Hygiene Products"
      ]
    }
  ];

  // Get all categories
  static List<Map<String, dynamic>> getAllCategories() {
    return _categories;
  }

  // Get category by index
  static Map<String, dynamic> getCategory(int index) {
    return _categories[index];
  }

  // Get subcategories for a category
  static List<String> getSubCategories(int categoryIndex) {
    return _categories[categoryIndex]['subCategories'];
  }
} 