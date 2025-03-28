import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';

class DeliveryAddressService {
  final Dio _dio = Dio();

  // Save delivery address
  Future<void> saveAddress(DeliveryAddressModel address) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.deliveryAddress,  // API endpoint for saving address
        data: address.toJson(),  // Convert your DeliveryAddressModel to JSON
      );
      // Handle the response if needed (e.g., show success message)
      print('Address saved successfully: ${response.data}');
    } catch (e) {
      throw Exception('Error saving address: $e');
    }
  }

  Future<List<DeliveryAddressModel>> getAllAddressesByUserId(String userId) async {
    try {
      // Log the API endpoint and userId for debugging purposes
      print("Fetching addresses for userId: $userId");
      final String endpoint = '${ApiEndpoints.getDeliveryAddresses}/$userId';
      print("API Endpoint: $endpoint");

      final response = await _dio.get(endpoint);

      // Log the status code and response data for debugging
      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Ensure response.data is a Map
        final Map<String, dynamic> responseData = response.data;

        // Check if 'data' is available and contains a list of addresses
        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> data = responseData['data']; // Extract the list of addresses
          List<DeliveryAddressModel> addresses = data.map((addressJson) {
            print("Parsing address: $addressJson");  // Log each address JSON data
            return DeliveryAddressModel.fromJson(addressJson); // Convert JSON to model
          }).toList();

          return addresses;  // Return the list of addresses
        } else {
          // Log the error if 'data' is not found or is not a list
          print("Failed to load addresses. 'data' is missing or not a list.");
          throw Exception('Failed to load addresses');
        }
      } else {
        // Log the error if status code is not 200
        print("Failed to load addresses. Status code: ${response.statusCode}");
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      // Log the error message and the error itself
      print("Error fetching addresses: $e");
      throw Exception('Error fetching addresses: $e');
    }
  }


  // Delete a delivery address by its ID
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteDeliveryAddress}/$addressId',  // API endpoint for deleting address
      );

      // Handle the response if needed
      if (response.statusCode == 200) {
        print('Address deleted successfully: ${response.data}');
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }
}
