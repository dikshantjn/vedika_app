// import 'package:dio/dio.dart';
// import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
//
// class BloodBankService {
//   final Dio _dio = Dio();
//
//   BloodBankService() {
//     _dio.options = BaseOptions(
//       baseUrl: ApiEndpoints.baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {"Content-Type": "application/json"},
//     );
//   }
//
//   // Service Status
//   Future<Map<String, dynamic>> getServiceStatus() async {
//     try {
//       final response = await _dio.get(ApiEndpoints.bloodBankServiceStatus);
//       return response.data;
//     } on DioError catch (e) {
//       throw Exception('Failed to get service status: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   Future<void> updateServiceStatus(bool isActive) async {
//     try {
//       await _dio.put(
//         ApiEndpoints.bloodBankServiceStatus,
//         data: {'isActive': isActive},
//       );
//     } on DioError catch (e) {
//       throw Exception('Failed to update service status: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   // Blood Availability
//   Future<Map<String, dynamic>> getBloodAvailability() async {
//     try {
//       final response = await _dio.get(ApiEndpoints.bloodBankAvailability);
//       return response.data;
//     } on DioError catch (e) {
//       throw Exception('Failed to get blood availability: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   Future<void> updateBloodAvailability(Map<String, dynamic> availability) async {
//     try {
//       await _dio.put(
//         ApiEndpoints.bloodBankAvailability,
//         data: availability,
//       );
//     } on DioError catch (e) {
//       throw Exception('Failed to update blood availability: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   // Requests
//   Future<Map<String, dynamic>> getRequests() async {
//     try {
//       final response = await _dio.get(ApiEndpoints.bloodBankRequests);
//       return response.data;
//     } on DioError catch (e) {
//       throw Exception('Failed to get requests: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   Future<void> acceptRequest(String requestId) async {
//     try {
//       await _dio.post(
//         ApiEndpoints.bloodBankAcceptRequest,
//         data: {'requestId': requestId},
//       );
//     } on DioError catch (e) {
//       throw Exception('Failed to accept request: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   Future<void> rejectRequest(String requestId) async {
//     try {
//       await _dio.post(
//         ApiEndpoints.bloodBankRejectRequest,
//         data: {'requestId': requestId},
//       );
//     } on DioError catch (e) {
//       throw Exception('Failed to reject request: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
//
//   // Analytics
//   Future<Map<String, dynamic>> getAnalytics({
//     required String period,
//     required String type,
//   }) async {
//     try {
//       final response = await _dio.get(
//         ApiEndpoints.bloodBankAnalytics,
//         queryParameters: {
//           'period': period,
//           'type': type,
//         },
//       );
//       return response.data;
//     } on DioError catch (e) {
//       throw Exception('Failed to get analytics: ${e.response?.data['message'] ?? e.message}');
//     }
//   }
// }