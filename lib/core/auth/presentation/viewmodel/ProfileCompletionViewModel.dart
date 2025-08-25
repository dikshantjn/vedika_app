import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/auth/data/services/ProfileCompletionService.dart';

class ProfileCompletionViewModel extends ChangeNotifier {
  final ProfileCompletionService _service;

  ProfileCompletionViewModel({ProfileCompletionService? service}) : _service = service ?? ProfileCompletionService();

  final Map<ServiceType, bool> _statusByService = {};
  bool _isPreloaded = false;
  String? _userId;

  bool get isPreloaded => _isPreloaded;
  String? get userId => _userId;

  bool? isComplete(ServiceType serviceType) => _statusByService[serviceType];

  Future<void> preloadAll(String userId) async {
    if (_isPreloaded && _userId == userId) return;
    _userId = userId;

    final futures = <Future<void>>[
      _load(ServiceType.ambulance),
      _load(ServiceType.hospital),
      _load(ServiceType.bloodBank),
      _load(ServiceType.labTest),
      _load(ServiceType.medicineDelivery),
      _load(ServiceType.clinic),
    ];
    await Future.wait(futures);
    _isPreloaded = true;
    notifyListeners();
  }

  Future<void> _load(ServiceType serviceType) async {
    try {
      if (_userId == null) return;
      final result = await _service.isProfileComplete(_userId!, serviceType);
      _statusByService[serviceType] = result;
    } catch (_) {
      // Leave as null on error to allow fallback behavior
    }
  }
}


