import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddNewAddressViewModel>(context);

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Add New Address",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: ColorPalette.whiteColor,
          ),
        ),
        backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        elevation: 3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: SingleChildScrollView(  // Wrap the Column in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              _buildTextField("House & Street", viewModel.houseStreetController),
              _buildTextField("Address Line 1", viewModel.addressLine1Controller),
              _buildTextField("Address Line 2 (Optional)", viewModel.addressLine2Controller),
              _buildTextField("City", viewModel.cityController),
              _buildTextField("State", viewModel.stateController),
              _buildTextField("Zip Code", viewModel.zipCodeController, keyboardType: TextInputType.number),
              _buildTextField("Country", viewModel.countryController),

              const SizedBox(height: 12),
              Text(
                "Address Type:",
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: ColorPalette.textColor2),
              ),
              const SizedBox(height: 6),
              _buildAddressTypeDropdown(viewModel),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (viewModel.validateForm()) {
                      try {
                        await viewModel.saveAddress();
                        DeliveryAddressModel newAddress = await viewModel.getAddressData();

                        // Send the success message back
                        Navigator.pop(context, {'success': true, 'message': 'Address saved successfully!'});
                      } catch (e) {
                        // Send the failure message back
                        Navigator.pop(context, {'success': false, 'message': 'Failed to save address. Please try again.'});
                      }
                    } else {
                      // Show a validation failure message but do not pop
                      Fluttertoast.showToast(
                        msg: 'Please fill in all required fields.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.orange,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Text(
                    "Save Address",
                    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Modern Text Field with Grey Border & Padding**
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(fontSize: 14, color: ColorPalette.textColor2),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(fontSize: 14, color: ColorPalette.textColor),
          filled: true,
          fillColor: ColorPalette.whiteColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  /// **Modern Dropdown with Styled UI**
  Widget _buildAddressTypeDropdown(AddNewAddressViewModel viewModel) {
    return DropdownButtonFormField<String>(
      value: viewModel.selectedAddressType,
      items: ["Home", "Office", "Other"].map((String type) {
        return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.montserrat(fontSize: 14, color: ColorPalette.textColor2)));
      }).toList(),
      onChanged: (value) {
        viewModel.setAddressType(value!);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorPalette.whiteColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorPalette.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorPalette.primaryColor, width: 2),
        ),
      ),
      style: GoogleFonts.montserrat(fontSize: 14, color: ColorPalette.textColor2),
      dropdownColor: ColorPalette.whiteColor,
    );
  }
}
