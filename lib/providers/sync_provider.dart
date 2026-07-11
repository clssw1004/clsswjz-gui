import 'dart:async';
import 'package:flutter/material.dart';

import '../manager/service_manager.dart';
import '../manager/app_config_manager.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_book.dart';
import '../events/special/event_activity_checkin.dart';
import '../events/special/event_recurring_config.dart';
import '../events/special/event_bookkeeping_rule.dart';
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
      EventBus.instance.on<GiftCardChangedEvent>(_handleGiftCardChanged),
      EventBus.instance.on<ActivityChangedEvent>(_handleActivityChanged),
      EventBus.instance.on<ActivityDefinitionChangedEvent>(_handleActivityDefinitionChanged),
      EventBus.instance.on<UserShareChangedEvent>(_handleUserShareChanged),
      EventBus.instance.on<RecurringConfigChangedEvent>(_handleRecurringConfigChanged),
      EventBus.instance.on<BookkeepingRuleChangedEvent>(_handleBookkeepingRuleChanged),
      EventBus.instance.on<SyncCompletedEvent>(_handleSyncCompleted),
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

  void _handleGiftCardChanged(GiftCardChangedEvent event) {
    // 礼物卡任何操作都需要同步
    syncData();
  }

  void _handleActivityChanged(ActivityChangedEvent event) {
    syncData();
  }

  void _handleActivityDefinitionChanged(ActivityDefinitionChangedEvent event) {
    syncData();
  }

  void _handleUserShareChanged(UserShareChangedEvent event) {
    syncData();
  }

  void _handleRecurringConfigChanged(RecurringConfigChangedEvent event) {
    if (event.operateType == OperateType.create) {
      syncData();
    }
  }

  void _handleBookkeepingRuleChanged(BookkeepingRuleChangedEvent event) {
    syncData();
  }

  void _handleSyncCompleted(SyncCompletedEvent event) {
    _backgroundSyncing = false;
    _backgroundProgress = 0.0;
    notifyListeners();
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

  bool _backgroundSyncing = false;
  bool get backgroundSyncing => _backgroundSyncing;

  double _progress = 0.0;
  double get progress => _progress;

  double _backgroundProgress = 0.0;
  double get backgroundProgress => _backgroundProgress;

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

  /// 仅同步优先数据（P0+P1），用于首次安装场景
  /// 同步完基础数据后即可进入 APP，其余数据在后台继续同步
  Future<void> syncPriorityData() async {
    if (_syncing) return;

    _syncing = true;
    _progress = 0.0;
    _currentStep = null;
    _backgroundSyncing = false;
    _backgroundProgress = 0.0;
    notifyListeners();
    try {
      await ServiceManager.syncService.syncChanges(
        priorityOnly: true,
        onProgress: (progress, step) {
          _progress = progress.toDouble() / 100;
          _currentStep = step;
          notifyListeners();
        },
      );
      // 后台同步由 SyncService 的 _startBackgroundSync 负责发 SyncCompletedEvent
      // 此处不发送，以免各 Provider 过早刷新导致数据不完整
      _backgroundSyncing = true;
      notifyListeners();
    } finally {
      _syncing = false;
      _progress = 0.0;
      _currentStep = null;
      notifyListeners();
    }
  }
}
