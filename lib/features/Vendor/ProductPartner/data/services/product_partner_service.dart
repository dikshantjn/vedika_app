import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/product_partner_model.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class ProductPartnerService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  final Dio _dio = Dio();

  Future<Map<String, dynamic>> registerProductPartner(
    ProductPartner productPartner,
    Vendor vendor,
  ) async {
    try {
      _logger.i('Starting product partner registration process...');

      // Validate required fields
      if (productPartner.companyLegalName.isEmpty ||
          productPartner.brandName.isEmpty ||
          productPartner.email.isEmpty ||
          productPartner.password.isEmpty ||
          productPartner.gstNumber.isEmpty ||
          productPartner.panCardNumber.isEmpty ||
          productPartner.address.isEmpty ||
          productPartner.state.isEmpty ||
          productPartner.city.isEmpty ||
          productPartner.pincode.isEmpty ||
          productPartner.location.isEmpty ||
          productPartner.bankAccountNumber.isEmpty ||
          productPartner.licenseDetails.isEmpty) {
        _logger.e('Validation failed: Required fields are missing');
        throw Exception('Please fill in all required fields');
      }

      // Prepare request body
      final requestBody = {
        'vendor': vendor.toJson(),
        'productPartner': productPartner.toJson(),
      };

      // Log the registration data
      _logger.i('Sending registration request with data: ${requestBody.toString()}');

      // Make API call
      final response = await _dio.post(
        ApiEndpoints.registerProductPartner,
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Registration successful! Response: ${response.data.toString()}');
        return response.data;
      } else {
        _logger.e('Registration failed with status code: ${response.statusCode}');
        _logger.e('Error message: ${response.statusMessage}');
        throw Exception('Failed to register product partner: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _logger.e('Network error occurred during registration');
      if (e.response != null) {
        _logger.e('Error response from server: ${e.response?.data.toString()}');
        final errorMessage = e.response?.data['message'] ?? 'Failed to register product partner';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        _logger.e('Connection timeout');
        throw Exception('Connection timeout. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        _logger.e('Receive timeout');
        throw Exception('Server response timeout. Please try again.');
      } else {
        _logger.e('Dio error: ${e.message}');
        throw Exception('Network error occurred. Please try again.');
      }
    } catch (e) {
      _logger.e('Unexpected error during registration: ${e.toString()}');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
} 