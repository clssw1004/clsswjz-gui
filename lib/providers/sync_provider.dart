import 'package:flutter/material.dart';

import '../manager/service_manager.dart';
import '../manager/app_config_manager.dart';
import '../utils/event_bus.dart';
import '../events/sync_events.dart';

class SyncProvider extends ChangeNotifier {
  bool _syncing = false;
  bool get syncing => _syncing;

  double _progress = 0.0;
  double get progress => _progress;

  String? _currentStep;
  String? get currentStep => _currentStep;

  int? get lastSyncTime => AppConfigManager.instance.lastSyncTime;

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

      EventBus.instance.emit(const SyncCompletedEvent());

      notifyListeners();
    } finally {
      _syncing = false;
      _progress = 0.0;
      _currentStep = null;
      notifyListeners();
    }
  }
}
