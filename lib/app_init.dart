import 'package:clsswjz/enums/storage_mode.dart';

import 'manager/app_config_manager.dart';
import 'manager/database_manager.dart';
import 'manager/service_manager.dart';
import 'manager/user_config_manager.dart';
import 'utils/http_client.dart';

/// 应用初始化
Future<void> initApp({
  String? userName,
  String? userNickname,
  String? userEmail,
  String? userPhone,
}) async {
  if (AppConfigManager.isAppInit()) {
    bool needSync = AppConfigManager.instance.storageType == StorageMode.selfHost;
    if (needSync) {
      //  初始化HTTP客户端
      await HttpClient.refresh(
        serverUrl: AppConfigManager.instance.serverUrl,
        accessToken: AppConfigManager.instance.accessToken,
      );
    }
    // 初始化数据库管理器
    await DatabaseManager.init();
    // 初始化服务管理器
    await ServiceManager.init(syncInit: needSync);
    // 初始化用户配置管理器
    await UserConfigManager.refresh(AppConfigManager.instance.userId!);
  }
}
