import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../manager/service_manager.dart';
import '../models/common.dart';
import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';

/// 用户信息状态管理
class UserProvider extends ChangeNotifier {
  UserProvider() {
    // 监听同步完成事件
    _subscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      refreshUserInfo();
    });
  }

  late final StreamSubscription _subscription;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  UserVO? _user;
  UserVO? get user => _user;

  UserStatisticVO? _statistic;
  UserStatisticVO? get statistic => _statistic;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// 获取用户信息
  Future<void> refreshUserInfo() async {
    try {
      final result = await DriverFactory.driver
          .getUserInfo(AppConfigManager.instance.userId);

      if (result.ok && result.data != null) {
        _user = result.data;
        // 获取用户统计信息
        ServiceManager.statisticService
            .getUserStatisticInfo(AppConfigManager.instance.userId)
            .then((statisticResult) {
          if (statisticResult.ok) {
            _statistic = statisticResult.data;
            notifyListeners();
          }
        });
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
      AppConfigManager.instance.userId,
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
    await DriverFactory.driver.updateUser(
      AppConfigManager.instance.userId,
      avatar: file,
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
      final result = await DriverFactory.driver.updateUser(
        AppConfigManager.instance.userId,
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
