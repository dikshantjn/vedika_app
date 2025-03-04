import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/ViewModel/SignupViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/Profile/presentation/viewmodel/UserProfileViewModel.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/ClinicSearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/HealthDaysViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/homePageViewModal/BannerViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/HospitalSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/CartService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/LabTestViewModel.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';
import 'package:vedika_healthcare/shared/widgets/SplashScreen.dart';

// ✅ Add Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handle background notification taps
void onBackgroundNotificationTap(NotificationResponse response) {
  print("[Background Notification Tap] Payload: ${response.payload}");
  AmbulanceRequestNotificationService.handleNotificationClick(response.payload);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ChangeNotifierProvider(create: (_) => BookClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => LabTestViewModel()),
        ChangeNotifierProvider(create: (_) => BloodBankOrderViewModel()),
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        ChangeNotifierProvider(create: (_) => HealthDaysViewModel()),

        // ✅ Add CartViewModel
        ChangeNotifierProvider(create: (_) => CartViewModel(CartService())),
        ChangeNotifierProvider(create: (_) => DeliveryPartnerViewModel()),

        ChangeNotifierProvider(create: (context) => EmergencyViewModel()),
        Provider(create: (context) => EmergencyService(context.read<LocationProvider>())),

        ChangeNotifierProvider(create: (context) => HospitalSearchViewModel()),
        ChangeNotifierProvider(create: (context) => LabSearchViewModel()),
        ChangeNotifierProvider(create: (context) => LabTestAppointmentViewModel()),

        ChangeNotifierProvider(create: (_) => ClinicSearchViewModel()),

        Provider(create: (context) => NotificationRepository()),
        ChangeNotifierProvider<NotificationViewModel>(
          create: (context) => NotificationViewModel(
            context.read<NotificationRepository>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HealthRecordViewModel()),

        ChangeNotifierProvider(create: (_) => SignupViewModel()),


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
          "/": (context) => SplashScreen(),
          ...AppRoutes.getRoutes(), // Include All App Routes
        },
      ),
    );
  }
}
