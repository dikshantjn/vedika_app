import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/ProfileCompletionService.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/CompleteProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/ProfileCompletionViewModel.dart';

class ProfileNavigationService {
  static Future<Widget> checkProfileCompletionAndNavigate({
    required Widget destination,
    required ServiceType serviceType,
    required BuildContext context,
  }) async {
    try {
      print('Starting profile completion check for ${serviceType.toString()}');
      
      // Get userId from secure storage
      final userId = await StorageService.getUserId();
      // Debug print removed
      
      if (userId == null || userId.isEmpty) {
        // Debug print removed
        return destination;
      }

      // Fast-path: use preloaded cache if available
      final profileVM = context.read<ProfileCompletionViewModel>();
      final cached = profileVM.isComplete(serviceType);
      bool isComplete;
      if (cached != null) {
        print('Using cached profile completion for $serviceType: $cached');
        isComplete = cached;
      } else {
        print('No cached result for $serviceType, calling service...');
        final profileService = ProfileCompletionService();
        isComplete = await profileService.isProfileComplete(userId, serviceType);
      }
      print('Profile completion status: $isComplete');

      if (isComplete) {
        print('Profile is complete, proceeding to destination');
        return destination;
      } else {
        print('Profile is incomplete, showing CompleteProfileScreen');
        return CompleteProfileScreen(
          serviceType: serviceType,
          userId: userId,
          onComplete: () {
            print('Profile completion finished, navigating to destination');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
        );
      }
    } catch (e, stackTrace) {
      print('Error in profile navigation check: $e');
      print('Stack trace: $stackTrace');
      return destination;
    }
  }
}

// Global navigator key for navigation from static context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 