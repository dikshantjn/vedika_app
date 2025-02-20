import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class ClinicData {
  List<Clinic> getClinics(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return []; // Return an empty list if the location isn't available yet
    }

    // User's current location (around central Pune)
    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

    // Actual clinic data
    return [
      Clinic(
        id: "C1",
        name: "Shree Child care",
        address: "104 Decision tower near city pride cinema hall, Pune - Satara Rd, above Dominos pizza, Pune, Maharashtra 411037",
        contact: "Phone: 094230 32257",
        lat: userLocation.latitude + 0.001,
        lng: userLocation.longitude + 0.002,
        doctors: [
          Doctor(
            name: "Dr. Shree",
            specialization: "Pediatrician",
            timeSlots: ["10:30 AM - 12:30 PM", "5:30 PM - 8:45 PM"],
            fee: 500,
            imageUrl: 'https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["Pediatrician"],
        images: [
          'https://plus.unsplash.com/premium_photo-1682130157004-057c137d96d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
      Clinic(
        id: "C2",
        name: "Advanced Dental Clinic",
        address: "106, Decision Tower, Next To City Pride Cinema, Opposite Bhapkar Petrol Pump, Pune Satara Road, Pune Satara Road, Pune, Maharashtra 411037",
        contact: "Phone: 020 2421 3708",
        lat: userLocation.latitude + 0.003,
        lng: userLocation.longitude - 0.003,
        doctors: [
          Doctor(
            name: "Dr. Sharma",
            specialization: "Dental",
            timeSlots: ["9:30 AM - 8:30 PM"],
            fee: 600,
            imageUrl: 'https://img.freepik.com/premium-photo/portrait-smiling-young-male-doctor-with-stethoscope-around-neck-standing-with-crossed-arms-white-coat-isolated-blue-background_1016700-2997.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["Dental"],
        images: [
          'https://plus.unsplash.com/premium_photo-1664475477169-46b784084d4e?q=80&w=2072&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
      Clinic(
        id: "C3",
        name: "Neha Clinic",
        address: "FVP3+FQ3, Sant Nagar Chowk, Taware Colony, Aranyeshwar Road, Parvati, Parvati, Pune, Maharashtra 411009",
        contact: "Phone: 020 2422 1747",
        lat: userLocation.latitude + 0.005,
        lng: userLocation.longitude + 0.004,
        doctors: [
          Doctor(
            name: "Dr. Neha",
            specialization: "General Physician",
            timeSlots: ["10:00 AM - 2:00 PM", "6:00 PM - 10:00 PM"],
            fee: 550,
            imageUrl: 'https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["General Physician"],
        images: [
          'https://images.unsplash.com/photo-1512678080530-7760d81faba6?q=80&w=2074&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
      Clinic(
        id: "C4",
        name: "Tulip Health Care Clinic",
        address: "Snehal Kunj Building, Opposite Swadesh Milk Centre Near Treasure Park, Aranyeshwar Padmavati Rd, Sant Nagar, Pune, Maharashtra 411009",
        contact: "Phone: 096733 71818",
        lat: userLocation.latitude + 0.004,
        lng: userLocation.longitude + 0.002,
        doctors: [
          Doctor(
            name: "Dr. Tulip",
            specialization: "Maternity",
            timeSlots: ["10:00 AM - 2:00 PM", "5:00 PM - 9:00 PM"],
            fee: 650,
            imageUrl: 'https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["Maternity"],
        images: [
          'https://plus.unsplash.com/premium_photo-1682130157004-057c137d96d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
      Clinic(
        id: "C5",
        name: "Nuleaf Skin Clinic and Hair Transplant Centre",
        address: "203, Pushpa Prestige, Pune-Satara Road, Parvati Darshan, Pune, Maharashtra 411009",
        contact: "NA",
        lat: userLocation.latitude + 0.003,
        lng: userLocation.longitude + 0.005,
        doctors: [
          Doctor(
            name: "Dr. Nuleaf",
            specialization: "Skin and Hair",
            timeSlots: ["10:30 AM - 8:00 PM"],
            fee: 700,
            imageUrl: 'https://img.freepik.com/premium-photo/portrait-smiling-young-male-doctor-with-stethoscope-around-neck-standing-with-crossed-arms-white-coat-isolated-blue-background_1016700-2997.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["Skin and Hair"],
        images: [
          'https://plus.unsplash.com/premium_photo-1682130157004-057c137d96d5?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
      Clinic(
        id: "C6",
        name: "Holistic Multispecialty Clinic",
        address: "Vedant Hotel, Beside ICICI Bank, First Floor, Plot No. 4, S No. 46/1, B-2 Kaka Halwai Estate, Pune - Satara Rd, near City Pride, Pune, Maharashtra 411009",
        contact: "Phone: 088281 18804",
        lat: userLocation.latitude + 0.006,
        lng: userLocation.longitude - 0.002,
        doctors: [
          Doctor(
            name: "Dr. Holistic",
            specialization: "Multispeciality",
            timeSlots: ["08:00 AM - 8:00 PM"],
            fee: 750,
            imageUrl: 'https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg?ga=GA1.1.984242816.1724735164&semt=ais_hybrid',
          )
        ],
        specialties: ["Multispeciality"],
        images: [
          'https://plus.unsplash.com/premium_photo-1664475477169-46b784084d4e?q=80&w=2072&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ],
      ),
    ];
  }
}
