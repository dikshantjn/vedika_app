import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vedika_healthcare/features/hospital/data/modal/Hospital.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class HospitalData {

  static List<Map<String, dynamic>> getHospitals(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return []; // Return an empty list if the location isn't available yet
    }

    // User's current location
    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

    // Sample hospitals with adjusted locations based on user location
    return [
      Hospital(
        id: "H1",
        name: "Rao Nursing Home",
        address: "Survey No. 691A, B, CTS No. 1897, 1A-1, Pune - Satara Rd, Bibwewadi, Pune, Maharashtra 411037",
        contact: "091300 06009",
        email: "contact@raonursinghome.com",
        website: "https://raonursinghome.com",
        specialties: ["Multi-Speciality"],
        doctors: [
          Doctor(name: "Dr. A. Rao", specialization: "General Practitioner", timeSlots: ["9:00 AM", "12:00 PM", "3:00 PM"], fee: 500),
        ],
        beds: 100,
        services: ["General Services", "Emergency Care", "ICU"],
        visitingHours: "Open 24 hours",
        ratings: 4.0,
        insuranceProviders: ["Provider A", "Provider B"],
        labs: ["Lab A", "Lab B"],
        lat: userLocation.latitude + 0.002,
        lng: userLocation.longitude + 0.002,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H2",
        name: "Ranka Hospital",
        address: "157 / 5, SS Dhage Rd, near Swargate, Mukund Nagar, Pune, Maharashtra 411037",
        contact: "020 2426 1600",
        email: "contact@rankahospital.com",
        website: "https://rankahospital.com",
        specialties: ["Multi-Speciality"],
        doctors: [
          Doctor(name: "Dr. R. Ranka", specialization: "General Surgeon", timeSlots: ["10:00 AM", "1:00 PM", "4:00 PM"], fee: 600),
        ],
        beds: 120,
        services: ["Surgery", "Emergency", "Outpatient Services"],
        visitingHours: "Open 24 hours",
        ratings: 4.3,
        insuranceProviders: ["Provider C", "Provider D"],
        labs: ["Lab C", "Lab D"],
        lat: userLocation.latitude + 0.003,
        lng: userLocation.longitude - 0.001,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H3",
        name: "City Care Hospital",
        address: "Kothrud, Pune, Maharashtra 411038",
        contact: "020 2520 4444",
        email: "contact@citycarehospital.com",
        website: "https://citycarehospital.com",
        specialties: ["Cardiology", "Orthopaedics", "Neurology"],
        doctors: [
          Doctor(name: "Dr. N. Yadav", specialization: "Cardiologist", timeSlots: ["9:00 AM", "11:00 AM", "2:00 PM"], fee: 700),
        ],
        beds: 80,
        services: ["Emergency Services", "Outpatient Care", "Dialysis"],
        visitingHours: "9:00 AM - 7:00 PM",
        ratings: 4.2,
        insuranceProviders: ["Provider E", "Provider F"],
        labs: ["Lab E", "Lab F"],
        lat: userLocation.latitude + 0.004,
        lng: userLocation.longitude + 0.004,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H4",
        name: "MedPlus Hospital",
        address: "Shivaji Nagar, Pune, Maharashtra 411040",
        contact: "020 2666 8899",
        email: "contact@medplushospital.com",
        website: "https://medplushospital.com",
        specialties: ["Gynaecology", "Paediatrics"],
        doctors: [
          Doctor(name: "Dr. S. Mehta", specialization: "Gynaecologist", timeSlots: ["10:00 AM", "1:00 PM", "4:00 PM"], fee: 800),
        ],
        beds: 60,
        services: ["Maternal Care", "Infertility Treatment"],
        visitingHours: "9:00 AM - 6:00 PM",
        ratings: 4.5,
        insuranceProviders: ["Provider G", "Provider H"],
        labs: ["Lab G", "Lab H"],
        lat: userLocation.latitude + 0.005,
        lng: userLocation.longitude - 0.002,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H5",
        name: "Vidyadhari Hospital",
        address: "Viman Nagar, Pune, Maharashtra 411014",
        contact: "020 2690 4321",
        email: "contact@vidyadharihospital.com",
        website: "https://vidyadharihospital.com",
        specialties: ["Orthopaedics", "Dermatology"],
        doctors: [
          Doctor(name: "Dr. K. Deshmukh", specialization: "Orthopaedic Surgeon", timeSlots: ["8:00 AM", "12:00 PM", "5:00 PM"], fee: 900),
        ],
        beds: 150,
        services: ["Orthopaedic Surgery", "Physical Therapy"],
        visitingHours: "9:00 AM - 8:00 PM",
        ratings: 4.7,
        insuranceProviders: ["Provider I", "Provider J"],
        labs: ["Lab I", "Lab J"],
        lat: userLocation.latitude + 0.006,
        lng: userLocation.longitude + 0.003,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H6",
        name: "Shree Hospital",
        address: "Baner, Pune, Maharashtra 411045",
        contact: "020 2727 5678",
        email: "contact@shreehospital.com",
        website: "https://shreehospital.com",
        specialties: ["Urology", "Nephrology"],
        doctors: [
          Doctor(name: "Dr. P. Patil", specialization: "Urologist", timeSlots: ["9:00 AM", "11:30 AM", "2:00 PM"], fee: 750),
        ],
        beds: 110,
        services: ["Dialysis", "Emergency Care"],
        visitingHours: "8:00 AM - 6:00 PM",
        ratings: 4.3,
        insuranceProviders: ["Provider K", "Provider L"],
        labs: ["Lab K", "Lab L"],
        lat: userLocation.latitude + 0.007,
        lng: userLocation.longitude - 0.004,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H7",
        name: "Bharati Hospital",
        address: "Pimpri Chinchwad, Pune, Maharashtra 411017",
        contact: "020 2744 5896",
        email: "contact@bharatihospital.com",
        website: "https://bharatihospital.com",
        specialties: ["Pulmonology", "Cardiology"],
        doctors: [
          Doctor(name: "Dr. M. Singh", specialization: "Pulmonologist", timeSlots: ["10:30 AM", "12:30 PM", "3:30 PM"], fee: 650),
        ],
        beds: 95,
        services: ["Pulmonary Care", "Cardiology Services"],
        visitingHours: "9:00 AM - 5:00 PM",
        ratings: 4.1,
        insuranceProviders: ["Provider M", "Provider N"],
        labs: ["Lab M", "Lab N"],
        lat: userLocation.latitude + 0.008,
        lng: userLocation.longitude + 0.001,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H8",
        name: "Sanjeevani Hospital",
        address: "Hadapsar, Pune, Maharashtra 411028",
        contact: "020 2695 1122",
        email: "contact@sanjeevanihospital.com",
        website: "https://sanjeevanihospital.com",
        specialties: ["Obstetrics", "Gynaecology"],
        doctors: [
          Doctor(name: "Dr. A. Patil", specialization: "Gynaecologist", timeSlots: ["9:30 AM", "12:30 PM", "5:00 PM"], fee: 720),
        ],
        beds: 80,
        services: ["Maternal Care", "Gynaecological Surgery"],
        visitingHours: "8:00 AM - 7:00 PM",
        ratings: 4.4,
        insuranceProviders: ["Provider O", "Provider P"],
        labs: ["Lab O", "Lab P"],
        lat: userLocation.latitude + 0.009,
        lng: userLocation.longitude - 0.005,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H9",
        name: "Siddhi Vinayak Hospital",
        address: "Wakad, Pune, Maharashtra 411057",
        contact: "020 2722 3344",
        email: "contact@siddhivinayakhospital.com",
        website: "https://siddhivinayakhospital.com",
        specialties: ["Gynaecology", "Orthopaedics"],
        doctors: [
          Doctor(name: "Dr. R. Joshi", specialization: "Orthopaedic Surgeon", timeSlots: ["9:00 AM", "12:00 PM", "4:00 PM"], fee: 850),
        ],
        beds: 140,
        services: ["Orthopaedic Surgery", "Gynaecology Care"],
        visitingHours: "8:30 AM - 7:30 PM",
        ratings: 4.6,
        insuranceProviders: ["Provider Q", "Provider R"],
        labs: ["Lab Q", "Lab R"],
        lat: userLocation.latitude + 0.010,
        lng: userLocation.longitude + 0.002,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
      Hospital(
        id: "H10",
        name: "CarePlus Hospital",
        address: "Hinjewadi, Pune, Maharashtra 411057",
        contact: "020 4000 2211",
        email: "contact@careplushospital.com",
        website: "https://careplushospital.com",
        specialties: ["Oncology", "Cardiology"],
        doctors: [
          Doctor(name: "Dr. S. Joshi", specialization: "Oncologist", timeSlots: ["9:00 AM", "1:00 PM", "4:00 PM"], fee: 1000),
        ],
        beds: 200,
        services: ["Cancer Care", "Cardiac Surgery"],
        visitingHours: "9:00 AM - 6:00 PM",
        ratings: 4.8,
        insuranceProviders: ["Provider S", "Provider T"],
        labs: ["Lab S", "Lab T"],
        lat: userLocation.latitude + 0.011,
        lng: userLocation.longitude - 0.003,
        images: [
          "https://media.istockphoto.com/id/482858629/photo/doctors-hospital-corridor-nurse-pushing-gurney-stretcher-bed.jpg?s=612x612&w=0&k=20&c=unfa1VMpYQGt3PyrkuvxN1JkX7FRk-w0knEFCqjTugg=",
          "https://media.istockphoto.com/id/1312706413/photo/modern-hospital-building.jpg?s=612x612&w=0&k=20&c=oUILskmtaPiA711DP53DFhOUvE7pfdNeEK9CfyxlGio=",
        ],
      ).toJson(),
    ];
  }
}
