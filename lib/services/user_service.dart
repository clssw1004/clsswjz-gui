import 'package:drift/drift.dart';
import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../database/database_service.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../utils/id.util.dart';

class UserService extends BaseService {
  final UserDao _userDao;

  UserService() : _userDao = UserDao(DatabaseService.db);

  /// 用户登录
  Future<OperateResult<User>> login(String username, String password) async {
    final user = await _userDao.verifyUser(username, password);
    if (user == null) {
      return OperateResult.fail('用户名或密码错误', null);
    }
    return OperateResult.success(user);
  }

  /// 用户注册
  Future<OperateResult<String>> register({
    required String username,
    required String password,
    required String? nickname,
    String? email,
    String? phone,
  }) async {
    try {
      // 检查用户名是否已存在
      if (await _userDao.isUsernameExists(username)) {
        return OperateResult.fail('用户名已存在', null);
      }

      final userId = generateUuid();
      await _userDao.createUser(
        id: userId,
        username: username,
        password: password,
        nickname: nickname ?? generateNickname(),
        inviteCode: generateInviteCode(),
        email: email,
        phone: phone,
      );
      return OperateResult.success(userId);
    } catch (e) {
      return OperateResult.fail('注册失败：$e', e as Exception);
    }
  }

  /// 修改用户信息
  Future<OperateResult<void>> updateUserInfo({
    required String id,
    String? nickname,
    String? email,
    String? phone,
    String? language,
    String? timezone,
  }) async {
    try {
      final user = await _userDao.findById(id);
      if (user == null) {
        return OperateResult.fail('用户不存在', null);
      }

      await _userDao.update(UserTableCompanion(
        id: Value(id),
        nickname: absentIfNull(nickname),
        email: absentIfNull(email),
        phone: absentIfNull(phone),
        language: absentIfNull(language),
        timezone: absentIfNull(timezone),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('更新失败：$e', e as Exception);
    }
  }

  /// 修改密码
  Future<OperateResult<void>> changePassword({
    required String id,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _userDao.findById(id);
      if (user == null) {
        return OperateResult.fail('用户不存在', null);
      }

      if (user.password != oldPassword) {
        return OperateResult.fail('原密码错误', null);
      }

      await _userDao.update(UserTableCompanion(
        id: Value(id),
        password: Value(newPassword),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('修改密码失败：$e', e as Exception);
    }
  }

  /// 获取用户信息
  Future<OperateResult<User>> getUserInfo(String id) async {
    try {
      final user = await _userDao.findById(id);
      if (user == null) {
        return OperateResult.fail('用户不存在', null);
      }
      return OperateResult.success(user);
    } catch (e) {
      return OperateResult.fail('获取用户信息失败：$e', e as Exception);
    }
  }

  String generateInviteCode() {
    return genNanoId6();
  }

  String generateNickname() {
    return 'clsswjz_$genNanoId8()';
  }
}
