import 'package:flutter/foundation.dart';
import '../providers/sync_provider.dart';

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
  
  /// 应用启动时同步
  Future<void> _syncOnAppLaunch() async {
    try {
      debugPrint('应用启动，触发数据同步');
      await _syncProvider?.syncData();
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