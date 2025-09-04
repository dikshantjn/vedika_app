import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/LogoutPage.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/features/NewMedicineDelivery/presentation/view/MedicineDeliveryScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyMainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/VendorBloodBankMainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/doctor_dashboard_screen.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/HospitalDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/VendorMedicalStoreDashBoard.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/NewOrders/NewOrdersScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/VendorRegistrationPage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/DonorRegistrationPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/EnableBloodBankLocationServiceScreen.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicAppointmentPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicConsultationTypePage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/OnlineDoctorConsultationPage.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/BookAppointmentPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/BookLabTestAppointmentPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/LabSearchPage.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/CartScreen.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/Appointments/clinic_appointments_screen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/views/VendorProductPartnerDashBoardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/blog/presentation/view/BlogListPage.dart';
import 'package:vedika_healthcare/features/membership/presentation/view/MembershipPage.dart';
import 'package:vedika_healthcare/features/settings/presentation/view/SettingsPage.dart';
import 'package:vedika_healthcare/features/help/presentation/view/HelpCenterPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductListScreen.dart';
import 'package:vedika_healthcare/features/home/presentation/view/ProductDetailScreen.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/core/services/ProfileNavigationService.dart';
import 'package:vedika_healthcare/features/VedikaAI/presentation/view/AIChatScreen.dart';
import 'package:vedika_healthcare/features/cart/presentation/view/NewCartScreen.dart';

// Singleton navigation controller for better performance
class NavigationController {
  static final NavigationController _instance = NavigationController._internal();
  factory NavigationController() => _instance;
  NavigationController._internal();

  static NavigationController get instance => _instance;

  // Cache for vendor service to avoid repeated initialization
  VendorLoginService? _vendorLoginService;
  VendorLoginService get vendorLoginService {
    _vendorLoginService ??= VendorLoginService();
    return _vendorLoginService!;
  }

  // Navigation method that uses existing MainScreen if available
  void navigateToMainScreen(BuildContext context, {
    int? index,
    Widget? child,
    Map<String, dynamic>? arguments,
  }) {
    // Check if MainScreen already exists in the route stack
    final existingRoute = ModalRoute.of(context);
    if (existingRoute?.settings.name == '/home') {
      // Update existing MainScreen
      if (index != null && child != null) {
        MainScreenNavigator.instance.navigateToIndexWithChild(index, child);
      } else if (index != null) {
        MainScreenNavigator.instance.navigateToIndex(index);
      } else if (child != null) {
        MainScreenNavigator.instance.navigateToTransientChild(child);
      }
      return;
    }

    // Navigate to new MainScreen
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        if (index != null) 'initialIndex': index,
        if (child != null) 'transientChild': child,
        ...?arguments,
      },
    );
  }
}

class AppRoutes {
  // Route constants
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String vendorLogin = '/vendorLogin';
  static const String logout = '/logout';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notification = '/notification';
  static const String userProfile = '/userProfile';
  static const String healthRecords = '/healthRecords';
  static const String vedikaPlus = '/vedikaPlus';
  static const String membership = '/membership';
  static const String blogs = '/blogs';
  static const String settingsPage = '/settingsPage';
  static const String helpCenter = '/helpCenter';
  static const String productList = '/productList';
  static const String productDetail = '/productDetail';
  static const String ambulanceSearch = '/ambulance-search';
  static const String bloodBank = '/blood-bank';
  static const String medicineOrder = '/medicine-order';
  static const String hospitalSearch = '/hospital-search';
  static const String clinicSearch = '/clinic-search';
  static const String labSearch = '/lab-search';
  static const String labTest = '/labTest';
  static const String clinic = '/clinic';
  static const String onlineDoctorConsultation = '/onlineDoctorConsultation';
  static const String hospital = '/hospital';
  static const String bookAppointment = '/book-appointment';
  static const String bookClinicAppointment = '/book-clinic-appointment';
  static const String bookLabTestAppointment = '/book-lab-test-appointment';
  static const String clinicConsultationType = '/clinic/consultationType';
  static const String onlineDoctorDetail = '/clinic/onlineConsultation/doctor';
  static const String doctorAppointments = '/doctor/appointments';
  static const String donorRegistration = '/donor-registration';
  static const String trackOrder = '/track-order';
  static const String orderHistory = '/orderHistory';
  static const String enableBloodBankLocation = '/enableBloodBankLocation';
  static const String goToCart = '/goToCart';
  static const String vendor = '/vendor';
  static const String VendorMedicalStoreDashBoard = '/VendorMedicalStoreDashBoard';
  static const String MedicalStoreVendordashboard = '/MedicalStoreVendordashboard';
  static const String MedicalStoreVendorOrders = '/orders';
  static const String MedicalStoreVendorInventory = '/inventory';
  static const String MedicalStoreVendorReturns = '/returns';
  static const String MedicalStoreVendorSettings = '/settings';
  static const String trackOrderScreen = '/trackOrder';
  static const String VendorHospitalDashBoard = '/VendorHospitalDashBoard';
  static const String VendorClinicDashBoard = '/VendorClinicDashBoard';
  static const String AmbulanceAgencyDashboard = '/AmbulanceAgencyDashboard';
  static const String VendorBloodBankDashBoard = '/VendorBloodBankDashBoard';
  static const String VendorPathologyDashBoard = '/VendorPathologyDashBoard';
  static const String VendorDeliveryPartnerDashBoard = '/VendorDeliveryPartnerDashBoard';
  static const String VendorProductPartnerDashBoard = '/VendorProductPartnerDashBoard';
  static const String bloodBankBooking = '/bloodBankBooking';
  static const String aiChat = '/aiChat';
  static const String newMedicineOrderScreen = '/newMedicineOrderScreen';
  static const String newCartScreen = '/newCartScreen';

  // medical store vendor
  static const String newOrderScreen = '/newOrderScreen';

  // Optimized route mapping with lazy initialization
  static Map<String, WidgetBuilder> getRoutes() {
    final nav = NavigationController.instance;

    return {

      // medical store vendor
      newOrderScreen: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final initialTab = args?['initialTab'] as int?;
        return NewOrdersScreen(initialTab: initialTab);
      },
      newCartScreen: (context) => const NewCartScreen(),

      // Primary routes
      home: (context) => const MainScreen(),
      login: (context) => UserLoginScreen(),
      vendorLogin: (context) => VendorRegistrationPage(),
      logout: (context) => LogoutPage(),

      // Vendor routes (direct navigation - no MainScreen wrapper needed)
      vendor: (context) => VendorRegistrationPage(),
      VendorMedicalStoreDashBoard: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] as int?;
        return VendorMedicalStoreDashBoardScreen(initialIndex: initialIndex);
      },
      VendorHospitalDashBoard: (context) => HospitalDashboardScreen(),
      VendorClinicDashBoard: (context) => DoctorDashboardScreen(),
      AmbulanceAgencyDashboard: (context) => AmbulanceAgencyMainScreen(),
      VendorBloodBankDashBoard: (context) => VendorBloodBankMainScreen(),
      VendorPathologyDashBoard: (context) => LabTestDashboardScreen(),
      bloodBankBooking: (context) => BloodBankBookingScreen(),

      // Optimized vendor product partner with cached service
      VendorProductPartnerDashBoard: (context) => FutureBuilder<String?>(
        future: nav.vendorLoginService.getVendorId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Scaffold(
              body: Center(
                child: Text('No vendor ID found. Please login again.'),
              ),
            );
          }

          return VendorProductPartnerDashBoardScreen(vendorId: snapshot.data!);
        },
      ),

      // Direct navigation routes (non-MainScreen)
      donorRegistration: (context) => DonorRegistrationPage(),
      enableBloodBankLocation: (context) => EnableBloodBankLocationServiceScreen(),
      doctorAppointments: (context) => ClinicAppointmentsScreen(),
      membership: (context) => const MembershipPage(),

      // MainScreen-integrated routes (optimized)
      aiChat: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return _MainScreenRoute(
          child: AIChatScreen(
            initialQuery: args?['initialQuery'] ?? '',
          ),
          index: 9,
        );
      },
      bloodBank: (context) => _MainScreenRoute(
        child: BloodBankMapScreen(),
        index: 9,
      ),
      ambulanceSearch: (context) => _MainScreenRoute(
        child: AmbulanceSearchPage(),
        index: 9,
      ),
      medicineOrder: (context) => _MainScreenRoute(
        child: MedicineOrderScreen(),
        index: 9,
      ),
      newMedicineOrderScreen: (context) => _MainScreenRoute(
        child: MedicineDeliveryScreen(),
        index: 9,
      ),
      hospital: (context) => _MainScreenRoute(
        child: HospitalSearchPage(),
        index: 9,
      ),
      clinicConsultationType: (context) => _MainScreenRoute(
        child: ClinicConsultationTypePage(),
        index: 9,
      ),
      labTest: (context) => _MainScreenRoute(
        child: LabSearchPage(),
        index: 9,
      ),
      clinic: (context) => _MainScreenRoute(
        child: ClinicSearchPage(),
        index: 9,
      ),
      clinicSearch: (context) => _MainScreenRoute(
        child: ClinicSearchPage(),
        index: 9,
      ),
      onlineDoctorConsultation: (context) => _MainScreenRoute(
        child: OnlineDoctorConsultationPage(),
        index: 9,
      ),
      goToCart: (context) => _MainScreenRoute(
        child: CartScreen(),
        index: 9,
      ),
      blogs: (context) => _MainScreenRoute(
        child: BlogListPage(),
        index: 9,
      ),
      settingsPage: (context) => _MainScreenRoute(
        child: SettingsPage(),
        index: 9,
      ),
      helpCenter: (context) => _MainScreenRoute(
        child: HelpCenterPage(),
        index: 9,
      ),

      // MainScreen index routes
      orderHistory: (context) => _MainScreenRoute(index: 1),
      notification: (context) => _MainScreenRoute(index: 2),
      healthRecords: (context) => _MainScreenRoute(index: 3),
      trackOrderScreen: (context) => _MainScreenRoute(index: 4),
      userProfile: (context) => _MainScreenRoute(index: 6),

      // Parametrized routes
      productList: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return _MainScreenRoute(
          child: ProductListScreen(
            category: args?['category'] ?? 'medicine',
            subCategory: args?['subCategory'],
          ),
          index: 9,
        );
      },
      productDetail: (context) {
        final product = ModalRoute.of(context)?.settings.arguments as VendorProduct;
        return _MainScreenRoute(
          child: ProductDetailScreen(product: product),
          index: 9,
        );
      },
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final nav = NavigationController.instance;

    switch (settings.name) {
      case bookAppointment:
        final hospital = settings.arguments as HospitalProfile;
        return MaterialPageRoute(
          builder: (context) => _MainScreenRoute(
            child: BookAppointmentPage(hospital: hospital),
            index: 9,
          ),
        );

      case bookClinicAppointment:
        final clinic = settings.arguments as DoctorClinicProfile;
        return MaterialPageRoute(
          builder: (context) => _MainScreenRoute(
            child: ClinicAppointmentPage(doctor: clinic, isOnline: false),
            index: 9,
          ),
        );

      case bookLabTestAppointment:
        final center = settings.arguments as DiagnosticCenter;
        return MaterialPageRoute(
          builder: (context) => _MainScreenRoute(
            child: BookLabTestAppointmentPage(center: center),
            index: 9,
          ),
        );

      case onlineDoctorDetail:
        final doctor = settings.arguments as DoctorClinicProfile;
        return MaterialPageRoute(
          builder: (context) => _MainScreenRoute(
            child: ClinicAppointmentPage(doctor: doctor, isOnline: true),
            index: 9,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page Not Found')),
          ),
        );
    }
  }
}

// Optimized widget for MainScreen routes
class _MainScreenRoute extends StatelessWidget {
  final Widget? child;
  final int? index;
  final bool isFromNotification; // New parameter to prevent auto-pop during notification navigation

  const _MainScreenRoute({
    this.child,
    this.index,
    this.isFromNotification = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    // Use post-frame callback for navigation to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MainScreenNavigator.instance.isMainScreenCreated) {
        // Update existing MainScreen
        if (child != null && index != null) {
          MainScreenNavigator.instance.navigateToIndexWithChild(index!, child!);
        } else if (index != null) {
          MainScreenNavigator.instance.navigateToIndex(index!);
        } else if (child != null) {
          MainScreenNavigator.instance.navigateToTransientChild(child!);
        }
        // Only pop if not from notification navigation
        if (!isFromNotification) {
          Navigator.pop(context);
        }
      } else {
        // Create new MainScreen
        Navigator.pushReplacementNamed(context, '/home', arguments: {
          if (index != null) 'initialIndex': index,
          if (child != null) 'transientChild': child,
          'isFromNotification': isFromNotification, // Pass the flag
        });
      }
    });

    return const SizedBox.shrink();
  }
}