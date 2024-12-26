import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/utils/cache_util.dart';

import '../database/database.dart';
import '../services/user_service.dart';
import 'service_manager.dart';

class UserConfigManager {
  static const _currentUserIdKey = 'current_user_id';

  static late final UserConfigManager _instance;
  static UserConfigManager get instance => _instance;
  static late UserService _userService;

  static UserService get userService => _userService;

  static String get currentUserIdKey => _currentUserIdKey;

  static late String _currentUserId;
  static String get currentUserId => _currentUserId;

  static late User _currentUser;
  User get currentUser => _currentUser;

  UserConfigManager._();

  static Future<void> refresh(String userId) async {
    print('init:$userId');
    _instance = UserConfigManager._();
    _userService = ServiceManager.userService;
    _currentUserId = userId;
    final user =
        await _userService.getUserInfo(userId).then((value) => value.data);
    print('user: $user');
    setCurrentUser(user!);
  }

  static setCurrentUser(User user) {
    _currentUser = user;
    CacheUtil.instance.setString(_currentUserIdKey, user.id);
  }

  static setUserServerInfo({
    required String serverUrl,
    required String userId,
    required String accessToken,
  }) {
    refresh(userId);
    AppConfigManager.instance.setServerUrl(serverUrl);
    AppConfigManager.instance.setAccessToken(accessToken);
  }
}
