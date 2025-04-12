import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankBooking {
  final String? bookingId;
  final String requestId;
  final String vendorId;
  final String userId;
  final UserModel user;
  final double deliveryFees;
  final double gst;
  final double discount;
  final double totalAmount;
  final String status; // confirmed, completed, cancelled
  final DateTime createdAt;

  BloodBankBooking({
    this.bookingId,
    required this.requestId,
    required this.vendorId,
    required this.userId,
    required this.user,
    required this.deliveryFees,
    required this.gst,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  BloodBankBooking copyWith({
    String? bookingId,
    String? requestId,
    String? vendorId,
    String? userId,
    UserModel? user,
    double? deliveryFees,
    double? gst,
    double? discount,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
  }) {
    return BloodBankBooking(
      bookingId: bookingId ?? this.bookingId,
      requestId: requestId ?? this.requestId,
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      gst: gst ?? this.gst,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'requestId': requestId,
      'vendorId': vendorId,
      'userId': userId,
      'user': user.toJson(),
      'deliveryFees': deliveryFees,
      'gst': gst,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BloodBankBooking.fromJson(Map<String, dynamic> json) {
    return BloodBankBooking(
      bookingId: json['bookingId'],
      requestId: json['requestId'],
      vendorId: json['vendorId'],
      userId: json['userId'],
      user: UserModel.fromJson(json['user']),
      deliveryFees: json['deliveryFees'].toDouble(),
      gst: json['gst'].toDouble(),
      discount: json['discount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Calculate total amount including all charges
  static double calculateTotalAmount(double baseAmount, double deliveryFees, double gst, double discount) {
    final subtotal = baseAmount + deliveryFees;
    final gstAmount = subtotal * (gst / 100);
    return subtotal + gstAmount - discount;
  }

  @override
  String toString() {
    return 'BloodBankBooking(bookingId: $bookingId, requestId: $requestId, vendorId: $vendorId, user: ${user.name}, status: $status, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodBankBooking && other.bookingId == bookingId;
  }

  @override
  int get hashCode => bookingId.hashCode;
} 