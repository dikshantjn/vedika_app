import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class BedBooking {
  final String? bedBookingId;
  final String? vendorId;
  final String? userId;
  final String? hospitalId;
  final String? wardId;
  final String bedType;
  final double price;
  final double paidAmount;
  final String paymentStatus;
  final DateTime bookingDate;
  final String timeSlot;
  final String? selectedDoctorId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Hospital hospital;
  final User user;

  BedBooking({
    this.bedBookingId,
    this.vendorId,
    this.userId,
    this.hospitalId,
    this.wardId,
    required this.bedType,
    required this.price,
    required this.paidAmount,
    required this.paymentStatus,
    required this.bookingDate,
    required this.timeSlot,
    this.selectedDoctorId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.hospital,
    required this.user,
  });

  factory BedBooking.fromJson(Map<String, dynamic> json) {
    return BedBooking(
      bedBookingId: json['bedBookingId']?.toString(),
      vendorId: json['vendorId']?.toString(),
      userId: json['userId']?.toString(),
      hospitalId: json['hospitalId']?.toString(),
      wardId: json['wardId']?.toString(),
      bedType: json['bedType']?.toString() ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      bookingDate: DateTime.parse(json['bookingDate']?.toString() ?? DateTime.now().toString()),
      timeSlot: json['timeSlot']?.toString() ?? 'Unknown',
      selectedDoctorId: json['selectedDoctorId']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toString()),
      hospital: Hospital.fromJson(json['hospital'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedBookingId': bedBookingId,
      'vendorId': vendorId,
      'userId': userId,
      'hospitalId': hospitalId,
      'wardId': wardId,
      'bedType': bedType,
      'price': price,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'selectedDoctorId': selectedDoctorId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hospital': hospital.toJson(),
      'user': user.toJson(),
    };
  }

  BedBooking copyWith({
    String? bedBookingId,
    String? vendorId,
    String? userId,
    String? hospitalId,
    String? wardId,
    String? bedType,
    double? price,
    double? paidAmount,
    String? paymentStatus,
    DateTime? bookingDate,
    String? timeSlot,
    String? selectedDoctorId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Hospital? hospital,
    User? user,
  }) {
    return BedBooking(
      bedBookingId: bedBookingId ?? this.bedBookingId,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      hospitalId: hospitalId ?? this.hospitalId,
      wardId: wardId ?? this.wardId,
      bedType: bedType ?? this.bedType,
      price: price ?? this.price,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      selectedDoctorId: selectedDoctorId ?? this.selectedDoctorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hospital: hospital ?? this.hospital,
      user: user ?? this.user,
    );
  }
}

class Hospital {
  final String name;
  final String address;
  final String city;
  final String state;
  final String contactNumber;
  final String email;

  Hospital({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.contactNumber,
    required this.email,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name']?.toString() ?? 'Unknown Hospital',
      address: json['address']?.toString() ?? 'Unknown Address',
      city: json['city']?.toString() ?? 'Unknown City',
      state: json['state']?.toString() ?? 'Unknown State',
      contactNumber: json['contactNumber']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'contactNumber': contactNumber,
      'email': email,
    };
  }
}

class User {
  final String? userId;
  final String? name;
  final String phoneNumber;
  final String? emailId;
  final String? gender;
  final String? photo;

  User({
    this.userId,
    this.name,
    required this.phoneNumber,
    this.emailId,
    this.gender,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId']?.toString(),
      name: json['name']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? 'Unknown',
      emailId: json['emailId']?.toString(),
      gender: json['gender']?.toString(),
      photo: json['photo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone_number': phoneNumber,
      'emailId': emailId,
      'gender': gender,
      'photo': photo,
    };
  }
}

class BedType {
  final String id;
  final String type;
  final double price;
  final String description;

  BedType({
    required this.id,
    required this.type,
    required this.price,
    required this.description,
  });

  static List<BedType> getBedTypes() {
    return [
      BedType(
        id: 'generic_ward',
        type: 'Generic Ward',
        price: 1000.0,
        description: 'Shared ward with basic amenities',
      ),
      BedType(
        id: 'semi_private_ward',
        type: 'Semi-Private Ward',
        price: 2000.0,
        description: 'Semi-private room with shared bathroom',
      ),
      BedType(
        id: 'private_ward',
        type: 'Private Ward',
        price: 3000.0,
        description: 'Private room with attached bathroom',
      ),
      BedType(
        id: 'female_ward',
        type: 'Female Ward',
        price: 1500.0,
        description: 'Dedicated ward for female patients',
      ),
      BedType(
        id: 'male_ward',
        type: 'Male Ward',
        price: 1500.0,
        description: 'Dedicated ward for male patients',
      ),
      BedType(
        id: 'children_ward',
        type: 'Children Ward',
        price: 2500.0,
        description: 'Special ward for pediatric patients',
      ),
      BedType(
        id: 'icu_ward',
        type: 'ICU Ward',
        price: 5000.0,
        description: 'Intensive Care Unit with 24/7 monitoring',
      ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BedType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 