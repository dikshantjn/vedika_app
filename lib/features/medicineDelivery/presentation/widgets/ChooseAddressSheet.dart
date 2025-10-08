import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/view/AddNewAddressScreen.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/presentation/viewModal/AddNewAddressViewModel.dart';
import 'package:provider/provider.dart';

class ChooseAddressSheet extends StatefulWidget {
  const ChooseAddressSheet({Key? key}) : super(key: key);

  @override
  _ChooseAddressSheetState createState() => _ChooseAddressSheetState();
}

class _ChooseAddressSheetState extends State<ChooseAddressSheet> {
  bool showAddressList = false;
  String? selectedAddressId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  void _loadAddresses() async {
    setState(() {
      isLoading = true;
    });
    
    final viewModel = Provider.of<AddNewAddressViewModel>(context, listen: false);
    await viewModel.getAllAddresses();
    
    if (viewModel.addresses.isNotEmpty) {
      setState(() {
        selectedAddressId = viewModel.addresses.first.addressId;
        print('DEBUG: Initialized selectedAddressId to: $selectedAddressId');
      });
    }
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddNewAddressViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(viewModel),
              const SizedBox(height: 20),
              isLoading 
                ? _buildLoadingView() 
                : (showAddressList ? _buildAddressList(viewModel) : _buildSelectedAddress(viewModel)),
              const SizedBox(height: 20),
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
        Expanded(
          child: Text(
            "Choose Address",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: ColorPalette.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton.icon(
            onPressed: () => _navigateToAddNewAddress(viewModel),
            icon: Icon(Icons.add_location_alt, color: ColorPalette.primaryColor, size: 20),
            label: Text(
              "Add New",
              style: GoogleFonts.poppins(
                color: ColorPalette.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getAddressType(selectedAddress),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => showAddressList = true),
                child: Text(
                  "Change",
                  style: GoogleFonts.poppins(
                    color: ColorPalette.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: ColorPalette.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedAddress.houseStreet,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${selectedAddress.city}, ${selectedAddress.state} - ${selectedAddress.zipCode}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(AddNewAddressViewModel viewModel) {
    return Column(
      children: viewModel.addresses.map((address) {
        final isSelected = selectedAddressId == address.addressId;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? ColorPalette.primaryColor.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? ColorPalette.primaryColor : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                print('DEBUG: Selecting address with ID: ${address.addressId}');
                setState(() {
                  selectedAddressId = address.addressId;
                  showAddressList = false;
                });
                print('DEBUG: selectedAddressId is now: $selectedAddressId');
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ColorPalette.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getAddressType(address),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                          onPressed: () => _deleteAddress(viewModel, address.addressId!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: ColorPalette.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.houseStreet,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${address.city}, ${address.state} - ${address.zipCode}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton(AddNewAddressViewModel viewModel) {
    bool hasAddresses = viewModel.addresses.isNotEmpty;

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
          onTap: hasAddresses && selectedAddressId != null
              ? () {
                  Navigator.pop(context, selectedAddressId);
                }
              : () => _navigateToAddNewAddress(viewModel),
          child: Center(
            child: Text(
              hasAddresses
                  ? (selectedAddressId != null ? "Confirm Address" : "Select Address")
                  : "Add New Address",
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

  Widget _buildNoAddressView(AddNewAddressViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off,
              size: 40,
              color: ColorPalette.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Address Added",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add a new address to continue",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading addresses...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getAddressType(DeliveryAddressModel address) {
    // You can customize this based on your address type logic
    if (address.houseStreet.toLowerCase().contains('home')) {
      return 'Home';
    } else if (address.houseStreet.toLowerCase().contains('work')) {
      return 'Work';
    } else {
      return 'Other';
    }
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