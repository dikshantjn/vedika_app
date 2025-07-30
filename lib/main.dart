import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/userLoginViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';
import 'package:vedika_healthcare/features/EmergencyService/data/services/EmergencyService.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/viewModal/TrackOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceAgencyViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingHistoryViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/FeeViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodAvailabilityViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankAgencyProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankBookingViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/BloodBankRequestViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/VendorBloodBankDashBoardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/viewModel/VendorBloodBankMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/ClinicAppointmentHistoryViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/ClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/AppointmentViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/ProcessAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/BookingsViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/viewModels/DiagnosticCenterProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicalStoreVendorUpdateProfileViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineOrderViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MedicineProductViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/viewmodels/product_partner_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorLoginViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/ViewModels/VendorRegistrationViewModel.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/viewmodel/AmbulanceSearchViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/OnlineDoctorConsultationViewModel.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductCartService.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/CategoryViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ProductViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/userCartService.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BedBookingOrderViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/LabTestOrderViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserMedicalProfileViewModel.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/viewmodel/UserPersonalProfileViewModel.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/viewmodel/BloodBankViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/BookClinicAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/clinic/presentation/viewmodel/ClinicSearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/HealthDaysViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/homePageViewModal/BannerViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/BookAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/hospital/presentation/viewModal/HospitalSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabSearchViewModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/viewmodel/LabTestAppointmentViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/CartAndPlaceOrderViewModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/viewmodel/DeliveryPartner/DeliveryPartnerViewModel.dart';
import 'package:vedika_healthcare/features/notifications/data/repositories/NotificationRepository.dart';
import 'package:vedika_healthcare/features/notifications/presentation/viewmodel/NotificationViewModel.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/utils/AppLifecycleObserver.dart';
import 'package:vedika_healthcare/shared/widgets/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vedika_healthcare/features/notifications/data/models/AppNotification.dart';
import 'package:vedika_healthcare/features/notifications/data/adapters/AppNotificationAdapter.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/SearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ScannerViewModel.dart';
import 'package:vedika_healthcare/features/ai/presentation/viewmodel/AIViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/WardViewModel.dart';
import 'package:vedika_healthcare/core/services/ProfileNavigationService.dart';
import 'package:vedika_healthcare/features/blog/presentation/viewmodel/BlogViewModel.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Device Preview Configuration
const bool enableDevicePreview = true; // Set to false to disable device preview

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
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(AppNotificationAdapter());
  
  // Open boxes
  await Hive.openBox<AppNotification>('notifications');
  
  await Firebase.initializeApp();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());

  // Initialize FCM Service
  final fcmService = FCMService();
  final notificationRepository = NotificationRepository();
  await notificationRepository.init();
  final notificationViewModel = NotificationViewModel(notificationRepository);

  // Handle initial notification (app opened from terminated state)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final notification = AppNotification.fromPayload({
      'notification': {
        'title': initialMessage.notification?.title ?? '',
        'body': initialMessage.notification?.body ?? '',
      },
      'data': initialMessage.data,
    });
    await notificationViewModel.addNotification(notification);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fcmService.handleNotificationTap(
          jsonEncode(initialMessage.data),
          navigatorKey.currentContext!
      );
    });
  }

  // Set up FCM message handlers
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');
    
    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');
      
      // Create notification object
      final notification = AppNotification.fromPayload({
        'notification': {
          'title': message.notification!.title,
          'body': message.notification!.body,
        },
        'data': message.data,
      });
      
      // Save notification
      await notificationViewModel.addNotification(notification);
    }
  });

  // Request permissions and setup token
  await fcmService.requestNotificationPermission();
  String? userId = await StorageService.getUserId();
  String? vendorId = await VendorLoginService().getVendorId();
  if (userId != null) await fcmService.getTokenAndSend(userId);
  else if (vendorId != null) await fcmService.getVendorTokenAndSend(vendorId);

  runApp(
    enableDevicePreview && !kReleaseMode
        ? DevicePreview(
            enabled: true,
            builder: (context) => MyApp(), // Wrap your app
          )
        : MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => BookAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => BookClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => BloodBankOrderViewModel()),
        ChangeNotifierProvider(create: (_) => BannerViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => HealthDaysViewModel()),
        ChangeNotifierProvider(create: (_) => CartAndPlaceOrderViewModel(
          UserCartService(),
          ProductCartService(Dio()),
        )),
        ChangeNotifierProvider(create: (_) => DeliveryPartnerViewModel()),
        ChangeNotifierProvider(create: (_) => EmergencyViewModel()),
        ChangeNotifierProvider(create: (_) => HospitalSearchViewModel()),
        ChangeNotifierProvider(create: (_) => LabSearchViewModel()),
        ChangeNotifierProvider(create: (_) => LabTestAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => ClinicSearchViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()),
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
        ChangeNotifierProvider(create: (_) => AmbulanceMainViewModel()),
        ChangeNotifierProvider(create: (_) => AgencyDashboardViewModel()),
        ChangeNotifierProvider(create: (context) => FeeViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceBookingRequestViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceBookingHistoryViewModel()),
        ChangeNotifierProvider(create: (context) => AmbulanceSearchViewModel(context)),
        ChangeNotifierProvider(create: (context) => VendorBloodBankDashBoardViewModel()),
        ChangeNotifierProvider(create: (context) => BloodBankRequestViewModel()),

        ChangeNotifierProvider(create: (context) => BloodBankBookingViewModel()),
        ChangeNotifierProvider(create: (context) => BloodAvailabilityViewModel()),
        ChangeNotifierProvider(create: (context) => BloodBankAgencyProfileViewModel()),
        ChangeNotifierProvider(create: (context) => VendorBloodBankMainViewModel()),
        ChangeNotifierProvider(create: (context) => HospitalRegistrationViewModel()),

        ChangeNotifierProvider(create: (context) => HospitalDashboardViewModel()),
        ChangeNotifierProvider(create: (context) => AppointmentViewModel()),

        ChangeNotifierProvider(create: (context) => HospitalProfileViewModel()),
        ChangeNotifierProvider(create: (context) => ProcessAppointmentViewModel()),

        ChangeNotifierProvider(create: (context) => BedBookingOrderViewModel()),
        ChangeNotifierProvider(create: (context) => DoctorClinicRegistrationViewModel()),
        ChangeNotifierProvider(create: (context) => DoctorClinicProfileViewModel()),
        ChangeNotifierProvider(create: (context) => ClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (context) => ClinicAppointmentHistoryViewModel()),
        ChangeNotifierProvider(create: (context) => OnlineDoctorConsultationViewModel()),
        ChangeNotifierProvider(create: (context) => DiagnosticCenterProfileViewModel()),
        ChangeNotifierProvider(create: (context) => BookingsViewModel()),
        ChangeNotifierProvider(create: (context) => LabTestOrderViewModel()),

        ChangeNotifierProvider(create: (context) => ProductPartnerViewModel()),
        ChangeNotifierProvider(create: (_) => AIViewModel()),
        ChangeNotifierProvider(create: (_) => WardViewModel()),
        ChangeNotifierProvider(create: (context) => BlogViewModel()),

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
            useInheritedMediaQuery: enableDevicePreview && !kReleaseMode, // Conditional for device preview
            locale: enableDevicePreview && !kReleaseMode ? DevicePreview.locale(context) : null, // Conditional for device preview
            builder: enableDevicePreview && !kReleaseMode ? DevicePreview.appBuilder : null, // Conditional for device preview
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
