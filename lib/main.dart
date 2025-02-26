import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/home/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';

// ✅ Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handle background notification taps
void onBackgroundNotificationTap(NotificationResponse response) {
  print("[Background Notification Tap] Payload: ${response.payload}");
  AmbulanceRequestNotificationService.handleNotificationClick(response.payload);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved location
  final locationProvider = LocationProvider();
  await locationProvider.loadSavedLocation();

  // Set Transparent Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent Status Bar
    statusBarIconBrightness: Brightness.dark, // Dark Icons for Light Background
  ));

  // Initialize Emergency Service
  final EmergencyService emergencyService = EmergencyService(locationProvider);
  emergencyService.initialize();

  // ✅ Initialize Notification Service (so notifications work properly)
  await AmbulanceRequestNotificationService.initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locationProvider),
        ChangeNotifierProvider(create: (_) => BookAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => BookClinicAppointmentViewModel()), // Correct ViewModel
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BloodBankViewModel(context), // Initialize BloodBankViewModel here
      child: MaterialApp(
        title: 'Vedika Healthcare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey, // ✅ Set navigator key
        initialRoute: "/",
        onGenerateRoute: AppRoutes.generateRoute, // Handles dynamic routes like BookAppointmentPage
        routes: {
          "/": (context) => const HomePage(),
          ...AppRoutes.getRoutes(), // Include All App Routes
        },
      ),
    );
  }
}