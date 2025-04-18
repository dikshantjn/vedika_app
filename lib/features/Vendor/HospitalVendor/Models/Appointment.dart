class Appointment {
  final String id;
  final String patientName;
  final String phoneNumber;
  final String address;
  final String appointmentTime;
  final String status;
  final bool isProcessing;
  final double amount;
  final String? notes;

  Appointment({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.address,
    required this.appointmentTime,
    required this.status,
    this.isProcessing = false,
    this.amount = 2500.0,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      appointmentTime: json['appointmentTime'] as String,
      status: json['status'] as String,
      isProcessing: json['isProcessing'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toDouble() ?? 2500.0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'address': address,
      'appointmentTime': appointmentTime,
      'status': status,
      'isProcessing': isProcessing,
      'amount': amount,
      'notes': notes,
    };
  }

  Appointment copyWith({
    String? id,
    String? patientName,
    String? phoneNumber,
    String? address,
    String? appointmentTime,
    String? status,
    bool? isProcessing,
    double? amount,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }
} 