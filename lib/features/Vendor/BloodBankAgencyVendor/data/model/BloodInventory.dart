class BloodInventory {
  final String? bloodInventoryId;
  final String bloodType;
  int unitsAvailable;
  bool isAvailable;
  final String vendorId;
  final DateTime? lastUpdated;

  BloodInventory({
    this.bloodInventoryId,
    required this.bloodType,
    required this.unitsAvailable,
    required this.isAvailable,
    required this.vendorId,
    this.lastUpdated,
  });

  // Create a copy of this BloodInventory with the given fields replaced with the new values
  BloodInventory copyWith({
    String? bloodInventoryId,
    String? bloodType,
    int? unitsAvailable,
    bool? isAvailable,
    String? vendorId,
    DateTime? lastUpdated,
  }) {
    return BloodInventory(
      bloodInventoryId: bloodInventoryId ?? this.bloodInventoryId,
      bloodType: bloodType ?? this.bloodType,
      unitsAvailable: unitsAvailable ?? this.unitsAvailable,
      isAvailable: isAvailable ?? this.isAvailable,
      vendorId: vendorId ?? this.vendorId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convert BloodInventory to JSON
  Map<String, dynamic> toJson() {
    return {
      if (bloodInventoryId != null) 'bloodInventoryId': bloodInventoryId,
      'bloodType': bloodType,
      'unitsAvailable': unitsAvailable,
      'isAvailable': isAvailable,
      'vendorId': vendorId,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    };
  }

  // Create BloodInventory from JSON
  factory BloodInventory.fromJson(Map<String, dynamic> json) {
    return BloodInventory(
      bloodInventoryId: json['bloodInventoryId'] as String?,
      bloodType: json['bloodType'] as String,
      unitsAvailable: json['unitsAvailable'] as int,
      isAvailable: json['isAvailable'] as bool,
      vendorId: json['vendorId'] as String,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'BloodInventory(bloodInventoryId: $bloodInventoryId, bloodType: $bloodType, unitsAvailable: $unitsAvailable, isAvailable: $isAvailable, vendorId: $vendorId, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BloodInventory &&
        other.bloodInventoryId == bloodInventoryId &&
        other.bloodType == bloodType &&
        other.unitsAvailable == unitsAvailable &&
        other.isAvailable == isAvailable &&
        other.vendorId == vendorId &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      bloodInventoryId,
      bloodType,
      unitsAvailable,
      isAvailable,
      vendorId,
      lastUpdated,
    );
  }
} 