class Ward {
  final String wardId;
  final String name;
  final String wardType; // e.g., General, ICU, Private, Semi-Private
  final int totalBeds;
  final int availableBeds;
  final double pricePerDay;
  final String genderRestriction; // 'Male', 'Female', 'None'
  final bool isAC;
  final bool hasAttachedBathroom;
  final bool isIsolation;
  final String description;
  final String vendorId;
  final List<String> facilities; // e.g., ['TV', 'Fan', 'Nurse Call Button']
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ward({
    required this.wardId,
    required this.name,
    required this.wardType,
    required this.totalBeds,
    required this.availableBeds,
    required this.pricePerDay,
    required this.genderRestriction,
    required this.isAC,
    required this.hasAttachedBathroom,
    required this.isIsolation,
    required this.description,
    required this.vendorId,
    required this.facilities,
    this.createdAt,
    this.updatedAt,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      wardId: json['wardId'] ?? '',
      name: json['name'] ?? '',
      wardType: json['wardType'] ?? '',
      totalBeds: json['totalBeds'] ?? 0,
      availableBeds: json['availableBeds'] ?? 0,
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      genderRestriction: json['genderRestriction'] ?? 'None',
      isAC: json['isAC'] ?? false,
      hasAttachedBathroom: json['hasAttachedBathroom'] ?? false,
      isIsolation: json['isIsolation'] ?? false,
      description: json['description'] ?? '',
      vendorId: json['vendorId'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wardId': wardId,
      'name': name,
      'wardType': wardType,
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,
      'pricePerDay': pricePerDay,
      'genderRestriction': genderRestriction,
      'isAC': isAC,
      'hasAttachedBathroom': hasAttachedBathroom,
      'isIsolation': isIsolation,
      'description': description,
      'vendorId': vendorId,
      'facilities': facilities,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
} 