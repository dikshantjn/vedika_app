import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/HospitalVendorColorPalette.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Ward.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/WardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/HospitalDashboardViewModel.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/ViewModels/AddEditWardViewModel.dart';

class AddEditWardDetailsScreen extends StatefulWidget {
  final Ward? ward;

  const AddEditWardDetailsScreen({Key? key, this.ward}) : super(key: key);

  @override
  _AddEditWardDetailsScreenState createState() => _AddEditWardDetailsScreenState();
}

class _AddEditWardDetailsScreenState extends State<AddEditWardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wardTypeController = TextEditingController();
  final _totalBedsController = TextEditingController();
  final _availableBedsController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _genderRestriction = 'None';
  bool _isAC = false;
  bool _hasAttachedBathroom = false;
  bool _isIsolation = false;
  List<String> _facilities = [];

  late final AddEditWardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddEditWardViewModel();
    
    if (widget.ward != null) {
      _nameController.text = widget.ward!.name;
      _wardTypeController.text = widget.ward!.wardType;
      _totalBedsController.text = widget.ward!.totalBeds.toString();
      _availableBedsController.text = widget.ward!.availableBeds.toString();
      _priceController.text = widget.ward!.pricePerDay.toString();
      _descriptionController.text = widget.ward!.description;
      _genderRestriction = widget.ward!.genderRestriction;
      _isAC = widget.ward!.isAC;
      _hasAttachedBathroom = widget.ward!.hasAttachedBathroom;
      _isIsolation = widget.ward!.isIsolation;
      _facilities = List.from(widget.ward!.facilities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wardTypeController.dispose();
    _totalBedsController.dispose();
    _availableBedsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddEditWardViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.ward == null ? 'Add New Ward' : 'Edit Ward Details',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: HospitalVendorColorPalette.primaryBlue,
            actions: [
              if (!viewModel.isLoading)
                TextButton.icon(
                  onPressed: _saveWard,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: viewModel.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        widget.ward == null ? 'Adding ward...' : 'Updating ward...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (viewModel.error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildBasicDetails(),
                      const SizedBox(height: 20),
                      _buildBedDetails(),
                      const SizedBox(height: 20),
                      _buildAdditionalDetails(),
                      const SizedBox(height: 20),
                      _buildFacilities(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.ward == null ? 'Create New Ward' : 'Update Ward Information',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HospitalVendorColorPalette.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.ward == null
                ? 'Fill in the details below to create a new ward'
                : 'Update the ward information as needed',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: HospitalVendorColorPalette.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Basic Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Ward Name',
              hintText: 'Enter ward name',
              prefixIcon: const Icon(Icons.local_hospital),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: HospitalVendorColorPalette.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ward name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _wardTypeController,
            decoration: InputDecoration(
              labelText: 'Ward Type',
              hintText: 'e.g., General, ICU, Private',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: HospitalVendorColorPalette.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ward type';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBedDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bed,
                color: HospitalVendorColorPalette.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Bed Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _totalBedsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Beds',
                    prefixIcon: const Icon(Icons.bed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: HospitalVendorColorPalette.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _availableBedsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Available',
                    prefixIcon: const Icon(Icons.event_available),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: HospitalVendorColorPalette.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    final available = int.parse(value);
                    final total = int.tryParse(_totalBedsController.text) ?? 0;
                    if (available > total) {
                      return 'Cannot exceed total';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price per Day',
              prefixIcon: const Icon(Icons.currency_rupee),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: HospitalVendorColorPalette.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid price';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: HospitalVendorColorPalette.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Additional Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _genderRestriction,
            decoration: InputDecoration(
              labelText: 'Gender Restriction',
              prefixIcon: const Icon(Icons.people),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: HospitalVendorColorPalette.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            items: ['None', 'Male', 'Female']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _genderRestriction = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter ward description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: HospitalVendorColorPalette.primaryBlue,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildAmenityTile(
            title: 'Air Conditioning',
            icon: Icons.ac_unit,
            value: _isAC,
            onChanged: (value) => setState(() => _isAC = value),
          ),
          _buildAmenityTile(
            title: 'Attached Bathroom',
            icon: Icons.bathroom,
            value: _hasAttachedBathroom,
            onChanged: (value) => setState(() => _hasAttachedBathroom = value),
          ),
          _buildAmenityTile(
            title: 'Isolation Ward',
            icon: Icons.security,
            value: _isIsolation,
            onChanged: (value) => setState(() => _isIsolation = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? HospitalVendorColorPalette.primaryBlue.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? HospitalVendorColorPalette.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: value ? HospitalVendorColorPalette.primaryBlue : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: value ? HospitalVendorColorPalette.primaryBlue : Colors.grey[800],
                  fontWeight: value ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: HospitalVendorColorPalette.primaryBlue,
      ),
    );
  }

  Widget _buildFacilities() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.featured_play_list,
                    color: HospitalVendorColorPalette.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Additional Facilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _showAddFacilityDialog,
                icon: const Icon(Icons.add_circle),
                color: HospitalVendorColorPalette.primaryBlue,
                tooltip: 'Add Facility',
              ),
            ],
          ),
          if (_facilities.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                'No additional facilities added',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _facilities.map((facility) => Chip(
                  label: Text(facility),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _facilities.remove(facility);
                    });
                  },
                  backgroundColor: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: HospitalVendorColorPalette.primaryBlue,
                  ),
                  deleteIconColor: HospitalVendorColorPalette.primaryBlue,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddFacilityDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle,
                          color: HospitalVendorColorPalette.primaryBlue,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Add New Facility',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: HospitalVendorColorPalette.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add amenities and facilities available in this ward',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: 'Facility Name',
                              hintText: 'e.g., TV, Fan, Nurse Call Button',
                              prefixIcon: const Icon(
                                Icons.featured_play_list,
                                color: HospitalVendorColorPalette.primaryBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: HospitalVendorColorPalette.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red[400]!,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red[400]!,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter facility name';
                              }
                              if (_facilities.contains(value.trim())) {
                                return 'This facility already exists';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Common Facilities',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSuggestionChip('TV', controller),
                              _buildSuggestionChip('Fan', controller),
                              _buildSuggestionChip('Nurse Call Button', controller),
                              _buildSuggestionChip('Oxygen Supply', controller),
                              _buildSuggestionChip('Medical Gas Pipeline', controller),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                controller.clear();
                                Navigator.pop(context);
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isSubmitting = true);
                                  
                                  // Simulate a small delay for better UX
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  
                                  if (mounted) {
                                    final facilityName = controller.text.trim();
                                    this.setState(() {
                                      _facilities.add(facilityName);
                                    });
                                    Navigator.pop(context);
                                    
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$facilityName added successfully'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HospitalVendorColorPalette.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSubmitting)
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            Text(
                              isSubmitting ? 'Adding...' : 'Add Facility',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, TextEditingController controller) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: _facilities.contains(label)
              ? Colors.grey[400]
              : HospitalVendorColorPalette.primaryBlue,
          fontSize: 12,
        ),
      ),
      backgroundColor: _facilities.contains(label)
          ? Colors.grey[100]
          : HospitalVendorColorPalette.primaryBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _facilities.contains(label)
              ? Colors.grey[300]!
              : HospitalVendorColorPalette.primaryBlue.withOpacity(0.3),
        ),
      ),
      onPressed: _facilities.contains(label)
          ? null
          : () {
              controller.text = label;
            },
    );
  }

  Future<void> _saveWard() async {
    if (_formKey.currentState!.validate()) {
      final hospitalId = Provider.of<HospitalDashboardViewModel>(
        context,
        listen: false,
      ).hospitalProfile?.vendorId;

      if (hospitalId != null) {
        final ward = Ward(
          wardId: widget.ward?.wardId ?? '',
          name: _nameController.text,
          wardType: _wardTypeController.text,
          totalBeds: int.parse(_totalBedsController.text),
          availableBeds: int.parse(_availableBedsController.text),
          pricePerDay: double.parse(_priceController.text),
          genderRestriction: _genderRestriction,
          isAC: _isAC,
          hasAttachedBathroom: _hasAttachedBathroom,
          isIsolation: _isIsolation,
          description: _descriptionController.text,
          vendorId: hospitalId,
          facilities: _facilities,
        );

        try {
          final success = await _viewModel.saveWard(ward);

          if (success && mounted) {
            // Refresh the ward list in WardViewModel
            Provider.of<WardViewModel>(context, listen: false).fetchWards(hospitalId);

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.ward == null
                      ? 'Ward added successfully'
                      : 'Ward updated successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital ID not found. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 