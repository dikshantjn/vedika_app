import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';
import 'package:vedika_healthcare/features/home/data/repositories/HealthDayRepository.dart';


class HealthDaysViewModel extends ChangeNotifier {
  final HealthDayRepository _repository = HealthDayRepository();
  List<HealthDay> healthDays = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadHealthDays() async {
    isLoading = true;
    notifyListeners();
    try {
      healthDays = await _repository.fetchHealthDays();
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error loading health days";
    }
    isLoading = false;
    notifyListeners();
  }
}
