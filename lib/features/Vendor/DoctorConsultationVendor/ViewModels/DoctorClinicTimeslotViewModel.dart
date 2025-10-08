import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicTimeslotModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicTimeslotService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:logger/logger.dart';

class DoctorClinicTimeslotViewModel extends ChangeNotifier {
  final DoctorClinicTimeslotService _timeslotService = DoctorClinicTimeslotService();
  final VendorLoginService _loginService = VendorLoginService();
  final Logger _logger = Logger();

  // State variables
  List<DoctorClinicTimeslotModel> _timeslots = [];
  DoctorClinicTimeslotModel? _selectedTimeslot;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  // Form controllers
  final TextEditingController dayController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController intervalController = TextEditingController(text: '30');

  // Generated slots preview
  List<String> _generatedSlots = [];

  // Form validation errors
  Map<String, String> _validationErrors = {};

  // Getters
  List<DoctorClinicTimeslotModel> get timeslots => _timeslots;
  DoctorClinicTimeslotModel? get selectedTimeslot => _selectedTimeslot;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;
  List<String> get generatedSlots => _generatedSlots;
  Map<String, String> get validationErrors => _validationErrors;

  // Week days for dropdown
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Common time intervals
  final List<int> timeIntervals = [15, 30, 45, 60];

  @override
  void dispose() {
    dayController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    intervalController.dispose();
    super.dispose();
  }

  /// Load all timeslots for the current doctor
  Future<void> loadTimeslots() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final String? vendorId = await _timeslotService.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      final timeslots = await _timeslotService.getTimeslots(vendorId);

      if (timeslots.isNotEmpty) {
        _timeslots = timeslots;
        _logger.i('✅ Timeslots loaded successfully: ${timeslots.length}');
      } else {
        _timeslots = [];
        _logger.i('ℹ️ No timeslots found for this doctor');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading timeslots: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new timeslot
  Future<bool> createTimeslot() async {
    try {
      _isSaving = true;
      _error = null;
      _validationErrors.clear();
      notifyListeners();

      final String? vendorId = await _timeslotService.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      final timeslot = DoctorClinicTimeslotModel(
        vendorId: vendorId,
        day: dayController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        intervalMinutes: int.tryParse(intervalController.text) ?? 30,
        generatedSlots: _generatedSlots,
      );

      // Validate the timeslot
      final errors = timeslot.validate();
      if (errors.isNotEmpty) {
        _validationErrors = errors;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final success = await _timeslotService.createTimeslot(timeslot);

      if (success) {
        _successMessage = 'Timeslot created successfully!';
        _clearForm();
        await loadTimeslots(); // Refresh the list
      } else {
        throw Exception('Failed to create timeslot');
      }

      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _logger.e('Error creating timeslot: $e');
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing timeslot
  Future<bool> updateTimeslot() async {
    try {
      _logger.i('🔧 Starting update process. Selected timeslot: ${_selectedTimeslot?.day ?? 'null'}');
      _isSaving = true;
      _error = null;
      _validationErrors.clear();
      notifyListeners();

      if (_selectedTimeslot == null || _selectedTimeslot!.timeSlotID == null) {
        _logger.e('❌ No timeslot selected for update. _selectedTimeslot is null: ${_selectedTimeslot == null}');
        _logger.e('❌ Current form data: day=${dayController.text}, start=${startTimeController.text}, end=${endTimeController.text}');

        // Try to find the timeslot from the current form data if we have enough info
        if (dayController.text.isNotEmpty && startTimeController.text.isNotEmpty) {
          _logger.i('🔍 Attempting to find timeslot from form data...');
          // Look through existing timeslots to find a match
          final matchingTimeslot = _timeslots.firstWhere(
            (t) => t.day == dayController.text &&
                   t.startTime == startTimeController.text &&
                   t.endTime == endTimeController.text,
            orElse: () => DoctorClinicTimeslotModel(
              vendorId: '',
              day: '',
              startTime: '',
              endTime: '',
              intervalMinutes: 30,
            ),
          );

          if (matchingTimeslot.timeSlotID != null && matchingTimeslot.timeSlotID!.isNotEmpty) {
            _logger.i('✅ Found matching timeslot: ${matchingTimeslot.day}, ID: ${matchingTimeslot.timeSlotID}');
            _selectedTimeslot = matchingTimeslot;
          } else {
            throw Exception('Could not find matching timeslot for update. Please try editing again.');
          }
        } else {
          throw Exception('No timeslot selected for update. Please try editing again.');
        }
      }

      final updatedTimeslot = _selectedTimeslot!.copyWith(
        day: dayController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        intervalMinutes: int.tryParse(intervalController.text) ?? 30,
        generatedSlots: _generatedSlots,
        updatedAt: DateTime.now(),
      );

      // Validate the timeslot
      final errors = updatedTimeslot.validate();
      if (errors.isNotEmpty) {
        _validationErrors = errors;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final success = await _timeslotService.updateTimeslot(
        _selectedTimeslot!.timeSlotID!,
        updatedTimeslot,
      );

      if (success) {
        _successMessage = 'Timeslot updated successfully!';
        _clearForm();
        _selectedTimeslot = null;
        await loadTimeslots(); // Refresh the list
      } else {
        throw Exception('Failed to update timeslot');
      }

      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _logger.e('Error updating timeslot: $e');
      _error = e.toString();
      _isSaving = false;
      // Don't clear _selectedTimeslot on error so user can retry
      notifyListeners();
      return false;
    }
  }

  /// Delete a timeslot
  Future<bool> deleteTimeslot(String timeslotId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _timeslotService.deleteTimeslot(timeslotId);

      if (success) {
        _successMessage = 'Timeslot deleted successfully!';
        await loadTimeslots(); // Refresh the list
      } else {
        throw Exception('Failed to delete timeslot');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _logger.e('Error deleting timeslot: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete specific slots from a timeslot
  Future<Map<String, dynamic>?> deleteSpecificSlots(String timeSlotID, List<String> slotsToDelete) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _logger.i('📝 Deleting specific slots from timeslot: $timeSlotID');
      _logger.i('📝 Slots to delete: $slotsToDelete');

      final result = await _timeslotService.deleteSpecificSlots(timeSlotID, slotsToDelete);

      if (result != null) {
        _logger.i('✅ Specific slots deleted successfully!');
        _successMessage = 'Selected slots deleted successfully!';
        await loadTimeslots(); // Refresh the list
      } else {
        throw Exception('Failed to delete specific slots');
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _logger.e('Error deleting specific slots: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Toggle timeslot active status
  Future<bool> toggleTimeslotStatus(String timeSlotID, bool isActive) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _timeslotService.toggleTimeslotStatus(timeSlotID, isActive);

      if (success) {
        _successMessage = isActive ? 'Timeslot activated!' : 'Timeslot deactivated!';
        await loadTimeslots(); // Refresh the list
      } else {
        throw Exception('Failed to update timeslot status');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _logger.e('Error toggling timeslot status: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select a timeslot for editing
  void selectTimeslot(DoctorClinicTimeslotModel timeslot) {
    _logger.i('🔧 Selecting timeslot for editing: ${timeslot.day}, ID: ${timeslot.timeSlotID}');
    _logger.i('🔧 Timeslot data: startTime=${timeslot.startTime}, endTime=${timeslot.endTime}, interval=${timeslot.intervalMinutes}');
    _selectedTimeslot = timeslot;
    _populateFormWithTimeslot(timeslot);
    _logger.i('✅ Timeslot selected. Current _selectedTimeslot: ${_selectedTimeslot?.day ?? 'null'}, ID: ${_selectedTimeslot?.timeSlotID ?? 'null'}');
    _logger.i('✅ Form populated: day=${dayController.text}, start=${startTimeController.text}, end=${endTimeController.text}');
    notifyListeners();
  }

  /// Clear the selected timeslot (for creating new ones)
  void clearSelection() {
    _selectedTimeslot = null;
    _clearForm();
    notifyListeners();
  }

  /// Generate time slots preview based on current form data
  void generateSlotsPreview() {
    try {
      final startTime = startTimeController.text;
      final endTime = endTimeController.text;
      final interval = int.tryParse(intervalController.text) ?? 30;

      if (startTime.isNotEmpty && endTime.isNotEmpty && interval > 0) {
        // Create a temporary timeslot to generate slots
        final tempTimeslot = DoctorClinicTimeslotModel(
          vendorId: 'temp',
          day: dayController.text,
          startTime: startTime,
          endTime: endTime,
          intervalMinutes: interval,
        );

        _generatedSlots = tempTimeslot.generateTimeSlots();
      } else {
        _generatedSlots = [];
      }

      notifyListeners();
    } catch (e) {
      _logger.e('Error generating slots preview: $e');
      _generatedSlots = [];
      notifyListeners();
    }
  }

  /// Clear the form
  void _clearForm() {
    dayController.clear();
    startTimeController.clear();
    endTimeController.clear();
    intervalController.text = '30';
    _generatedSlots = [];
    _validationErrors.clear();
    _error = null;
    _successMessage = null;
  }

  /// Populate form with timeslot data
  void _populateFormWithTimeslot(DoctorClinicTimeslotModel timeslot) {
    _logger.i('🔧 Populating form with timeslot: ${timeslot.day}, ${timeslot.startTime}-${timeslot.endTime}');

    dayController.text = timeslot.day;
    startTimeController.text = timeslot.startTime;
    endTimeController.text = timeslot.endTime;
    intervalController.text = timeslot.intervalMinutes.toString();
    _generatedSlots = timeslot.generatedSlots;

    _logger.i('✅ Form populated: day=${dayController.text}, start=${startTimeController.text}, end=${endTimeController.text}, interval=${intervalController.text}');
    notifyListeners(); // Notify listeners to update the UI
  }

  /// Clear error messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Clear validation errors
  void clearValidationErrors() {
    _validationErrors.clear();
    notifyListeners();
  }

  /// Check if form is valid
  bool get isFormValid {
    return dayController.text.isNotEmpty &&
           startTimeController.text.isNotEmpty &&
           endTimeController.text.isNotEmpty &&
           intervalController.text.isNotEmpty &&
           _validationErrors.isEmpty;
  }

  /// Get timeslots for a specific day
  List<DoctorClinicTimeslotModel> getTimeslotsForDay(String day) {
    return _timeslots.where((timeslot) => timeslot.day == day).toList();
  }

  /// Get active timeslots only
  List<DoctorClinicTimeslotModel> get activeTimeslots {
    return _timeslots.where((timeslot) => timeslot.isActive).toList();
  }
}
