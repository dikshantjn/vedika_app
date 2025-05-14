class ProductPartner {
  String? vendorId;
  String? generatedId;
  String password;
  String companyLegalName;
  String brandName;
  String gstNumber;
  String panCardNumber;
  List<Map<String, String>> licenseDetails;
  String address;
  String pincode;
  String city;
  String state;
  String email;
  String bankAccountNumber;
  String profilePicture;
  String location;
  String phoneNumber;

  ProductPartner({
    this.vendorId,
    this.generatedId,
    required this.password,
    required this.companyLegalName,
    required this.brandName,
    required this.gstNumber,
    required this.panCardNumber,
    required this.licenseDetails,
    required this.address,
    required this.pincode,
    required this.city,
    required this.state,
    required this.email,
    required this.bankAccountNumber,
    required this.profilePicture,
    required this.location,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'vendorId': vendorId,
        'generatedId': generatedId,
        'password': password,
        'companyLegalName': companyLegalName,
        'brandName': brandName,
        'gstNumber': gstNumber,
        'panCardNumber': panCardNumber,
        'licenseDetails': licenseDetails,
        'address': address,
        'pincode': pincode,
        'city': city,
        'state': state,
        'email': email,
        'bankAccountNumber': bankAccountNumber,
        'profilePicture': profilePicture,
        'location': location,
        'phoneNumber': phoneNumber,
      };

  factory ProductPartner.fromJson(Map<String, dynamic> json) {
    return ProductPartner(
      vendorId: json['vendorId'],
      generatedId: json['generatedId'],
      password: json['password'],
      companyLegalName: json['companyLegalName'],
      brandName: json['brandName'],
      gstNumber: json['gstNumber'],
      panCardNumber: json['panCardNumber'],
      licenseDetails: List<Map<String, String>>.from(
        json['licenseDetails'].map((x) => Map<String, String>.from(x)),
      ),
      address: json['address'],
      pincode: json['pincode'],
      city: json['city'],
      state: json['state'],
      email: json['email'],
      bankAccountNumber: json['bankAccountNumber'],
      profilePicture: json['profilePicture'],
      location: json['location'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
