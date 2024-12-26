import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../utils/id_util.dart';

/// 用户服务
class UserService extends BaseService {
  final UserDao _userDao;

  UserService() : _userDao = UserDao(DatabaseManager.db);

  /// 用户登录
  Future<OperateResult<User>> login(String username, String password) async {
    User? user = await _userDao.findByUsername(username);
    if (user == null) {
      return OperateResult.fail('用户名或密码错误', null);
    }
    if (!await verifyPassword(user, password)) {
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
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      await _userDao.createUser(
        id: userId,
        username: username,
        password: hashedPassword,
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

  /// 更新用户信息
  Future<OperateResult<void>> updateUserInfo({
    required String id,
    String? nickname,
    String? email,
    String? phone,
    String? timezone,
  }) async {
    try {
      final user = await _userDao.findById(id);
      if (user == null) {
        return OperateResult.fail('用户不存在', null);
      }

      await _userDao.update(UserTableCompanion(
        id: Value(id),
        createdAt: Value(user.createdAt),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        username: Value(user.username),
        nickname: Value(nickname ?? user.nickname),
        password: Value(user.password),
        email: absentIfNull(email),
        phone: absentIfNull(phone),
        inviteCode: Value(user.inviteCode),
        timezone: absentIfNull(timezone),
      ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('更新用户信息失败：$e', e as Exception);
    }
  }

  /// 验证密码
  Future<bool> verifyPassword(User user, String password) async {
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    return user.password == hashedPassword;
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

      // 验证旧密码
      if (!await verifyPassword(user, oldPassword)) {
        return OperateResult.fail('旧密码错误', null);
      }

      // 对新密码进行哈希
      final hashedNewPassword =
          sha256.convert(utf8.encode(newPassword)).toString();

      await _userDao.update(UserTableCompanion(
        id: Value(id),
        password: Value(hashedNewPassword),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('修改密码失败：$e', e as Exception);
    }
  }

  String generateInviteCode() {
    return IdUtils.genNanoId6();
  }

  String generateNickname() {
    return 'clsswjz_${IdUtils.genNanoId8()}';
  }
}
