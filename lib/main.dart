import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/userLoginViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/AI/presentation/viewmodel/MicViewModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingHistoryViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/FeeViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineProductViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/ViewModal/hospital_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/userCartService.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/ClinicSearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/HealthDaysViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodal/homePageViewModal/BannerViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/HospitalSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/LabTestViewModel.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/utils/AppLifecycleObserver.dart';
import 'package:vedika_healthcare/shared/widgets/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:network_info_plus/network_info_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void onBackgroundNotificationTap(NotificationResponse response) {
  print("[Background Notification Tap] Payload: ${response.payload}");
}

Future<void> getWifiIpAddress() async {
  final info = NetworkInfo();
  String? ip = await info.getWifiIP();
  print("Connected Wi-Fi IP Address: $ip");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver()); // Add lifecycle observer

  // Initialize FCM Service
  final fcmService = FCMService();

  // Handle initial notification (app opened from terminated state)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fcmService.handleNotificationTap(
          jsonEncode(initialMessage.data),
          navigatorKey.currentContext!
      );
    });
  }

  // Request permissions and setup token
  await fcmService.requestNotificationPermission();
  String? userId = await StorageService.getUserId();
  String? vendorId = await VendorLoginService().getVendorId();
  if (userId != null) await fcmService.getTokenAndSend(userId);
  else if (vendorId != null) await fcmService.getVendorTokenAndSend(vendorId);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BookAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => BookClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => LabTestViewModel()),
        ChangeNotifierProvider(create: (_) => BloodBankOrderViewModel()),
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        ChangeNotifierProvider(create: (_) => HealthDaysViewModel()),
        ChangeNotifierProvider(create: (_) => CartAndPlaceOrderViewModel(UserCartService())),
        ChangeNotifierProvider(create: (_) => DeliveryPartnerViewModel()),
        ChangeNotifierProvider(create: (_) => EmergencyViewModel()),
        ChangeNotifierProvider(create: (_) => HospitalSearchViewModel()),
        ChangeNotifierProvider(create: (_) => LabSearchViewModel()),
        ChangeNotifierProvider(create: (_) => LabTestAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => ClinicSearchViewModel()),
        Provider(create: (_) => NotificationRepository()),
        ChangeNotifierProvider(
          create: (context) => NotificationViewModel(
            context.read<NotificationRepository>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => UserPersonalProfileViewModel()),
        ChangeNotifierProvider(create: (_) => UserMedicalProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HealthRecordViewModel()),
        ChangeNotifierProvider(create: (_) => UserLoginViewModel(navigatorKey: navigatorKey)),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => MicViewModel()),
        ChangeNotifierProvider(create: (_) => HospitalRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => VendorRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalStoreRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => VendorLoginViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalStoreVendorDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalStoreVendorProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MedicalStoreVendorUpdateProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineProductViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineOrderViewModel()),
        ChangeNotifierProvider(create: (context) => BloodBankViewModel(context)),
        ProxyProvider<LocationProvider, EmergencyService>(
          update: (context, locationProvider, _) => EmergencyService(locationProvider),
        ),

        ChangeNotifierProvider(create: (_) => AddNewAddressViewModel()),
        ChangeNotifierProvider(create: (_) => TrackOrderViewModel()),

        ChangeNotifierProvider(create: (_) => AmbulanceAgencyViewModel()),

        ChangeNotifierProvider(create: (context) => FeeViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceBookingRequestViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceBookingHistoryViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceMainViewModel()),



      ],
      child: Builder(
        builder: (context) {
          // Call loadSavedLocation and initialize EmergencyService
          final locationProvider = context.read<LocationProvider>();
          final emergencyService = context.read<EmergencyService>();

          locationProvider.loadSavedLocation();
          emergencyService.initialize();

          return MaterialApp(
            title: 'Vedika Healthcare',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            navigatorKey: navigatorKey,
            scaffoldMessengerKey:scaffoldMessengerKey,
            initialRoute: "/",
            onGenerateRoute: AppRoutes.generateRoute,
            routes: {
              "/": (context) => SplashScreen(),
              ...AppRoutes.getRoutes(),
            },
          );
        },
      ),
    );
  }
}
