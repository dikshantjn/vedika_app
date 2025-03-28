import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/service/DeliveryAddressService.dart';

class AddNewAddressViewModel extends ChangeNotifier {
  final TextEditingController houseStreetController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String selectedAddressType = "Home"; // Default
  final DeliveryAddressService _deliveryAddressService = DeliveryAddressService();

  bool isLoading = false;
  String? errorMessage;
  List<DeliveryAddressModel> addresses = [];

  // Set Address Type
  void setAddressType(String type) {
    selectedAddressType = type;
    notifyListeners();
  }

  bool validateForm() {
    return houseStreetController.text.isNotEmpty &&
        addressLine1Controller.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        zipCodeController.text.isNotEmpty &&
        countryController.text.isNotEmpty;
  }

  Future<DeliveryAddressModel> getAddressData() async {
    String? userId = await StorageService.getUserId();

    return DeliveryAddressModel(
      userId: userId,
      houseStreet: houseStreetController.text,
      addressLine1: addressLine1Controller.text,
      addressLine2: addressLine2Controller.text.isEmpty ? null : addressLine2Controller.text,
      city: cityController.text,
      state: stateController.text,
      zipCode: zipCodeController.text,
      country: countryController.text,
      addressType: selectedAddressType,
    );
  }

  Future<void> saveAddress() async {
    if (validateForm()) {
      try {
        isLoading = true;
        errorMessage = null; // Clear any previous errors
        notifyListeners();

        // Get the address data from the form (now await the asynchronous call)
        DeliveryAddressModel address = await getAddressData();

        // Call the service to save the address
        await _deliveryAddressService.saveAddress(address);

        // If successful, reset the loading state
        isLoading = false;
        notifyListeners();

        // Optionally, you can display a success message here or navigate to another screen
        print("Address saved successfully!");

        // Reset the form fields after saving the address
        resetForm();

      } catch (e) {
        isLoading = false;
        errorMessage = "Error saving address: $e"; // Set the error message
        notifyListeners();
      }
    } else {
      errorMessage = "Form is not valid. Please fill all required fields.";
      notifyListeners();
    }
  }

  // Reset form fields to their initial state
  void resetForm() {
    houseStreetController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    zipCodeController.clear();
    countryController.clear();
    selectedAddressType = "Home"; // Reset address type to default
    notifyListeners();
  }

  Future<void> getAllAddresses() async {
    try {
      String? userId = await StorageService.getUserId();
      print("Fetched UserId: $userId"); // Log userId

      if (userId != null) {
        isLoading = true;
        notifyListeners();

        // Call the service to get all addresses
        List<DeliveryAddressModel> fetchedAddresses = await _deliveryAddressService.getAllAddressesByUserId(userId);

        // Store the fetched addresses and stop loading
        addresses = fetchedAddresses;
        print("Fetched Addresses: $addresses"); // Log the fetched addresses
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = "User ID is not available.";
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Error fetching addresses: $e";
      isLoading = false;
      notifyListeners();
      print("Error in getAllAddresses: $e"); // Log the error
    }
  }


  // New method to delete an address by index
  Future<void> deleteAddress(String addressId) async {
    try {

      // Call the service to delete the address from the backend
      await _deliveryAddressService.deleteAddress(addressId);

      // Update the UI state
      notifyListeners();

      // Optionally, show a success message or toast
      print("Address deleted successfully!");
    } catch (e) {
      errorMessage = "Error deleting address: $e";
      notifyListeners();
    }
  }
}
