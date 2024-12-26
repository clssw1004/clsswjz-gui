import 'package:flutter/material.dart';
import 'manager/app_config_manager.dart';
import 'manager/database_manager.dart';
import 'manager/service_manager.dart';
import 'manager/user_config_manager.dart';
import 'utils/cache_util.dart';

/// 应用初始化
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化缓存工具
  await CacheUtil.init();

  final currentUserId =
      CacheUtil.instance.getString(UserConfigManager.currentUserIdKey) ??
          'iy6dnir1k359j47yna16d538q88zqppn';

  // 2. 初始化配置管理器
  await AppConfigManager.init();

  // 3. 初始化数据库管理器
  await DatabaseManager.init();

  // 4. 初始化用户配置管理器
  await UserConfigManager.init(currentUserId!);

  // 5. 初始化服务管理器
  await ServiceManager.init();
}
