class AmbulanceBooking {
  String requestId; // Unique identifier for the booking request
  String userId; // User requesting the ambulance
  String vendorId; // The agency handling the request
  String customerName; // Name of the person requesting the ambulance
  String phoneNumber; // Phone number of the user
  String pickupLocation; // Location where the ambulance will pick the user
  String dropLocation; // Location where the user needs to be dropped
  String urgency; // Urgency of the request (e.g., Urgent, Non-Urgent)
  String vehicleType; // Type of vehicle required (BLS, ALS, ICU, etc.)
  int numberOfPersons; // Number of persons to be transported
  DateTime requiredDateTime; // Date and time when the ambulance is required
  double fees; // Fees charged by the agency
  double gst; // GST applied
  double discount; // Discount applied to the booking
  double totalAmount; // Total amount after applying GST and discount
  bool isPaid; // Flag to check if the user has paid the total amount
  String status; // Status of the request (Accepted, Pending, Rejected)
  String agencyContactNumber; // Agency contact number for communication
  String ambulanceDriverId; // ID of the driver handling the booking
  String userLocation; // User's location for easy communication with the driver
  String agencyNotes; // Additional notes from the agency

  AmbulanceBooking({
    required this.requestId,
    required this.userId,
    required this.vendorId,
    required this.customerName,
    required this.phoneNumber,
    required this.pickupLocation,
    required this.dropLocation,
    required this.urgency,
    required this.vehicleType,
    required this.numberOfPersons,
    required this.requiredDateTime,
    required this.fees,
    required this.gst,
    required this.discount,
    required this.totalAmount,
    this.isPaid = false,
    this.status = 'Pending',
    this.agencyContactNumber = '',
    this.ambulanceDriverId = '',
    this.userLocation = '',
    this.agencyNotes = '',
  });
}
