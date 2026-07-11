
import 'enums/storage_mode.dart';
import 'main.dart' show resetNavigatorKey;
import 'manager/app_config_manager.dart';
import 'manager/database_manager.dart';
import 'manager/service_manager.dart';
import 'manager/sync_manager.dart';
import 'manager/user_config_manager.dart';
import 'utils/http_client.dart';
import 'package:flutter/foundation.dart';

/// 应用初始化
Future<void> initApp({
  String? userName,
  String? userNickname,
  String? userEmail,
  String? userPhone,
}) async {
  if (AppConfigManager.isAppInit()) {
    // 重置导航键，确保 MaterialApp 重建时 Navigator 重新读取 initialRoute
    resetNavigatorKey();
    // 重置同步管理器，允许新的 SyncProvider 初始化时触发同步
    SyncManager().reset();
    bool needSync = AppConfigManager.instance.storageType == StorageMode.selfHost;
    debugPrint('[initApp] start, needSync=$needSync');
    if (needSync) {
      await HttpClient.refresh(
        serverUrl: AppConfigManager.instance.serverUrl,
        accessToken: AppConfigManager.instance.accessToken,
      );
      debugPrint('[initApp] httpClient refreshed');
    }
    await DatabaseManager.init();
    debugPrint('[initApp] db init done');
    await ServiceManager.init(syncInit: needSync);
    // 重置后台同步状态，避免重启/热重载后旧状态残留
    ServiceManager.resetBackgroundSyncState();
    debugPrint('[initApp] service init done');
    debugPrint('[initApp] refreshing user config...');
    await UserConfigManager.refresh(AppConfigManager.instance.userId);
    debugPrint('[initApp] user config done');
  } else {
    debugPrint('[initApp] app not init, skip');
  }
  debugPrint('[initApp] complete');
}
