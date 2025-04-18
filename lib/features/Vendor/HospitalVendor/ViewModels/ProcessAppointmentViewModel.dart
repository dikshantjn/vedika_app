import 'package:flutter/material.dart';

class ProcessAppointmentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isPaymentCompleted = false;
  bool _isProcessing = false;
  bool _isNotifyingPayment = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isPaymentCompleted => _isPaymentCompleted;
  bool get isProcessing => _isProcessing;
  bool get isNotifyingPayment => _isNotifyingPayment;
  String? get error => _error;

  Future<void> notifyPayment(String appointmentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _isPaymentCompleted = true;
    } catch (e) {
      _error = 'Failed to notify payment. Please try again.';
    } finally {
      _isLoading = false;
      _isNotifyingPayment = false;
      notifyListeners();
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Update appointment status to completed
    } catch (e) {
      _error = 'Failed to complete appointment. Please try again.';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void resetState() {
    _isLoading = false;
    _isPaymentCompleted = false;
    _isProcessing = false;
    _isNotifyingPayment = false;
    _error = null;
    notifyListeners();
  }
} 