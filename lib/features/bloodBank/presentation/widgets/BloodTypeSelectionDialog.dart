import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankAgencyService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:io';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart' show OrderHistoryNavigation;

import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodRequestDetailsBottomSheet.dart';

class BloodTypeSelectionDialog extends StatefulWidget {
  final List<String>? selectedBloodTypes;
  final Function(List<String>) onBloodTypesSelected;
  final Function(String)? onPrescriptionSelected;
  final VoidCallback? onRequestConfirm;
  final String? customerName;
  final int units;

  const BloodTypeSelectionDialog({
    Key? key,
    required this.selectedBloodTypes,
    required this.onBloodTypesSelected,
    this.onPrescriptionSelected,
    this.onRequestConfirm,
    this.customerName,
    this.units = 1,
  }) : super(key: key);

  @override
  _BloodTypeSelectionDialogState createState() => _BloodTypeSelectionDialogState();
}

class _BloodTypeSelectionDialogState extends State<BloodTypeSelectionDialog> {
  List<String> _selectedBloodTypes = [];
  String? _uploadedFileName;
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isRequestSent = false;
  String? _errorMessage;
  File? _prescriptionFile;
  final BloodBankAgencyService _bloodBankService = BloodBankAgencyService();
  Position? _currentPosition;
  Map<String, dynamic>? _response;

  @override
  void initState() {
    super.initState();
    _selectedBloodTypes = widget.selectedBloodTypes ?? [];
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isSubmitting = true; // Show loading state while getting location
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        // Use a default location instead of showing an error
        if (mounted) {
          setState(() {
            _currentPosition = Position(
              latitude: 0.0,
              longitude: 0.0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _isSubmitting = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          // Use a default location instead of showing an error
          if (mounted) {
            setState(() {
              _currentPosition = Position(
                latitude: 0.0,
                longitude: 0.0,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              );
              _isSubmitting = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        // Use a default location instead of showing an error
        if (mounted) {
          setState(() {
            _currentPosition = Position(
              latitude: 0.0,
              longitude: 0.0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _isSubmitting = false;
          });
        }
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        );
        
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isSubmitting = false;
            _errorMessage = null;
          });
        }
      } catch (e) {
        print('Error getting precise location: $e');
        // Use a default location as fallback
        if (mounted) {
          setState(() {
            _currentPosition = Position(
              latitude: 0.0,
              longitude: 0.0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      print('Error in location service: $e');
      // Use a default location as fallback
      if (mounted) {
        setState(() {
          _currentPosition = Position(
            latitude: 0.0,
            longitude: 0.0,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          _isSubmitting = false;
        });
      }
    }
  }

  void _navigateToMyOrders(BuildContext context) {
    // Close the current dialog first
    Navigator.pop(context);
    
    // Set bridge for MainScreen-integrated OrderHistory
    OrderHistoryNavigation.initialTab = 4; // Blood Bank tab index
    Navigator.pushNamed(
      context,
      AppRoutes.orderHistory,
      arguments: {'initialTab': 4}, // Blood Bank tab index
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _uploadedFileName = result.files.single.name;
          _prescriptionFile = File(result.files.single.path!);
          _isUploading = false;
        });

        // Trigger onPrescriptionSelected callback
        widget.onPrescriptionSelected?.call(result.files.single.name);
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      print('Error uploading file: $e'); // Log the error
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error uploading file. Please try again.';
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedBloodTypes.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one blood type';
      });
      return;
    }

    if (_prescriptionFile == null) {
      setState(() {
        _errorMessage = 'Please upload a prescription';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Upload prescription first
      final prescriptionUrl = await _bloodBankService.uploadPrescription(_prescriptionFile!);
      print('Prescription uploaded successfully: $prescriptionUrl');

      // Send blood request
      print('Sending blood request...');
      final response = await _bloodBankService.sendBloodRequest(
        customerName: widget.customerName ?? 'Anonymous',
        bloodTypes: _selectedBloodTypes,
        units: widget.units,
        prescriptionUrls: [prescriptionUrl],
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
      );

      print('Blood request response: $response');
      _response = response;

      // Check for success in the nested error object
      if (response['error'] != null && response['error']['success'] == true) {
        // Request was successful
        if (mounted) {
          setState(() {
            _isRequestSent = true;
            _isSubmitting = false;
            _errorMessage = null; // Clear any error messages
          });
          
          // Call the onRequestConfirm callback if provided
          widget.onRequestConfirm?.call();
        }
      } else {
        // Request failed
        if (mounted) {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to send blood request';
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      print('Error submitting request: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred while submitting the request';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            height: 5,
            width: 50,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          // Title Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bloodtype,
                        color: ColorPalette.primaryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Blood Types",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Choose the blood types you need",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToMyOrders(context),
                    icon: Icon(Icons.history, size: 16),
                    label: Text("My Orders"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.primaryColor,
                      side: BorderSide(color: ColorPalette.primaryColor),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Blood Type Selection Grid
          Container(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"].map((bloodType) {
                final isSelected = _selectedBloodTypes.contains(bloodType);
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 70,
                  height: 40,
                  child: Material(
                    color: isSelected ? ColorPalette.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: isSelected ? 2 : 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedBloodTypes.remove(bloodType);
                          } else {
                            _selectedBloodTypes.add(bloodType);
                          }
                        });
                        widget.onBloodTypesSelected(_selectedBloodTypes);
                      },
                      child: Center(
                        child: Text(
                          bloodType,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Prescription Upload Section
          if (_selectedBloodTypes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Prescription",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: _isUploading ? null : _pickFile,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _uploadedFileName != null
                              ? Colors.green.withOpacity(0.5)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_isUploading)
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
                            )
                          else if (_uploadedFileName != null)
                            Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _uploadedFileName!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Tap to change file",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  color: ColorPalette.primaryColor,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tap to upload prescription",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "PDF, JPG, PNG (max 5MB)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error Message
          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Submitting..."),
                            ],
                          )
                        : Text("Submit Request"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
