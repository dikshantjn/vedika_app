import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankAgencyService.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:io';

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
    // Fetch location immediately
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _isRequestSent
                ? [
                    // Modern Success State
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      "Request Sent Successfully!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Request Status",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Please wait while blood banks review your request. We will notify you once a blood bank accepts your request.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.done, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Close",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                : [
                    // Original form content
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorPalette.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bloodtype,
                        color: ColorPalette.primaryColor,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Select Blood Types",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You can select multiple blood types for your request",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
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
                    SizedBox(height: 24),
                    if (_selectedBloodTypes.isNotEmpty) ...[
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
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Container(
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
                    ],
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                                  ],
                                )
                              : Text("Submit Request"),
                        ),
                      ],
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
