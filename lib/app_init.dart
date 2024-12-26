import 'package:flutter/material.dart';
import 'manager/app_config_manager.dart';
import 'manager/database_manager.dart';
import 'manager/service_manager.dart';
import 'manager/user_config_manager.dart';
import 'utils/cache_util.dart';
import 'utils/http_client.dart';

/// 应用初始化
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  初始化缓存工具
  await CacheUtil.init();

  //  初始化配置管理器
  await AppConfigManager.init();
  if (AppConfigManager.isConfigServer()) {
    //  初始化HTTP客户端
    HttpClient.refresh(
      serverUrl: AppConfigManager.instance.serverUrl,
      accessToken: AppConfigManager.instance.accessToken,
    );
    // 初始化数据库管理器
    await DatabaseManager.init();
    // 初始化服务管理器
    await ServiceManager.init();
    // 初始化用户配置管理器
    await UserConfigManager.refresh(AppConfigManager.instance.userId!);

    await ServiceManager.syncService.syncInit();
  }
}

setServerInfo(String serverUrl, String userId, String accessToken) async {
  await AppConfigManager.instance.setServerUrl(serverUrl);
  await AppConfigManager.instance.setAccessToken(accessToken);
  await AppConfigManager.instance.setUserId(userId);
  await HttpClient.refresh(serverUrl: serverUrl, accessToken: accessToken);
}
