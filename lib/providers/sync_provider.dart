import 'package:flutter/material.dart';

import '../manager/service_manager.dart';

class SyncProvider extends ChangeNotifier {
  bool _syncing = false;
  bool get syncing => _syncing;

  double _progress = 0.0;
  double get progress => _progress;

  String? _currentStep;
  String? get currentStep => _currentStep;

  Future<void> syncData() async {
    if (_syncing) return;

    _syncing = true;
    _progress = 0.0;
    _currentStep = null;
    notifyListeners();

    try {
      await ServiceManager.syncService.syncChanges(
        onProgress: (progress, step) {
          _progress = progress.toDouble() / 100;
          _currentStep = step;
          notifyListeners();
        },
      );
    } finally {
      _syncing = false;
      _progress = 0.0;
      _currentStep = null;
      notifyListeners();
    }
  }
}
