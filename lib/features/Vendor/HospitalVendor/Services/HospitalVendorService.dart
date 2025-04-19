import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';

class HospitalVendorService {
  final Dio _dio = Dio();
  final HospitalVendorStorageService _storageService = HospitalVendorStorageService();

  Future<Response> registerHospital(Vendor vendor, HospitalProfile hospital) async {
    try {
      final requestBody = {
        'name': hospital.name,
        'gstNumber': hospital.gstNumber,
        'panNumber': hospital.panNumber,
        'address': hospital.address,
        'landmark': hospital.landmark,
        'ownerName': hospital.ownerName,
        'certifications': hospital.certifications,
        'licenses': hospital.licenses,
        'specialityTypes': hospital.specialityTypes,
        'servicesOffered': hospital.servicesOffered,
        'bedsAvailable': hospital.bedsAvailable,
        'doctors': hospital.doctors,
        'workingTime': hospital.workingTime,
        'workingDays': hospital.workingDays,
        'contactNumber': hospital.contactNumber,
        'email': hospital.email,
        'website': hospital.website,
        'hasLiftAccess': hospital.hasLiftAccess,
        'hasParking': hospital.hasParking,
        'providesAmbulanceService': hospital.providesAmbulanceService,
        'about': hospital.about,
        'hasWheelchairAccess': hospital.hasWheelchairAccess,
        'providesOnlineConsultancy': hospital.providesOnlineConsultancy,
        'feesRange': hospital.feesRange,
        'otherFacilities': hospital.otherFacilities,
        'insuranceCompanies': hospital.insuranceCompanies,
        'photos': hospital.photos,
        'state': hospital.state,
        'city': hospital.city,
        'pincode': hospital.pincode,
        'location': hospital.location,
        'panCardFile': hospital.panCardFile,
        'businessDocuments': hospital.businessDocuments,
        'vendor': {
          'vendorRole': 1,
          'phoneNumber': vendor.phoneNumber,
          'email': vendor.email,
          'password': vendor.password,
          'generatedId': vendor.generatedId,
        }
      };

      print("🔹 Register Request Data: ${jsonEncode(requestBody)}");

      final response = await _dio.post(
        ApiEndpoints.registerHospital,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Accept all status codes for debugging
        ),
        data: jsonEncode(requestBody),
      );

      print("✅ Register Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Register Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to register hospital: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      print("❌ Register DioException: ${e.message}");
      print("❌ Register Error Response: ${e.response?.data}");
      return _handleDioError(e);
    } catch (e) {
      print("❌ Register Exception: $e");
      rethrow;
    }
  }

  Future<HospitalProfile> getHospitalProfile(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getHospitalProfileById}/$vendorId',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      print("✅ Fetch Profile Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('hospital')) {
          final hospitalData = data['hospital'];
          
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
        } else {
          print("❌ Fetch Error: Hospital Profile data is missing");
          throw Exception("Hospital Profile data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch hospital profile: ${response.data}');
      }
    } on DioException catch (e) {
      print("❌ Fetch DioException: ${e.message}");
      print("❌ Fetch Error Response: ${e.response?.data}");
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  Future<Response> updateHospitalProfile(String vendorId, HospitalProfile hospital) async {
    try {
      // Log the input parameters
      print("🔹 Update Profile - Input Parameters:");
      print("🔹 Vendor ID: $vendorId");
      print("🔹 Hospital Data: ${hospital.toJson()}");

      // Prepare the request data
      final data = {
        'hospital': hospital.toJson(),
      };

      // Log the complete request data
      print("🔹 Update Request Data (Raw): $data");
      print("🔹 Update Request Data (JSON): ${jsonEncode(data)}");
      print("🔹 Update Endpoint: ${ApiEndpoints.updateHospitalProfile}/$vendorId");

      // Make the API call
      final response = await _dio.put(
        '${ApiEndpoints.updateHospitalProfile}/$vendorId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Accept all status codes for debugging
        ),
        data: jsonEncode(data),
      );

      // Log the complete response
      print("✅ Update Response Status: ${response.statusCode}");
      print("✅ Update Response Headers: ${response.headers}");
      print("✅ Update Response Data: ${response.data}");
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Update Error Details:");
        print("❌ Status Code: ${response.statusCode}");
        print("❌ Response Data: ${response.data}");
        print("❌ Response Headers: ${response.headers}");
        throw Exception('Failed to update hospital profile: ${response.data}');
      }

      print("✅ Update Successful!");
      return response;
    } on DioException catch (e) {
      print("❌ Update DioException Details:");
      print("❌ Error Message: ${e.message}");
      print("❌ Error Type: ${e.type}");
      print("❌ Error Response: ${e.response?.data}");
      print("❌ Error Status: ${e.response?.statusCode}");
      print("❌ Error Headers: ${e.response?.headers}");
      print("❌ Error Stack: ${e.stackTrace}");
      return _handleDioError(e);
    } catch (e, stackTrace) {
      print("❌ Update General Exception:");
      print("❌ Error: $e");
      print("❌ Stack Trace: $stackTrace");
      rethrow;
    }
  }

  Future<List<BedBooking>> getHospitalBookingsByVendor(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getHospitalBookingsByVendor}/$vendorId',
        options: Options(
          headers: {
          'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Fetch Bookings Response: ${response.statusCode}, Data: ${response.data}");

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
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  Future<Response> acceptAppointment(String bookingId) async {
    try {
      print("🔹 Accepting appointment with ID: $bookingId");
      
      final response = await _dio.put(
        '${ApiEndpoints.acceptAppointment}/$bookingId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("✅ Accept Appointment Response: ${response.statusCode}, Data: ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Accept Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to accept appointment: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      print("❌ Accept DioException: ${e.message}");
      print("❌ Accept Error Response: ${e.response?.data}");
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("❌ Accept Exception: $e");
      rethrow;
    }
  }

  Future<Response> notifyUserPayment(String bookingId) async {
    try {
      print("🔹 Notifying user about payment for booking ID: $bookingId");
      
      final response = await _dio.put(
       "${ ApiEndpoints.notifyUserPayment}/$bookingId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'bookingId': bookingId,
        },
      );

      print("✅ Notify Payment Response: ${response.statusCode}, Data: ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Notify Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to notify user: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      print("❌ Notify DioException: ${e.message}");
      print("❌ Notify Error Response: ${e.response?.data}");
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("❌ Notify Exception: $e");
      rethrow;
    }
  }

  Response _handleDioError(DioException e) {
    if (e.response != null) {
      print("❌ Dio Error Response: ${e.response?.data}");
      print("❌ Dio Error Status: ${e.response?.statusCode}");
      print("❌ Dio Error Headers: ${e.response?.headers}");
      return e.response!;
    } else {
      print("❌ Dio Network Error: ${e.message}");
      print("❌ Dio Error Type: ${e.type}");
      print("❌ Dio Error Stack: ${e.stackTrace}");
      throw Exception('Network error: ${e.message}');
    }
  }
} 