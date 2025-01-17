import 'package:clsswjz/manager/cache_manager.dart';

import '../drivers/driver_factory.dart';
import '../models/vo/user_vo.dart';

class UserConfigManager {
  static const _currentUserIdKey = 'current_user_id';

  static bool isInited = false;
  static late final UserConfigManager _instance;
  static UserConfigManager get instance => _instance;

  static String get currentUserIdKey => _currentUserIdKey;

  static late String _currentUserId;
  static String get currentUserId => _currentUserId;

  static late UserVO _currentUser;
  UserVO get currentUser => _currentUser;

  UserConfigManager._();

  static Future<void> refresh(String userId) async {
    if (!isInited) {
      _instance = UserConfigManager._();
      isInited = true;
    }
    _currentUserId = userId;
    final user = await DriverFactory.driver.getUserInfo(userId).then((value) => value.data);
    setCurrentUser(user!);
  }

  static setCurrentUser(UserVO user) {
    _currentUser = user;
    CacheManager.instance.setString(_currentUserIdKey, user.id);
  }
}
