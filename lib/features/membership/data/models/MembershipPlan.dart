class MembershipPlan {
  final String membershipPlanId;
  final String name;
  final String title;
  final double price;
  final String duration;
  final String description;
  final List<MembershipFeature> features;
  final List<String> highlights;
  final bool isPopular;
  final String? popularBadge;
  final String type; // NEW FIELD (silver, gold, platinum, etc.)

  MembershipPlan({
    required this.membershipPlanId,
    required this.name,
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    required this.features,
    required this.highlights,
    this.isPopular = false,
    this.popularBadge,
    required this.type, // required in constructor
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      membershipPlanId: json['membershipPlanId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => MembershipFeature.fromJson(e))
          .toList() ??
          [],
      highlights: List<String>.from(json['highlights'] ?? []),
      isPopular: json['isPopular'] ?? false,
      popularBadge: json['popularBadge'],
      type: json['type'] ?? '', // map from backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membershipPlanId': membershipPlanId,
      'name': name,
      'title': title,
      'price': price,
      'duration': duration,
      'description': description,
      'features': features.map((e) => e.toJson()).toList(),
      'highlights': highlights,
      'isPopular': isPopular,
      'popularBadge': popularBadge,
      'type': type,
    };
  }
}

class MembershipFeature {
  final String id;
  final String title;
  final String description;
  final String? value;
  final bool isIncluded;
  final String category;

  MembershipFeature({
    required this.id,
    required this.title,
    required this.description,
    this.value,
    required this.isIncluded,
    required this.category,
  });

  factory MembershipFeature.fromJson(Map<String, dynamic> json) {
    return MembershipFeature(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value'],
      isIncluded: json['isIncluded'] ?? false,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'value': value,
      'isIncluded': isIncluded,
      'category': category,
    };
  }
}

class UserMembership {
  final String userMembershipId;
  final String userId;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String status;
  final double amountPaid;
  final String paymentMethod;
  final DateTime? lastPaymentDate;
  final String type; // NEW FIELD (silver, gold, platinum, etc.)

  UserMembership({
    required this.userMembershipId,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.status,
    required this.amountPaid,
    required this.paymentMethod,
    this.lastPaymentDate,
    required this.type, // required in constructor
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      userMembershipId: json['userMembershipId'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      startDate: DateTime.parse(
          json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
      DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? '',
      amountPaid: json['amountPaid']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'])
          : null,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userMembershipId': userMembershipId,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'type': type,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}
