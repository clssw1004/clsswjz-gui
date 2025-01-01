import 'package:clsswjz/manager/cache_manager.dart';

import '../models/vo/user_vo.dart';
import '../services/user_service.dart';
import 'service_manager.dart';

class UserConfigManager {
  static const _currentUserIdKey = 'current_user_id';

  static bool isInited = false;
  static late final UserConfigManager _instance;
  static UserConfigManager get instance => _instance;
  static late UserService _userService;

  static UserService get userService => _userService;

  static String get currentUserIdKey => _currentUserIdKey;

  static late String _currentUserId;
  static String get currentUserId => _currentUserId;

  static late UserVO _currentUser;
  UserVO get currentUser => _currentUser;

  UserConfigManager._();

  static Future<void> refresh(String userId) async {
    print('init:$userId');
    if (!isInited) {
      _instance = UserConfigManager._();
      _userService = ServiceManager.userService;
      isInited = true;
    }
    _currentUserId = userId;
    final user =
        await _userService.getUserInfo(userId).then((value) => value.data);
    print('user: $user');
    setCurrentUser(user!);
  }

  static setCurrentUser(UserVO user) {
    _currentUser = user;
    CacheManager.instance.setString(_currentUserIdKey, user.id);
  }
}
