import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/view/AddNewAddressScreen.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';
import 'package:provider/provider.dart';

class ChooseAddressSheet extends StatefulWidget {
  final VoidCallback onAddressConfirmed;

  const ChooseAddressSheet({Key? key, required this.onAddressConfirmed}) : super(key: key);

  @override
  _ChooseAddressSheetState createState() => _ChooseAddressSheetState();
}

class _ChooseAddressSheetState extends State<ChooseAddressSheet> {
  bool showAddressList = false;
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Load addresses when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  void _loadAddresses() {
    final viewModel = Provider.of<AddNewAddressViewModel>(context, listen: false);
    viewModel.getAllAddresses().then((_) {
      if (viewModel.addresses.isNotEmpty) {
        setState(() {
          selectedAddressId = viewModel.addresses.first.addressId;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddNewAddressViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(viewModel),
              const SizedBox(height: 10),
              showAddressList ? _buildAddressList(viewModel) : _buildSelectedAddress(viewModel),
              const SizedBox(height: 10),
              _buildConfirmButton(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AddNewAddressViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Choose Delivery Address",
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () => _navigateToAddNewAddress(viewModel),
          icon: Icon(Icons.add_location_alt, color: ColorPalette.primaryColor),
          label: Text(
            "Add New",
            style: TextStyle(color: ColorPalette.primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedAddress(AddNewAddressViewModel viewModel) {
    if (viewModel.addresses.isEmpty) {
      return _buildNoAddressView(viewModel);
    }

    final selectedAddress = viewModel.addresses.firstWhere(
          (address) => address.addressId == selectedAddressId,
      orElse: () => viewModel.addresses.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: ColorPalette.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${selectedAddress.houseStreet}, ${selectedAddress.city}, ${selectedAddress.state}",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => showAddressList = true),
            child: Text(
              "Change",
              style: TextStyle(color: ColorPalette.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(AddNewAddressViewModel viewModel) {
    return Column(
      children: viewModel.addresses.map((address) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAddressId = address.addressId;
              showAddressList = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selectedAddressId == address.addressId
                  ? ColorPalette.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedAddressId == address.addressId
                    ? ColorPalette.primaryColor
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Radio(
                  value: address.addressId,
                  groupValue: selectedAddressId,
                  onChanged: (value) {
                    setState(() {
                      selectedAddressId = value as String?;
                      showAddressList = false;
                    });
                  },
                  activeColor: ColorPalette.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${address.houseStreet}, ${address.city}, ${address.state}",
                    style: GoogleFonts.openSans(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAddress(viewModel, address.addressId!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton(AddNewAddressViewModel viewModel) {
    bool hasAddresses = viewModel.addresses.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasAddresses && selectedAddressId != null
            ? widget.onAddressConfirmed
            : () => _navigateToAddNewAddress(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          hasAddresses
              ? (selectedAddressId != null ? "Confirm Address" : "Select Address")
              : "Add New Address",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNoAddressView(AddNewAddressViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_off, size: 50, color: Colors.grey),
        const SizedBox(height: 10),
        const Text("No address added click to Add new",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _navigateToAddNewAddress(AddNewAddressViewModel viewModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNewAddressScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final success = result['success'];
      final message = result['message'];

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: success ? ColorPalette.primaryColor : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (success) {
        // Reload addresses after adding new one
        await viewModel.getAllAddresses();
        if (viewModel.addresses.isNotEmpty) {
          setState(() {
            selectedAddressId = viewModel.addresses.last.addressId;
          });
        }
      }
    }
  }

  Future<void> _deleteAddress(AddNewAddressViewModel viewModel, String addressId) async {
    try {
      await viewModel.deleteAddress(addressId);
      Fluttertoast.showToast(
        msg: "Address deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: ColorPalette.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Reload addresses after deletion
      await viewModel.getAllAddresses();
      if (viewModel.addresses.isNotEmpty) {
        setState(() {
          selectedAddressId = viewModel.addresses.first.addressId;
        });
      } else {
        setState(() {
          selectedAddressId = null;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete address: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}