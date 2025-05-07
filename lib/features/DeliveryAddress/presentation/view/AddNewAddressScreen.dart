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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ColorPalette.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Address",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Address Details"),
                const SizedBox(height: 16),
                _buildTextField(
                  "House & Street",
                  viewModel.houseStreetController,
                  icon: Icons.home_outlined,
                ),
                _buildTextField(
                  "Address Line 1",
                  viewModel.addressLine1Controller,
                  icon: Icons.location_on_outlined,
                ),
                _buildTextField(
                  "Address Line 2 (Optional)",
                  viewModel.addressLine2Controller,
                  icon: Icons.add_location_alt_outlined,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Location Details"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "City",
                        viewModel.cityController,
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        "State",
                        viewModel.stateController,
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Zip Code",
                        viewModel.zipCodeController,
                        keyboardType: TextInputType.number,
                        icon: Icons.pin_drop_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        "Country",
                        viewModel.countryController,
                        icon: Icons.public_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle("Address Type"),
                const SizedBox(height: 16),
                _buildAddressTypeSelector(viewModel),
                const SizedBox(height: 32),
                _buildSaveButton(viewModel, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: ColorPalette.primaryColor, size: 20)
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorPalette.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector(AddNewAddressViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonFormField<String>(
        value: viewModel.selectedAddressType,
        items: ["Home", "Office", "Other"].map((String type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(
                  type == "Home"
                      ? Icons.home_outlined
                      : type == "Office"
                          ? Icons.work_outline
                          : Icons.location_on_outlined,
                  color: ColorPalette.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          viewModel.setAddressType(value!);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.keyboard_arrow_down, color: ColorPalette.primaryColor),
      ),
    );
  }

  Widget _buildSaveButton(AddNewAddressViewModel viewModel, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorPalette.primaryColor,
            ColorPalette.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (viewModel.validateForm()) {
              try {
                await viewModel.saveAddress();
                DeliveryAddressModel newAddress = await viewModel.getAddressData();
                Navigator.pop(context, {'success': true, 'message': 'Address saved successfully!'});
              } catch (e) {
                Navigator.pop(context, {'success': false, 'message': 'Failed to save address. Please try again.'});
              }
            } else {
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
          child: Center(
            child: Text(
              "Save Address",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
