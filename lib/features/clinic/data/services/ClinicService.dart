import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

// Model for booked slot
class BookedSlot {
  final String time;
  final String userId;

  BookedSlot({
    required this.time,
    required this.userId,
  });

  factory BookedSlot.fromJson(Map<String, dynamic> json) {
    return BookedSlot(
      time: json['time'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}

// Model for time slots response
class TimeSlotsResponse {
  final String vendorId;
  final String date;
  final String day;
  final List<String> availableSlots;
  final List<BookedSlot> bookedSlots;

  TimeSlotsResponse({
    required this.vendorId,
    required this.date,
    required this.day,
    required this.availableSlots,
    required this.bookedSlots,
  });

  factory TimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    return TimeSlotsResponse(
      vendorId: json['vendorId'] ?? '',
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      bookedSlots: (json['bookedSlots'] as List<dynamic>?)
          ?.map((slot) => BookedSlot.fromJson(slot))
          .toList() ?? [],
    );
  }
}

class ClinicService {
  final Dio _dio;

  ClinicService() : _dio = Dio() {
    // Configure Dio
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Log interceptor removed for cleaner output
  }

  // Fetch active online clinics
  Future<List<DoctorClinicProfile>> getActiveOnlineClinics() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getActiveOnlineClinics,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      
      // Debugging raw response structure
      if (response.data is Map && response.data.containsKey('clinics')) {
        final List<dynamic> data = response.data['clinics'] ?? [];

        // Debug prints removed for cleaner output

        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      } 
      // Check for the 'data' key in the response (our original expectation)
      else if (response.data is Map && response.data.containsKey('data')) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      }
      // If neither key is present but response is a list
      else if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      } 
      // If none of the above, try one last approach
      else {
        // Print all top-level keys to help diagnose
        if (response.data is Map) {
          // Try to find any list in the response
          for (var key in (response.data as Map).keys) {
            if (response.data[key] is List && (response.data[key] as List).isNotEmpty) {
              final List<dynamic> data = response.data[key];
              return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
            }
          }
        }
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching online clinics: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching online clinics: $e');
    }
  }

  // Fetch active offline clinics
  Future<List<DoctorClinicProfile>> getActiveOfflineClinics() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getActiveOfflineClinics,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      
      if (response.statusCode == 200) {
        // Check for the 'clinics' key in the response
        if (response.data is Map && response.data.containsKey('clinics')) {
          final List<dynamic> data = response.data['clinics'] ?? [];
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        } 
        // Check for the 'data' key in the response (our original expectation)
        else if (response.data is Map && response.data.containsKey('data')) {
          final List<dynamic> data = response.data['data'] ?? [];
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        }
        // If neither key is present but response is a list
        else if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        } 
        // If none of the above, try one last approach
        else {
          // Print all top-level keys to help diagnose
          if (response.data is Map) {
            // Try to find any list in the response
            for (var key in (response.data as Map).keys) {
              if (response.data[key] is List && (response.data[key] as List).isNotEmpty) {
                final List<dynamic> data = response.data[key];
                return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
              }
            }
          }
          print('❌ Could not parse response data: ${response.data}');
          throw Exception('Unexpected data format');
        }
      } else {
        print('❌ API Error: Failed to load offline clinics: ${response.statusCode}');
        throw Exception('Failed to load offline clinics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in getActiveOfflineClinics:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching offline clinics: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching offline clinics: $e');
    }
  }
  
  // Get clinic details by ID
  Future<DoctorClinicProfile> getClinicById(String clinicId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getClinicProfile}/$clinicId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      

      if (response.statusCode == 200) {
        final dynamic data = response.data['data'];
        return DoctorClinicProfile.fromJson(data);
      } else {
        throw Exception('Failed to load clinic details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching clinic details: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching clinic details: $e');
    }
  }

  // Create clinic appointment
  Future<Map<String, dynamic>> createClinicAppointment({
    required String doctorId,
    required String userId,
    required String status,
    required bool isOnline,
    required DateTime date,
    required String time,
    required double paidAmount,
    required String paymentStatus,
    required String vendorId,
    required String userResponseStatus,
    String? meetingUrl,
  }) async {
    try {
      final Map<String, dynamic> appointmentData = {
        "doctorId": doctorId,
        "userId": userId,
        "status": status,
        "isOnline": isOnline,
        "date": date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        "time": time,
        "paidAmount": paidAmount,
        "paymentStatus": paymentStatus,
        "vendorId": vendorId,
        "userResponseStatus": userResponseStatus,
        "meetingUrl": meetingUrl,
      };

      // Debug print removed
      
      final response = await _dio.post(
        ApiEndpoints.createClinicAppointment,
        data: appointmentData,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      

      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Appointment created successfully',
          'data': response.data['data'] ?? response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create appointment: ${response.statusMessage}',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in createClinicAppointment:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      return {
        'success': false,
        'message': 'Error creating appointment: ${e.message}',
      };
    } catch (e) {
      print('❌ Exception in createClinicAppointment: $e');
      return {
        'success': false,
        'message': 'Error creating appointment: $e',
      };
    }
  }

  // Fetch time slots by vendor and date
  Future<TimeSlotsResponse> getTimeSlotsByVendorAndDate({
    required String vendorId,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getClinicTimeslotsByVendorAndDate}/$vendorId/date/$date',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return TimeSlotsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load time slots: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching time slots: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching time slots: $e');
    }
  }
} 