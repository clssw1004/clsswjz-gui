import 'package:flutter/foundation.dart';
import '../providers/sync_provider.dart';
import 'app_config_manager.dart';

/// 同步管理器：负责在适当时机触发同步操作
class SyncManager {
  // 单例模式
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  // 状态追踪
  bool _isInitialized = false;
  SyncProvider? _syncProvider;

  /// 初始化同步管理器
  void initialize(SyncProvider syncProvider) {
    if (_isInitialized) return;
    _isInitialized = true;
    _syncProvider = syncProvider;

    // 应用启动时检查同步
    _syncOnAppLaunch();
  }

  /// 重置状态，在 app 重启时调用以允许新的 SyncProvider 初始化
  void reset() {
    _isInitialized = false;
    _syncProvider = null;
  }

  /// 应用启动时同步
  Future<void> _syncOnAppLaunch() async {
    try {
      if (AppConfigManager.isAppInit()) {
        debugPrint('应用启动，触发数据同步');
        await _syncProvider?.syncData();
      }
    } catch (e) {
      debugPrint('应用启动同步失败: $e');
    }
  }

  /// 手动触发同步
  Future<void> manualSync() async {
    try {
      await _syncProvider?.syncData();
    } catch (e) {
      debugPrint('手动同步失败: $e');
    }
  }
}
