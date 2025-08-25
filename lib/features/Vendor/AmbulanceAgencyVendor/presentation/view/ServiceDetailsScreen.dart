import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final AmbulanceBookingRequestViewModel viewModel;
  final String requestId;

  const ServiceDetailsScreen({super.key, required this.viewModel, required this.requestId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize bypass payment values if they exist
    final booking = widget.viewModel.bookingRequests
        .where((b) => b.requestId == widget.requestId)
        .firstOrNull;
    
    if (booking != null) {
      widget.viewModel.setPaymentBypassed(booking.isPaymentBypassed);
      if (booking.isPaymentBypassed) {
        widget.viewModel.bypassReasonController.text = booking.bypassReason ?? '';
        widget.viewModel.bypassApprovedByController.text = booking.bypassApprovedBy ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        elevation: 0,
        title: const Text(
          'Service Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Locations Section
              _buildSectionTitle("Locations", Icons.location_on_outlined),
              _buildTextField(
                widget.viewModel.pickupLocationController,
                "Pickup Location",
                prefixIcon: Icons.my_location,
              ),
              _buildTextField(
                widget.viewModel.dropLocationController,
                "Drop Location",
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 24),

              // Payment Bypass Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: widget.viewModel.isPaymentBypassed,
                          onChanged: (value) {
                            setState(() {
                              widget.viewModel.setPaymentBypassed(value ?? false);
                            });
                          },
                          activeColor: ColorPalette.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Waive Payment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Enable this option only for patients who are unable to pay. This will waive all charges for the service.",
                                style: TextStyle(
                                  fontSize: 12,
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
              const SizedBox(height: 24),

              // Conditional Sections based on Payment Bypass
              if (widget.viewModel.isPaymentBypassed) ...[
                _buildSectionTitle("Payment Waive Details", Icons.note_alt),
                _buildTextField(
                  widget.viewModel.bypassReasonController,
                  "Reason for Waive",
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                _buildTextField(
                  widget.viewModel.bypassApprovedByController,
                  "Approved By",
                  prefixIcon: Icons.person,
                ),
              ] else ...[
                // Fare Details Section
                _buildSectionTitle("Fare Details", Icons.currency_rupee),
                _buildNumberField(
                  widget.viewModel.totalDistanceController,
                  "Total Distance (km)",
                  prefixIcon: Icons.route,
                ),
                _buildNumberField(
                  widget.viewModel.costPerKmController,
                  "Cost per KM",
                  prefixIcon: Icons.attach_money,
                ),
                _buildNumberField(
                  widget.viewModel.baseChargeController,
                  "Base Charge",
                  prefixIcon: Icons.price_change,
                ),
              ],
              const SizedBox(height: 24),

              // Vehicle Type Section
              _buildSectionTitle("Vehicle Type", Icons.local_taxi),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonFormField<String>(
                  value: widget.viewModel.selectedVehicleType != null && 
                         widget.viewModel.vehicleTypes.contains(widget.viewModel.selectedVehicleType)
                      ? widget.viewModel.selectedVehicleType
                      : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_car, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Select Vehicle Type',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...widget.viewModel.vehicleTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        widget.viewModel.setSelectedVehicleType(newValue);
                      });
                    }
                  },
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (widget.viewModel.selectedVehicleType == null || widget.viewModel.selectedVehicleType!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: const Text('Please select a vehicle type'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate bypass fields if payment is bypassed
                  if (widget.viewModel.isPaymentBypassed) {
                    if (widget.viewModel.bypassReasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: const Text('Please provide a reason for payment bypass'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (widget.viewModel.bypassApprovedByController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: const Text('Please provide the name of person who approved the bypass'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }
                  
                  setState(() => _isLoading = true);
                  final success = await widget.viewModel.addOrUpdateServiceDetails(widget.requestId);
                  if (context.mounted) {
                    setState(() => _isLoading = false);
                    if (success) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            widget.viewModel.isPaymentBypassed 
                              ? 'Service details updated with payment bypass'
                              : 'Service details have been updated successfully'
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: const Text('Failed to update service details. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorPalette.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.notifications_active, size: 20),
                    const SizedBox(width: 8),
                    Text(_isLoading ? "Sending..." : "Notify User"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPalette.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: ColorPalette.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 20) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label, {IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 20) : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
} 