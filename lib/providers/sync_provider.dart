import 'dart:async';
import 'package:flutter/material.dart';

import '../manager/service_manager.dart';
import '../manager/app_config_manager.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_book.dart';
import '../enums/operate_type.dart';

class SyncProvider extends ChangeNotifier {
 final List<StreamSubscription> _subscriptions = [];

  SyncProvider() {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _subscriptions.addAll([
      EventBus.instance.on<ItemChangedEvent>(_handleItemChanged),
      EventBus.instance.on<NoteChangedEvent>(_handleNoteChanged),
      EventBus.instance.on<DebtChangedEvent>(_handleDebtChanged),
    ]);
  }

  void _handleItemChanged(ItemChangedEvent event) {
    if (event.operateType == OperateType.create) {
      syncData();
    }
  }

  void _handleNoteChanged(NoteChangedEvent event) {
    if (event.operateType == OperateType.create) {
      syncData();
    }
  }

  void _handleDebtChanged(DebtChangedEvent event) {
    if (event.operateType == OperateType.create) {
      syncData();
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
  
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
