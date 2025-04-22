class Vendor {
  final int vendorRole;
  final String phoneNumber;
  final String email;
  final String password;
  final String generatedId;
  final bool isActive;

  Vendor({
    required this.vendorRole,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.generatedId = '',
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorRole': vendorRole,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'generatedId': generatedId,
      'isActive': isActive,
    };
  }
} 