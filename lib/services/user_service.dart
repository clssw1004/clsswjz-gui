import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../database/tables/user_table.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import '../models/vo/user_vo.dart';
import 'base_service.dart';
import '../utils/id_util.dart';

/// 用户服务
class UserService extends BaseService {
  final UserDao _userDao;

  UserService() : _userDao = UserDao(DatabaseManager.db);

  /// 用户登录
  Future<OperateResult<UserVO>> login(String username, String password) async {
    User? user = await _userDao.findByUsername(username);
    if (user == null) {
      return OperateResult.failWithMessage(message: '用户名或密码错误');
    }
    if (!await verifyPassword(user, password)) {
      return OperateResult.failWithMessage(
        message: '用户名或密码错误',
      );
    }
    return OperateResult.success(UserVO.fromUser(user: user));
  }

  /// 用户注册
  Future<OperateResult<UserVO>> register({
    String? userId,
    required String username,
    required String password,
    required String? nickname,
    String? email,
    String? phone,
  }) async {
    try {
      // 检查用户名是否已存在
      if (await _userDao.isUsernameExists(username)) {
        return OperateResult.failWithMessage(message: '用户名已存在');
      }
      userId = userId ?? generateUuid();
      final hashedPassword = encryptPassword(password);
      await _userDao.createUser(
        id: userId,
        username: username,
        password: hashedPassword,
        nickname: nickname ?? generateNickname(),
        inviteCode: generateInviteCode(),
        email: email,
        phone: phone,
      );
      return await getUserInfo(userId);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '注册失败：$e',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取用户信息
  Future<OperateResult<UserVO>> getUserInfo(String id) async {
    try {
      final user = await _userDao.findById(id);
      if (user == null) {
        return OperateResult.failWithMessage(message: '用户不存在');
      }
      return OperateResult.success(UserVO.fromUser(user: user));
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取用户信息失败：$e',
        exception: e is Exception ? e : Exception(e.toString()),
      );
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
        return OperateResult.failWithMessage(message: '用户不存在');
      }

      await _userDao.update(
          id,
          UserTable.toUpdateCompanion(
            nickname: nickname,
            email: email,
            phone: phone,
            timezone: timezone,
          ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '更新用户信息失败：$e',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 验证密码
  Future<bool> verifyPassword(User user, String password) async {
    final hashedPassword = encryptPassword(password);
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
        return OperateResult.failWithMessage(message: '用户不存在');
      }

      // 验证旧密码
      if (!await verifyPassword(user, oldPassword)) {
        return OperateResult.failWithMessage(message: '旧密码错误');
      }

      // 对新密码进行哈希
      final hashedNewPassword = encryptPassword(newPassword);

      await _userDao.update(
          id,
          UserTable.toUpdateCompanion(
            password: hashedNewPassword,
          ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '修改密码失败：$e',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 生成邀请码
  String generateInviteCode() {
    return IdUtil.genNanoId6();
  }

  /// 生成昵称
  String generateNickname() {
    return 'clsswjz_${IdUtil.genNanoId8()}';
  }
}
