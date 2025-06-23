import 'package:flutter/material.dart';
import '../Models/Ward.dart';
import '../Services/WardService.dart';

class WardViewModel extends ChangeNotifier {
  final WardService _wardService = WardService();
  List<Ward> _wards = [];
  bool _isLoading = false;
  String? _error;

  List<Ward> get wards => _wards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchWards(String hospitalId) async {
    _setLoading(true);
    _error = null;

    try {
      _wards = await _wardService.getWards(hospitalId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addWard(Ward ward) async {
    _setLoading(true);
    _setError(null);

    try {
      final savedWard = await _wardService.addWard(ward);
      _wards.add(savedWard); // Add the returned ward to local list
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Error adding ward: $e');
      return false;
    }
  }

  Future<bool> updateWard(Ward ward) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedWard = await _wardService.updateWard(ward);
      final index = _wards.indexWhere((w) => w.wardId == ward.wardId);
      if (index != -1) {
        _wards[index] = updatedWard; // Update with the returned ward
        notifyListeners();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Error updating ward: $e');
      return false;
    }
  }

  Future<bool> deleteWard(String wardId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _wardService.deleteWard(wardId);
      
      if (success) {
        _wards.removeWhere((ward) => ward.wardId == wardId);
        notifyListeners();
      } else {
        _setError('Failed to delete ward');
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setLoading(false);
      _setError('Error deleting ward: $e');
      return false;
    }
  }
} 