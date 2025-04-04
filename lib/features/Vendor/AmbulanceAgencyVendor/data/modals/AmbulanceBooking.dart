class Booking {
  String userName;
  String pickupLocation;
  String dropLocation;
  String vehicleType;
  bool isAccepted;
  double fee;

  Booking({
    required this.userName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    this.isAccepted = false,
    this.fee = 0.0,
  });
}
