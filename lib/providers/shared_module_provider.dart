import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../enums/operate_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/user_share_vo.dart';

/// 模块共享 Provider
class SharedModuleProvider extends ChangeNotifier {
  /// 我共享出去的完整记录（用于查找 shareId 和状态判断）
  List<UserShareVO> _myShareList = [];
  List<UserShareVO> get myShareList => _myShareList;

  /// 我共享出去的配置：businessType → [targetUserId]
  Map<String, List<String>> get myShares => _groupBy(_myShareList, false);

  /// 我被共享的模块：businessType → [ownerUserId]
  Map<String, List<String>> get sharedToMe => _groupBy(_sharedToList, true);

  List<UserShareVO> _sharedToList = [];

  bool _loading = false;
  bool get loading => _loading;

  /// 加载所有共享数据
  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;

    final myResult = await DriverFactory.driver.listUserShares(userId);
    if (myResult.ok) {
      _myShareList = myResult.data ?? [];
    }

    final sharedResult =
        await DriverFactory.driver.listUserSharesByTarget(userId);
    if (sharedResult.ok) {
      _sharedToList = sharedResult.data ?? [];
    }

    _loading = false;
    notifyListeners();
  }

  /// 设置共享开关
  Future<bool> setShare(String targetUserId, String businessType,
      {required bool enabled}) async {
    final result = await DriverFactory.driver.setUserShare(
      AppConfigManager.instance.userId,
      targetUserId: targetUserId,
      businessType: businessType,
      isEnabled: enabled,
    );
    if (!result.ok) return false;
    await loadAll();
    EventBus.instance.emit(UserShareChangedEvent(
        enabled ? OperateType.create : OperateType.update));
    return true;
  }

  /// 判断当前用户是否将指定模块共享给了某用户
  bool isSharedTo(String targetUserId, String businessType) {
    return _myShareList.any(
      (s) => s.targetUserId == targetUserId && s.businessType == businessType,
    );
  }

  /// 获取指定模块共享给当前用户的所有者 ID 列表
  List<String> getSharedBy(String businessType) {
    return _sharedToList
        .where((s) => s.businessType == businessType)
        .map((s) => s.ownerUserId)
        .toList();
  }

  Map<String, List<String>> _groupBy(
      List<UserShareVO> shares, bool isTarget) {
    final result = <String, List<String>>{};
    for (final s in shares) {
      result.putIfAbsent(s.businessType, () => []).add(
          isTarget ? s.ownerUserId : s.targetUserId);
    }
    return result;
  }
}
