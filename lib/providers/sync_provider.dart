import 'package:flutter/material.dart';

import '../manager/service_manager.dart';

class SyncProvider extends ChangeNotifier {
  bool _syncing = false;
  bool get syncing => _syncing;

  Future<void> syncData() async {
    if (_syncing) return;

    _syncing = true;
    notifyListeners();

    try {
      await ServiceManager.syncService.syncChanges();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }
}
