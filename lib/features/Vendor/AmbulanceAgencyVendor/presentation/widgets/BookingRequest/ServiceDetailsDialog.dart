import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/viewModal/AmbulanceBookingRequestViewModel.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ServiceDetailsDialog extends StatefulWidget {
  final AmbulanceBookingRequestViewModel viewModel;
  final String requestId;

  const ServiceDetailsDialog({super.key, required this.viewModel, required this.requestId});

  @override
  State<ServiceDetailsDialog> createState() => _ServiceDetailsDialogState();
}

class _ServiceDetailsDialogState extends State<ServiceDetailsDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.medical_services, color: Colors.cyan, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Service Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Locations
              _buildSectionTitle("Locations"),
              _buildTextField(widget.viewModel.pickupLocationController, "Pickup Location"),
              _buildTextField(widget.viewModel.dropLocationController, "Drop Location"),

              // Fare Details
              _buildSectionTitle("Fare Details"),
              _buildNumberField(widget.viewModel.totalDistanceController, "Total Distance (km)"),
              _buildNumberField(widget.viewModel.costPerKmController, "Cost per KM"),
              _buildNumberField(widget.viewModel.baseChargeController, "Base Charge"),

              // Vehicle Type
              _buildSectionTitle("Vehicle Type"),
              DropdownButtonFormField<String>(
                value: widget.viewModel.vehicleTypes.contains(widget.viewModel.selectedVehicleType)
                    ? widget.viewModel.selectedVehicleType
                    : widget.viewModel.vehicleTypes.isNotEmpty ? widget.viewModel.vehicleTypes.first : null,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: widget.viewModel.vehicleTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.viewModel.setSelectedVehicleType(newValue);
                  }
                },
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      label: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        final success = await widget.viewModel.addOrUpdateServiceDetails(widget.requestId);
                        if (context.mounted) {
                          setState(() => _isLoading = false);
                          if (success) {
                            Navigator.pop(context, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Success!',
                                  message: 'Service details have been sent to the user.',
                                  contentType: ContentType.success,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Error!',
                                  message: 'Failed to send service details. Please try again.',
                                  contentType: ContentType.failure,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.notifications_active),
                      label: Text(_isLoading ? "Sending..." : "Notify to User"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- UI Helpers -----------------

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.cyan,
          ),
        ),
      ),
    );
  }
}
