import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/AuthViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/UserViewModel.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/core/init/AppInitializer.dart';
import 'package:vedika_healthcare/core/viewmodel/SplashViewModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';
import 'package:vedika_healthcare/features/EmergencyService/presentation/viewmodel/EmergencyViewModel.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/viewmodel/HealthRecordViewModel.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/viewmodel/MedicineDeliveryViewModel.dart';
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
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/NewOrders/NewOrdersViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/viewmodels/product_partner_viewmodel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/ViewModal/medical_store_registration_viewmodel.dart';
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
import 'package:vedika_healthcare/features/orderHistory/presentation/viewmodel/BloodBankOrderViewModel.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';
import 'package:vedika_healthcare/shared/widgets/GlobalConnectivityBanner.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceMainViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AgencyDashboardViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/SearchViewModel.dart';
import 'package:vedika_healthcare/features/home/presentation/viewmodel/ScannerViewModel.dart';
import 'package:vedika_healthcare/features/VedikaAI/presentation/viewmodel/AIViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/WardViewModel.dart';
import 'package:vedika_healthcare/core/services/ProfileNavigationService.dart';
import 'package:vedika_healthcare/features/blog/presentation/viewmodel/BlogViewModel.dart';
import 'package:vedika_healthcare/features/membership/presentation/viewmodel/MembershipViewModel.dart';
import 'package:vedika_healthcare/core/auth/presentation/viewmodel/ProfileCompletionViewModel.dart';
import 'package:vedika_healthcare/features/cart/presentation/viewmodel/CartViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/ViewModels/DoctorClinicTimeslotViewModel.dart';
import 'package:vedika_healthcare/core/viewmodel/CoreNotificationViewModel.dart';

// Device Preview Configuration
const bool enableDevicePreview = false; // Set to false to disable device preview

void onBackgroundNotificationTap(dynamic response) {}

void main() async {
  await AppInitializer.initCore();

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
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
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
        ChangeNotifierProvider(create: (_) => BookClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => ClinicAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => CoreNotificationViewModel()),
        ChangeNotifierProvider(create: (_) => UserPersonalProfileViewModel()),
        ChangeNotifierProvider(create: (_) => UserMedicalProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HealthRecordViewModel()),
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
        // EmergencyService is now initialized as a singleton in SplashScreen
        // No need for Provider here

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
        ChangeNotifierProvider(create: (context) => ClinicAppointmentHistoryViewModel()),
        ChangeNotifierProvider(create: (context) => OnlineDoctorConsultationViewModel()),
        ChangeNotifierProvider(create: (context) => DiagnosticCenterProfileViewModel()),
        ChangeNotifierProvider(create: (context) => BookingsViewModel()),
        ChangeNotifierProvider(create: (context) => LabTestOrderViewModel()),

        ChangeNotifierProvider(create: (context) => ProductPartnerViewModel()),
        ChangeNotifierProvider(create: (_) => AIViewModel()),
        ChangeNotifierProvider(create: (_) => WardViewModel()),
        ChangeNotifierProvider(create: (context) => BlogViewModel()),
        ChangeNotifierProvider(create: (_) => MembershipViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileCompletionViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineDeliveryViewModel()),
        ChangeNotifierProvider(create: (_) => NewOrdersViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => DoctorClinicTimeslotViewModel()),

      ],
      child: Builder(
        builder: (context) {
          // Call loadSavedLocation (EmergencyService is now initialized in SplashScreen)
          final locationProvider = context.read<LocationProvider>();

          locationProvider.loadSavedLocation();

          return MaterialApp(
            showPerformanceOverlay: false,
            title: 'Vedika Healthtech',
            debugShowCheckedModeBanner: false,
            useInheritedMediaQuery: enableDevicePreview && !kReleaseMode, // Conditional for device preview
            locale: enableDevicePreview && !kReleaseMode ? DevicePreview.locale(context) : null, // Conditional for device preview
            builder: (context, child) {
              final Widget appChild = enableDevicePreview && !kReleaseMode
                  ? DevicePreview.appBuilder(context, child)
                  : (child ?? const SizedBox.shrink());
              // Inject a global connectivity banner that can show on top of any screen.
              return GlobalConnectivityBanner(child: appChild);
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            navigatorKey: navigatorKey,
            scaffoldMessengerKey:scaffoldMessengerKey,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
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
