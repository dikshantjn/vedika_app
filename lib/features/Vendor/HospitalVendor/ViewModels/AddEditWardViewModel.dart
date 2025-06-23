import 'package:flutter/material.dart';
import '../Models/Ward.dart';
import '../Services/WardService.dart';

class AddEditWardViewModel extends ChangeNotifier {
  final WardService _wardService = WardService();
  bool _isLoading = false;
  String? _error;
  Ward? _ward;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Ward? get ward => _ward;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setWard(Ward? ward) {
    _ward = ward;
    notifyListeners();
  }

  Future<bool> saveWard(Ward ward) async {
    _setLoading(true);
    _setError(null);
    _setWard(null);

    try {
      final Ward savedWard;
      
      if (ward.wardId.isEmpty) {
        savedWard = await _wardService.addWard(ward);
      } else {
        savedWard = await _wardService.updateWard(ward);
      }

      _setWard(savedWard);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }
} 