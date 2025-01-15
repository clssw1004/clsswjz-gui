import 'dart:io';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../manager/service_manager.dart';
import '../manager/user_config_manager.dart';
import '../models/common.dart';
import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';

/// 用户信息状态管理
class UserProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  UserVO? _user;
  UserVO? get user => _user;

  UserStatisticVO? _statistic;
  UserStatisticVO? get statistic => _statistic;

  /// 获取用户信息
  Future<void> refreshUserInfo() async {
    try {
      final result = await ServiceManager.userService.getUserInfo(UserConfigManager.currentUserId);

      if (result.ok && result.data != null) {
        _user = result.data;
        // 获取用户统计信息
        final statisticResult = await ServiceManager.statisticService.getUserStatisticInfo(UserConfigManager.currentUserId);
        if (statisticResult.ok) {
          _statistic = statisticResult.data;
        }
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = '获取用户信息失败：$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 更新用户信息
  Future<void> updateUserInfo({
    String? nickname,
    String? email,
    String? phone,
    String? timezone,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await DriverFactory.driver.updateUser(
      UserConfigManager.currentUserId,
      nickname: nickname,
      email: email,
      phone: phone,
      timezone: timezone,
    );
    if (result.ok) {
      await refreshUserInfo();
    } else {
      _error = result.message;
    }
    _loading = false;
    notifyListeners();
  }

  /// 更新头像
  Future<void> updateAvatar(File file) async {
    final result = await ServiceManager.userService.updateAvatar(
      id: UserConfigManager.currentUserId,
      file: file,
    );
    await refreshUserInfo();
  }

  /// 修改密码
  Future<OperateResult<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_loading) {
      return OperateResult.failWithMessage(message: '正在处理中', exception: null);
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ServiceManager.userService.changePassword(
        id: UserConfigManager.currentUserId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return result;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
