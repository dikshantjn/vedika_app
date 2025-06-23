import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';

class HospitalService {
  final Dio _dio = Dio();

  Future<List<HospitalProfile>> getAllHospitals() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAllHospitals,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      print("✅ Fetch Hospitals Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('hospitals')) {
          final hospitals = data['hospitals'] as List;
          return hospitals.map((hospitalData) {
            // Convert dynamic lists to the correct type
            final certifications = (hospitalData['certifications'] as List?)
                ?.map((cert) => {
                      'name': cert['name']?.toString() ?? '',
                      'url': cert['url']?.toString() ?? '',
                    })
                .toList() ?? [];
            
            final licenses = (hospitalData['licenses'] as List?)
                ?.map((license) => {
                      'name': license['name']?.toString() ?? '',
                      'url': license['url']?.toString() ?? '',
                    })
                .toList() ?? [];
            
            final photos = (hospitalData['photos'] as List?)
                ?.map((photo) => {
                      'name': photo['name']?.toString() ?? '',
                      'url': photo['url']?.toString() ?? '',
                    })
                .toList() ?? [];
            
            final doctors = (hospitalData['doctors'] as List?)
                ?.map((doctor) => {
                      'name': doctor['name']?.toString() ?? '',
                      'speciality': doctor['speciality']?.toString() ?? '',
                      'experience': doctor['experience']?.toString() ?? '',
                    })
                .toList() ?? [];

            // Convert all string fields to ensure they are strings
            final convertedData = {
              'vendorId': hospitalData['vendorId']?.toString() ?? '',
              'generatedId': hospitalData['generatedId']?.toString() ?? '',
              'name': hospitalData['name']?.toString() ?? '',
              'gstNumber': hospitalData['gstNumber']?.toString() ?? '',
              'panNumber': hospitalData['panNumber']?.toString() ?? '',
              'address': hospitalData['address']?.toString() ?? '',
              'landmark': hospitalData['landmark']?.toString() ?? '',
              'ownerName': hospitalData['ownerName']?.toString() ?? '',
              'certifications': certifications,
              'licenses': licenses,
              'specialityTypes': (hospitalData['specialityTypes'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
              'servicesOffered': (hospitalData['servicesOffered'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
              'bedsAvailable': int.tryParse(hospitalData['bedsAvailable']?.toString() ?? '0') ?? 0,
              'doctors': doctors,
              'workingTime': hospitalData['workingTime']?.toString() ?? '',
              'workingDays': hospitalData['workingDays']?.toString() ?? '',
              'contactNumber': hospitalData['contactNumber']?.toString() ?? '',
              'email': hospitalData['email']?.toString() ?? '',
              'website': hospitalData['website']?.toString(),
              'hasLiftAccess': hospitalData['hasLiftAccess'] == true,
              'hasParking': hospitalData['hasParking'] == true,
              'providesAmbulanceService': hospitalData['providesAmbulanceService'] == true,
              'about': hospitalData['about']?.toString() ?? '',
              'hasWheelchairAccess': hospitalData['hasWheelchairAccess'] == true,
              'providesOnlineConsultancy': hospitalData['providesOnlineConsultancy'] == true,
              'feesRange': hospitalData['feesRange']?.toString() ?? '',
              'otherFacilities': (hospitalData['otherFacilities'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
              'insuranceCompanies': (hospitalData['insuranceCompanies'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [],
              'photos': photos,
              'state': hospitalData['state']?.toString() ?? '',
              'city': hospitalData['city']?.toString() ?? '',
              'pincode': hospitalData['pincode']?.toString() ?? '',
              'location': hospitalData['location']?.toString() ?? '',
              'isActive': hospitalData['isActive'] == true,
              'panCardFile': hospitalData['panCardFile'],
              'businessDocuments': (hospitalData['businessDocuments'] as List?)?.map((doc) => {
                    'name': doc['name']?.toString() ?? '',
                    'url': doc['url']?.toString() ?? '',
                  }).toList() ?? [],
            };

            return HospitalProfile.fromJson(convertedData);
          }).toList();
        } else {
          print("❌ Fetch Error: Hospitals data is missing");
          throw Exception("Hospitals data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch hospitals: ${response.data}');
      }
    } on DioException catch (e) {
      print("❌ Fetch DioException: ${e.message}");
      print("❌ Fetch Error Response: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBedBooking({
    required String vendorId,
    required String userId,
    required String hospitalId,
    required String wardId,
    required String bedType,
    required double price,
    required double paidAmount,
    required String paymentStatus,
    required DateTime bookingDate,
    required String timeSlot,
    String? selectedDoctorId,
    required String status,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createBedBooking,
        data: {
          'vendorId': vendorId,
          'userId': userId,
          'hospitalId': hospitalId,
          'wardId': wardId,
          'bedType': bedType,
          'price': price,
          'paidAmount': paidAmount,
          'paymentStatus': paymentStatus,
          'bookingDate': bookingDate.toIso8601String().split('T')[0],
          'timeSlot': timeSlot,
          'selectedDoctorId': selectedDoctorId,
          'status': status,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Create Bed Booking Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Bed booking request sent successfully',
        };
      } else {
        print("❌ Create Bed Booking Error: ${response.statusCode} - ${response.data}");
        return {
          'success': false,
          'message': 'Failed to create bed booking: ${response.data}',
        };
      }
    } on DioException catch (e) {
      print("❌ Create Bed Booking DioException: ${e.message}");
      print("❌ Create Bed Booking Error Response: ${e.response?.data}");
      return {
        'success': false,
        'message': 'Failed to create bed booking: ${e.message}',
      };
    } catch (e) {
      print("❌ Create Bed Booking Exception: $e");
      return {
        'success': false,
        'message': 'Failed to create bed booking: $e',
      };
    }
  }

  Future<List<BedBooking>> getUserOngoingBookings(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getUserOngoingBookings}/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Fetch User Bookings Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('bookings')) {
          final bookings = data['bookings'] as List;
          return bookings.map((booking) => BedBooking.fromJson(booking)).toList();
        } else {
          print("❌ Fetch Error: Bookings data is missing");
          throw Exception("Bookings data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch bookings: ${response.data}');
      }
    } on DioException catch (e) {
      print("❌ Fetch DioException: ${e.message}");
      print("❌ Fetch Error Response: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePaymentStatus(String bookingId) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updatePaymentStatus}/$bookingId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Update Payment Status Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Payment status updated successfully',
        };
      } else {
        print("❌ Update Payment Status Error: ${response.statusCode} - ${response.data}");
        return {
          'success': false,
          'message': 'Failed to update payment status: ${response.data}',
        };
      }
    } on DioException catch (e) {
      print("❌ Update Payment Status DioException: ${e.message}");
      print("❌ Update Payment Status Error Response: ${e.response?.data}");
      return {
        'success': false,
        'message': 'Failed to update payment status: ${e.message}',
      };
    } catch (e) {
      print("❌ Update Payment Status Exception: $e");
      return {
        'success': false,
        'message': 'Failed to update payment status: $e',
      };
    }
  }
} 