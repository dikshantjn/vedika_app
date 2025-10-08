import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

enum AIIntent {
  doctorSearch,
  labSearch,
  productSearch,
  hospitalSearch,
  orderMedicinePrescription,
  ambulanceSearch,
  bloodBankSearch,
  generalHelp,
}

class AIChatResponse {
  final AIIntent intent;
  final List<String> searchTerms;
  final List<String> extractedSymptoms;
  final List<String> addressSearch;
  final String reply;
  final List<DoctorClinicProfile>? doctors;
  final List<DiagnosticCenter>? labs;
  final List<VendorProduct>? products;
  final List<HospitalProfile>? hospitals;

  AIChatResponse({
    required this.intent,
    required this.searchTerms,
    required this.extractedSymptoms,
    required this.addressSearch,
    required this.reply,
    this.doctors,
    this.labs,
    this.products,
    this.hospitals,
  });

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    // Parse intent
    AIIntent parseIntent(String intentStr) {
      switch (intentStr) {
        case 'doctor_search':
          return AIIntent.doctorSearch;
        case 'lab_search':
          return AIIntent.labSearch;
        case 'product_search':
          return AIIntent.productSearch;
        case 'hospital_search':
          return AIIntent.hospitalSearch;
        case 'ORDER_MEDICINE_PRESCRIPTION':
        case 'order_medicine_prescription':
          return AIIntent.orderMedicinePrescription;
        case 'AMBULANCE_SEARCH':
        case 'ambulance_search':
          return AIIntent.ambulanceSearch;
        case 'BLOODBANK_SEARCH':
        case 'bloodbank_search':
        case 'blood_bank_search':
          return AIIntent.bloodBankSearch;
        case 'general_help':
        default:
          return AIIntent.generalHelp;
      }
    }

    // Parse doctors list
    List<DoctorClinicProfile>? parseDoctors(List<dynamic>? doctorsList) {
      if (doctorsList == null) return null;
      return doctorsList
          .map((doctor) => DoctorClinicProfile.fromJson(doctor))
          .toList();
    }

    // Parse labs list
    List<DiagnosticCenter>? parseLabs(List<dynamic>? labsList) {
      if (labsList == null) return null;
      return labsList
          .map((lab) => DiagnosticCenter.fromJson(lab))
          .toList();
    }

    // Parse products list
    List<VendorProduct>? parseProducts(List<dynamic>? productsList) {
      if (productsList == null) return null;
      return productsList
          .map((product) => VendorProduct.fromJson(product))
          .toList();
    }

    // Parse hospitals list
    List<HospitalProfile>? parseHospitals(List<dynamic>? hospitalsList) {
      if (hospitalsList == null) return null;
      return hospitalsList
          .map((hospital) => HospitalProfile.fromJson(hospital))
          .toList();
    }

    return AIChatResponse(
      intent: parseIntent(json['intent'] ?? 'general_help'),
      searchTerms: List<String>.from(json['searchTerms'] ?? []),
      extractedSymptoms: List<String>.from(json['extractedSymptoms'] ?? []),
      addressSearch: List<String>.from(json['addressSearch'] ?? []),
      reply: json['reply'] ?? "I understand you're looking for information. Here are some relevant options:",
      doctors: parseDoctors(json['doctors']),
      labs: parseLabs(json['labs']),
      products: parseProducts(json['products']),
      hospitals: parseHospitals(json['hospitals']),
    );
  }

  Map<String, dynamic> toJson() {
    String intentToString(AIIntent intent) {
      switch (intent) {
        case AIIntent.doctorSearch:
          return 'doctor_search';
        case AIIntent.labSearch:
          return 'lab_search';
        case AIIntent.productSearch:
          return 'product_search';
        case AIIntent.hospitalSearch:
          return 'hospital_search';
        case AIIntent.orderMedicinePrescription:
          return 'order_medicine_prescription';
        case AIIntent.ambulanceSearch:
          return 'ambulance_search';
        case AIIntent.bloodBankSearch:
          return 'bloodbank_search';
        case AIIntent.generalHelp:
          return 'general_help';
      }
    }

    return {
      'intent': intentToString(intent),
      'searchTerms': searchTerms,
      'extractedSymptoms': extractedSymptoms,
      'addressSearch': addressSearch,
      'reply': reply,
      'doctors': doctors?.map((d) => d.toJson()).toList(),
      'labs': labs?.map((l) => l.toJson()).toList(),
      'products': products?.map((p) => p.toJson()).toList(),
      'hospitals': hospitals?.map((h) => h.toJson()).toList(),
    };
  }
} 