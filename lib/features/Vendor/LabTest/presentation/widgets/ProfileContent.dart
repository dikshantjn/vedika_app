import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/LabTestColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({Key? key}) : super(key: key);

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers for all fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _businessTimingsController = TextEditingController();
  final TextEditingController _homeCollectionGeoLimitController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _nearbyLandmarkController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _mainContactNumberController = TextEditingController();
  final TextEditingController _emergencyContactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Other state variables
  String _sampleCollectionMethod = 'Both';
  List<String> _testTypes = [];
  List<String> _businessDays = [];
  List<String> _languagesSpoken = [];
  bool _emergencyHandlingFastTrack = false;
  bool _parkingAvailable = false;
  bool _wheelchairAccess = false;
  bool _liftAccess = false;
  bool _ambulanceServiceAvailable = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProfileForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: LabTestColorPalette.textPrimary,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing 
                ? LabTestColorPalette.primaryBlue 
                : LabTestColorPalette.secondaryTeal,
            foregroundColor: LabTestColorPalette.textWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isEditing ? Icons.save : Icons.edit,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isEditing ? 'Save Changes' : 'Edit Profile',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information'),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Center Name',
            controller: _nameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'GST Number',
            controller: _gstNumberController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'PAN Number',
            controller: _panNumberController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Owner Name',
            controller: _ownerNameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Main Contact Number',
            controller: _mainContactNumberController,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Emergency Contact Number',
            controller: _emergencyContactNumberController,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Website',
            controller: _websiteController,
            enabled: _isEditing,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Location Details'),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Address',
            controller: _addressController,
            enabled: _isEditing,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'State',
            controller: _stateController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'City',
            controller: _cityController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Pincode',
            controller: _pincodeController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Nearby Landmark',
            controller: _nearbyLandmarkController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Floor',
            controller: _floorController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Business Details'),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Business Timings',
            controller: _businessTimingsController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Home Collection Geo Limit',
            controller: _homeCollectionGeoLimitController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Sample Collection Method',
            value: _sampleCollectionMethod,
            items: ['At Center', 'At Home', 'Both'],
            enabled: _isEditing,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sampleCollectionMethod = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Facilities'),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Parking Available',
            value: _parkingAvailable,
            enabled: _isEditing,
            onChanged: (value) {
              setState(() {
                _parkingAvailable = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Wheelchair Access',
            value: _wheelchairAccess,
            enabled: _isEditing,
            onChanged: (value) {
              setState(() {
                _wheelchairAccess = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Lift Access',
            value: _liftAccess,
            enabled: _isEditing,
            onChanged: (value) {
              setState(() {
                _liftAccess = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Ambulance Service Available',
            value: _ambulanceServiceAvailable,
            enabled: _isEditing,
            onChanged: (value) {
              setState(() {
                _ambulanceServiceAvailable = value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Emergency Handling Fast Track',
            value: _emergencyHandlingFastTrack,
            enabled: _isEditing,
            onChanged: (value) {
              setState(() {
                _emergencyHandlingFastTrack = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: LabTestColorPalette.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: LabTestColorPalette.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.borderLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.primaryBlue,
            ),
          ),
          filled: true,
          fillColor: enabled 
              ? LabTestColorPalette.backgroundPrimary 
              : LabTestColorPalette.backgroundCard,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required bool enabled,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: LabTestColorPalette.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.borderLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.borderLight,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: LabTestColorPalette.primaryBlue,
            ),
          ),
          filled: true,
          fillColor: enabled 
              ? LabTestColorPalette.backgroundPrimary 
              : LabTestColorPalette.backgroundCard,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required bool enabled,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: LabTestColorPalette.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: LabTestColorPalette.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: LabTestColorPalette.textPrimary,
            fontSize: 16,
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: LabTestColorPalette.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _ownerNameController.dispose();
    _businessTimingsController.dispose();
    _homeCollectionGeoLimitController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _nearbyLandmarkController.dispose();
    _floorController.dispose();
    _mainContactNumberController.dispose();
    _emergencyContactNumberController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }
} 