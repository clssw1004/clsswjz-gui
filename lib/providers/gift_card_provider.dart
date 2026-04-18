import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/gift_card.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_book.dart';
import 'package:clsswjz_gui/manager/dao_manager.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../enums/gift_card_status.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/gift_card_vo.dart';

/// 礼物卡数据提供者
class GiftCardProvider extends ChangeNotifier {
  /// 我收到的礼物卡列表
  final List<GiftCardVO> _receivedGiftCards = [];

  /// 我送出的礼物卡列表
  final List<GiftCardVO> _sentGiftCards = [];

  /// 当前选中的Tab索引 (0: 我收到的, 1: 我送出的)
  int _selectedTabIndex = 0;

  /// 获取我收到的礼物卡列表
  List<GiftCardVO> get receivedGiftCards => _receivedGiftCards;

  /// 获取我送出的礼物卡列表
  List<GiftCardVO> get sentGiftCards => _sentGiftCards;

  /// 获取当前选中的Tab索引
  int get selectedTabIndex => _selectedTabIndex;

  /// 获取是否正在加载
  bool get loading => false; // 简化处理

  /// 获取当前显示的列表
  List<GiftCardVO> get currentGiftCards {
    return _selectedTabIndex == 0 ? _receivedGiftCards : _sentGiftCards;
  }

  /// 设置选中的Tab索引
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// 加载我收到的礼物卡
  Future<void> loadReceivedGiftCards() async {
    try {
      final result = await DriverFactory.driver.listGiftCards(
        AppConfigManager.instance.userId,
        type: GiftCardQueryType.received,
      );
      if (result.ok) {
        _receivedGiftCards.clear();
        _receivedGiftCards.addAll(result.data ?? []);
        notifyListeners();
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 加载我送出的礼物卡
  Future<void> loadSentGiftCards() async {
    try {
      final result = await DriverFactory.driver.listGiftCards(
        AppConfigManager.instance.userId,
        type: GiftCardQueryType.sent,
      );
      if (result.ok) {
        _sentGiftCards.clear();
        _sentGiftCards.addAll(result.data ?? []);
        notifyListeners();
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 加载所有礼物卡
  Future<void> loadGiftCards() async {
    await Future.wait([
      loadReceivedGiftCards(),
      loadSentGiftCards(),
    ]);
  }

  /// 创建礼物卡
  Future<OperateResult<String>> createGiftCard({
    required String toUserId,
    String? description,
    int? expiredTime,
  }) async {
    final userId = AppConfigManager.instance.userId;

    // 处理过期时间：如果选择了日期，设置为当天23:59:59
    int? finalExpiredTime;
    if (expiredTime != null && expiredTime > 0) {
      final expiredDate = DateTime.fromMillisecondsSinceEpoch(expiredTime);
      finalExpiredTime = DateTime(
        expiredDate.year,
        expiredDate.month,
        expiredDate.day,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;
    }

    final result = await DriverFactory.driver.createGiftCard(
      userId,
      toUserId: toUserId,
      description: description,
      expiredTime: finalExpiredTime,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(result.data!);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.create, card));
      }
    }
    return result;
  }

  /// 更新礼物卡（草稿状态可修改）
  Future<OperateResult<void>> updateGiftCard({
    required String id,
    String? toUserId,
    String? description,
    int? expiredTime,
  }) async {
    final userId = AppConfigManager.instance.userId;

    // 处理过期时间
    int? finalExpiredTime;
    if (expiredTime != null && expiredTime > 0) {
      final expiredDate = DateTime.fromMillisecondsSinceEpoch(expiredTime);
      finalExpiredTime = DateTime(
        expiredDate.year,
        expiredDate.month,
        expiredDate.day,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;
    }

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      toUserId: toUserId,
      description: description,
      expiredTime: finalExpiredTime,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 送出礼物卡
  Future<OperateResult<void>> sendGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      status: GiftCardStatus.sent.code,
      expiredTime: 0, // 清除过期时间，使用永久有效
      sentTime: now,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 接收礼物卡（需要当前用户是接收人）
  Future<OperateResult<void>> receiveGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      status: GiftCardStatus.received.code,
      receivedTime: now,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 延期礼物卡
  Future<OperateResult<void>> extendGiftCard(String id, int expiredTime) async {
    final userId = AppConfigManager.instance.userId;

    // 处理过期时间：设置为当天23:59:59
    final expiredDate = DateTime.fromMillisecondsSinceEpoch(expiredTime);
    final finalExpiredTime = DateTime(
      expiredDate.year,
      expiredDate.month,
      expiredDate.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      expiredTime: finalExpiredTime,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 标记为已使用（需要当前用户是赠送人）
  Future<OperateResult<void>> markAsUsed(String id) async {
    final userId = AppConfigManager.instance.userId;

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      status: GiftCardStatus.used.code,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 作废礼物卡（需要当前用户是赠送人）
  Future<OperateResult<void>> voidGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;

    final result = await DriverFactory.driver.updateGiftCard(
      userId,
      id,
      status: GiftCardStatus.voided.code,
    );
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
      }
    }
    return result;
  }

  /// 删除礼物卡（只能删除草稿状态的）
  Future<OperateResult<void>> deleteGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;

    final result = await DriverFactory.driver.deleteGiftCard(userId, id);
    if (result.ok) {
      await loadGiftCards();
      // 触发同步
      final card = getGiftCardById(id);
      if (card != null) {
        EventBus.instance.emit(GiftCardChangedEvent(OperateType.delete, card));
      }
    }
    return result;
  }

  /// 根据邀请码查找用户
  Future<OperateResult<User>> findUserByInviteCode(String inviteCode) async {
    try {
      final user = await DaoManager.userDao.findByInviteCode(inviteCode);
      
      return OperateResult.success(user);
    } catch (e) {
      return OperateResult.failWithMessage(message: '查找失败: $e');
    }
  }

  /// 根据ID获取礼物卡
  GiftCardVO? getGiftCardById(String id) {
    try {
      return _receivedGiftCards.firstWhere((card) => card.id == id);
    } catch (e) {
      try {
        return _sentGiftCards.firstWhere((card) => card.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// 获取当前用户可选择的接收人列表（从账本关联成员中获取，去重、去掉自己）
  Future<List<User>> getSelectableRecipients() async {
    
    return DaoManager.userDao.findSelectableRecipients(AppConfigManager.instance.userId);
  }

  /// 获取礼物卡详情
  Future<GiftCardVO?> getGiftCardDetail(String giftCardId) async {
    final result = await DriverFactory.driver.getGiftCard(
      AppConfigManager.instance.userId,
      giftCardId,
    );
    return result.data;
  }
}