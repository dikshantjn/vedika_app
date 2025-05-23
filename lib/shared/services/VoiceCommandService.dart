import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/LabSearchPage.dart';
import 'package:vedika_healthcare/features/home/data/services/CategoryService.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductListScreen.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/view/EmergencyDialog.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'dart:developer' as developer;

class VoiceCommandService {
  static void handleVoiceCommand(BuildContext context, String command, [Function(String)? onError]) {
    final normalizedCommand = command.toLowerCase().trim();
    developer.log('Processing voice command: $normalizedCommand');

    // Emergency dialog commands
    if (normalizedCommand.contains('emergency') || 
        normalizedCommand.contains('emergency help') ||
        normalizedCommand.contains('emergency assistance') ||
        normalizedCommand.contains('emergency services')) {
      _showEmergencyDialog(context);
      return;
    }

    // Direct emergency calls
    if (normalizedCommand.contains('call doctor') || 
        normalizedCommand.contains('doctor emergency') ||
        normalizedCommand.contains('emergency doctor')) {
      _triggerDoctorEmergency(context);
      return;
    }

    if (normalizedCommand.contains('call ambulance') || 
        normalizedCommand.contains('ambulance emergency') ||
        normalizedCommand.contains('emergency ambulance')) {
      _triggerAmbulanceEmergency(context);
      return;
    }

    if (normalizedCommand.contains('call blood bank') || 
        normalizedCommand.contains('blood bank emergency') ||
        normalizedCommand.contains('emergency blood bank')) {
      _triggerBloodBankEmergency(context);
      return;
    }

    // Back navigation commands
    if (normalizedCommand.contains('go back') || 
        normalizedCommand.contains('back') ||
        normalizedCommand.contains('previous') ||
        normalizedCommand.contains('return') ||
        normalizedCommand.contains('close overlay') ||
        normalizedCommand.contains('exit overlay')) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      } else {
        if (onError != null) {
          onError('Cannot go back further.');
        }
        return;
      }
    }

    // Check for product category commands first
    final categoryMatch = _findMatchingCategory(normalizedCommand);
    if (categoryMatch != null) {
      _navigateToProductList(context, categoryMatch['name'] as String);
      return;
    }

    // Ambulance related commands
    if (normalizedCommand.contains('ambulance') || 
        normalizedCommand.contains('book ambulance') ||
        normalizedCommand.contains('call ambulance')) {
      _navigateToRoute(context, AppRoutes.ambulanceSearch);
      return;
    }

    // Blood Bank related commands
    if (normalizedCommand.contains('blood bank') || 
        normalizedCommand.contains('find blood') ||
        normalizedCommand.contains('donate blood')) {
      _navigateToRoute(context, AppRoutes.bloodBank);
      return;
    }

    // Medicine Delivery related commands
    if (normalizedCommand.contains('medicine') || 
        normalizedCommand.contains('order medicine') ||
        normalizedCommand.contains('deliver medicine')) {
      _navigateToRoute(context, AppRoutes.medicineOrder);
      return;
    }

    // Hospital related commands
    if (normalizedCommand.contains('hospital') || 
        normalizedCommand.contains('find hospital') ||
        normalizedCommand.contains('book hospital')) {
      _navigateToRoute(context, AppRoutes.hospital);
      return;
    }

    // Clinic/Doctor related commands
    if (normalizedCommand.contains('doctor') || 
        normalizedCommand.contains('clinic') ||
        normalizedCommand.contains('book appointment') ||
        normalizedCommand.contains('doctor appointment')) {
      _navigateToRoute(context, AppRoutes.clinic);
      return;
    }

    // Lab Test related commands
    if (normalizedCommand.contains('lab') || 
        normalizedCommand.contains('test') ||
        normalizedCommand.contains('book test') ||
        normalizedCommand.contains('lab test')) {
      _navigateToRoute(context, AppRoutes.labTest);
      return;
    }

    // If no command matches, show error message
    if (onError != null) {
      onError('Sorry, I couldn\'t understand that command. Try saying something like "emergency", "call doctor", or "show dental care".');
    }
  }

  static void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmergencyDialog(
          ambulanceNumber: "9370320066",
          bloodBankNumber: "9370320066",
          doctorNumber: "9370320066",
        );
      },
    );
  }

  static void _triggerDoctorEmergency(BuildContext context) {
    final emergencyService = EmergencyService(context.read<LocationProvider>());
    emergencyService.triggerDoctorEmergency("9370320066");
  }

  static void _triggerAmbulanceEmergency(BuildContext context) {
    final emergencyService = EmergencyService(context.read<LocationProvider>());
    emergencyService.triggerAmbulanceEmergency("9370320066");
  }

  static void _triggerBloodBankEmergency(BuildContext context) {
    final emergencyService = EmergencyService(context.read<LocationProvider>());
    emergencyService.triggerBloodBankEmergency("9370320066");
  }

  static Map<String, dynamic>? _findMatchingCategory(String command) {
    final categories = CategoryService.getAllCategories();
    
    // First try exact matches
    for (var category in categories) {
      final categoryName = (category['name'] as String).toLowerCase();
      if (command.contains(categoryName)) {
        return category;
      }
    }

    // Then try partial matches
    for (var category in categories) {
      final categoryName = (category['name'] as String).toLowerCase();
      final words = categoryName.split(' ');
      
      // Check if all words in the category name are present in the command
      bool allWordsMatch = words.every((word) => command.contains(word));
      if (allWordsMatch) {
        return category;
      }
    }

    return null;
  }

  static void _navigateToProductList(BuildContext context, String category) {
    if (!context.mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          category: category,
        ),
      ),
    );
  }

  static void _navigateToRoute(BuildContext context, String routeName) {
    if (!context.mounted) return;
    
    Navigator.pushNamed(context, routeName);
  }
} 