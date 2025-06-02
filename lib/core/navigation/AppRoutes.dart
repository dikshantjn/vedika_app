import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/LogoutPage.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordsPage.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/view/TrackOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceAgencyMainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankRequestScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/ProcessBloodBankBookingScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/VendorBloodBankDashBoardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/VendorBloodBankMainScreen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/doctor_dashboard_screen.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/HospitalDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/LabTestDashboardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/VendorMedicalStoreDashBoard.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/VendorRegistrationPage.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/view/UserProfilePage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/DonorRegistrationPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/EnableBloodBankLocationServiceScreen.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/BookClinicAppointmentPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicConsultationTypePage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/OnlineDoctorConsultationPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/OnlineDoctorDetailPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/BookAppointmentPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/BookLabTestAppointmentPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/LabSearchPage.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/CartScreen.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';
import 'package:vedika_healthcare/features/notifications/presentation/view/NotificationPage.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/Appointments/clinic_appointments_screen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/views/VendorProductPartnerDashBoardScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String vendorLogin = '/vendorLogin';
  static const String logout = '/logout';

  // Main Routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notification = '/notification';
  static const String userProfile = '/userProfile';
  static const String healthRecords = '/healthRecords';
  static const String vedikaPlus = '/vedikaPlus';

  // Service Routes
  static const String ambulanceSearch = '/ambulance-search';
  static const String bloodBank = '/blood-bank';
  static const String medicineOrder = '/medicine-order';
  static const String hospitalSearch = '/hospital-search';
  static const String clinicSearch = '/clinic-search';
  static const String labSearch = '/lab-search';
  static const String labTest = '/labTest';
  static const String clinic = '/clinic';
  static const String hospital = '/hospital';

  // Booking Routes
  static const String bookAppointment = '/book-appointment';
  static const String bookClinicAppointment = '/book-clinic-appointment';
  static const String bookLabTestAppointment = '/book-lab-test-appointment';
  static const String clinicConsultationType = '/clinic/consultationType';
  static const String onlineDoctorConsultation = '/clinic/onlineConsultation';
  static const String onlineDoctorDetail = '/clinic/onlineConsultation/doctor';
  static const String doctorAppointments = '/doctor/appointments';

  // Other Routes
  static const String donorRegistration = '/donor-registration';
  static const String trackOrder = '/track-order';
  static const String orderHistory = '/orderHistory';
  static const String enableBloodBankLocation = '/enableBloodBankLocation';
  static const String goToCart = '/goToCart';

  // Vendor Routes
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

  static Map<String, WidgetBuilder> getRoutes() {
    final vendorLoginService = VendorLoginService();
    
    return {
      home: (context) => HomePage(),
      bloodBank: (context) => BloodBankMapScreen(),
      ambulanceSearch: (context) => AmbulanceSearchPage(),
      clinic: (context) => ClinicSearchPage(),
      hospital: (context) => HospitalSearchPage(),
      donorRegistration: (context) => DonorRegistrationPage(),
      orderHistory: (context) => OrderHistoryPage(), // Added route for EnableLocationPage
      enableBloodBankLocation: (context) => EnableBloodBankLocationServiceScreen(), // Added route for EnableLocationPage
      doctorAppointments: (context) => ClinicAppointmentsScreen(), // Route for doctor appointments
      clinicConsultationType: (context) => ClinicConsultationTypePage(),
      onlineDoctorConsultation: (context) => OnlineDoctorConsultationPage(),
      hospitalSearch: (context) => HospitalSearchPage(),
      clinicSearch: (context) => ClinicSearchPage(),

      medicineOrder: (context) => MedicineOrderScreen(), // Added route for EnableLocationPage
      goToCart: (context) => CartScreen(), // Added route for EnableLocationPage

      labTest: (context) => LabSearchPage(), // Added route for EnableLocationPage
      notification: (context) => NotificationPage(), // Added route for EnableLocationPage
      userProfile: (context) => UserProfilePage(), // Added route for EnableLocationPage
      healthRecords: (context) => HealthRecordsPage(), // Added route for EnableLocationPage
      login: (context) => UserLoginScreen(), // Added route for EnableLocationPage
      vendorLogin: (context) => VendorRegistrationPage(), // Added route for EnableLocationPage

      logout: (context) => LogoutPage(), // Added route for EnableLocationPage

      bloodBankBooking: (context) => BloodBankBookingScreen(), // Added route for EnableLocationPage

      //vendor
      vendor: (context) => VendorRegistrationPage(), // Added route for EnableLocationPage
      VendorMedicalStoreDashBoard: (context) => VendorMedicalStoreDashBoardScreen(), // Added route for EnableLocationPage
      trackOrderScreen: (context) => TrackOrderScreen(), // Added route for EnableLocationPage

      // // Vendor Dashboards
      VendorHospitalDashBoard: (context) => HospitalDashboardScreen(),
      VendorClinicDashBoard: (context) => DoctorDashboardScreen(),
      AmbulanceAgencyDashboard: (context) => AmbulanceAgencyMainScreen(),
      VendorBloodBankDashBoard: (context) => VendorBloodBankMainScreen(),
      VendorPathologyDashBoard: (context) => LabTestDashboardScreen(),
      VendorProductPartnerDashBoard: (context) => FutureBuilder<String?>(
        future: vendorLoginService.getVendorId(),
        builder: (context, snapshot) {
          print('VendorProductPartnerDashBoard - Connection State: ${snapshot.connectionState}');
          print('VendorProductPartnerDashBoard - Has Data: ${snapshot.hasData}');
          print('VendorProductPartnerDashBoard - Data: ${snapshot.data}');
          print('VendorProductPartnerDashBoard - Error: ${snapshot.error}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error loading vendor ID: ${snapshot.error}'),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('No vendor ID found. Please login again.'),
              ),
            );
          }
          
          return VendorProductPartnerDashBoardScreen(
            vendorId: snapshot.data!,
          );
        },
      ),
      // VendorDeliveryPartnerDashBoard: (context) => VendorDeliveryPartnerDashBoardScreen(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookAppointment:
        final hospital = settings.arguments as HospitalProfile;
        return MaterialPageRoute(
          builder: (context) => BookAppointmentPage(hospital: hospital),
        );

      case bookClinicAppointment:
        final clinic = settings.arguments as DoctorClinicProfile;
        return MaterialPageRoute(
          builder: (context) => BookClinicAppointmentPage(doctor: clinic),
        );

      case bookLabTestAppointment:
        final center = settings.arguments as DiagnosticCenter;  // Extracting DiagnosticCenter argument
        return MaterialPageRoute(
          builder: (context) => BookLabTestAppointmentPage(center: center),
        );

      case onlineDoctorDetail:
        final doctor = settings.arguments as DoctorClinicProfile ;
        return MaterialPageRoute(
          builder: (context) => OnlineDoctorDetailPage(doctor: doctor),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }
}
