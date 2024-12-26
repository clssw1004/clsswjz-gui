import 'package:clsswjz/utils/cache_util.dart';

import '../database/database.dart';
import '../services/user_service.dart';

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

  static Future<void> init(String userId) async {
    _instance = UserConfigManager._();
    _userService = UserService();
    _currentUserId = userId;
    final user =
        await _userService.getUserInfo(userId).then((value) => value.data);
    setCurrentUser(user!);
  }

  static setCurrentUser(User user) {
    _currentUser = user;
    CacheUtil.instance.setString(_currentUserIdKey, user.id);
  }
}
