class UserModel {
  final String userId;
  final String name;
  final String phone;
  final String password;

  UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      password: json['password'], // This won't be stored in real scenarios
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "phone": phone,
      "password": password,
    };
  }
}
