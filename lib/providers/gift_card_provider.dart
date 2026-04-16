import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../database/database.dart';
import '../database/tables/gift_card_table.dart';
import '../drivers/data_driver.dart';
import '../enums/gift_card_status.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';
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
    final toUser = await DaoManager.userDao.findById(toUserId);

    if (toUser == null) {
      return OperateResult.failWithMessage(message: '接收人不存在');
    }

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

    final companion = GiftCardTable.toCreateCompanion(
      userId,
      fromUserId: userId,
      toUserId: toUserId,
      description: description,
      expiredTime: finalExpiredTime,
    );

    try {
      // 从companion中获取预生成的ID
      final id = companion.id.value;
      await DaoManager.giftCardDao.insert(companion);
      await loadGiftCards();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(message: '创建失败: $e');
    }
  }

  /// 更新礼物卡（草稿状态可修改）
  Future<OperateResult<void>> updateGiftCard({
    required String id,
    String? toUserId,
    String? description,
    int? expiredTime,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    // 只有草稿状态可以修改内容
    if (card.status != GiftCardStatus.draft.code) {
      return OperateResult.failWithMessage(message: '当前状态不可修改');
    }

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

    final companion = GiftCardTable.toUpdateCompanion(
      userId,
      toUserId: toUserId,
      description: description,
      expiredTime: finalExpiredTime,
    );

    try {
      await DaoManager.giftCardDao.update(id, companion);
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '更新失败: $e');
    }
  }

  /// 送出礼物卡
  Future<OperateResult<void>> sendGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    if (card.status != GiftCardStatus.draft.code) {
      return OperateResult.failWithMessage(message: '只能送出草稿状态的礼物卡');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await DaoManager.giftCardDao.update(
        id,
        GiftCardTableCompanion(
          status: Value(GiftCardStatus.sent.code),
          sentTime: Value(now),
          updatedBy: Value(userId),
          updatedAt: Value(now),
        ),
      );
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '操作失败: $e');
    }
  }

  /// 接收礼物卡（需要当前用户是接收人）
  Future<OperateResult<void>> receiveGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    // 检查当前用户是否是接收人
    if (card.toUserId != userId) {
      return OperateResult.failWithMessage(message: '只有接收人才能接收礼物卡');
    }

    if (card.status != GiftCardStatus.sent.code) {
      return OperateResult.failWithMessage(message: '只能接收已送出的礼物卡');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await DaoManager.giftCardDao.update(
        id,
        GiftCardTableCompanion(
          status: Value(GiftCardStatus.received.code),
          receivedTime: Value(now),
          updatedBy: Value(userId),
          updatedAt: Value(now),
        ),
      );
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '操作失败: $e');
    }
  }

  /// 延期礼物卡
  Future<OperateResult<void>> extendGiftCard(String id, int expiredTime) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    // 已使用和已作废的不能延期
    if (card.status == GiftCardStatus.used.code ||
        card.status == GiftCardStatus.voided.code) {
      return OperateResult.failWithMessage(message: '当前状态不可延期');
    }

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

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await DaoManager.giftCardDao.update(
        id,
        GiftCardTableCompanion(
          expiredTime: Value(finalExpiredTime),
          updatedBy: Value(userId),
          updatedAt: Value(now),
        ),
      );
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '操作失败: $e');
    }
  }

  /// 标记为已使用（需要当前用户是接收人）
  Future<OperateResult<void>> markAsUsed(String id) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    // 检查当前用户是否是接收人
    if (card.toUserId != userId) {
      return OperateResult.failWithMessage(message: '只有接收人才能标记礼物卡');
    }

    if (card.status != GiftCardStatus.received.code) {
      return OperateResult.failWithMessage(message: '只能标记已接收的礼物卡为已使用');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await DaoManager.giftCardDao.update(
        id,
        GiftCardTableCompanion(
          status: Value(GiftCardStatus.used.code),
          updatedBy: Value(userId),
          updatedAt: Value(now),
        ),
      );
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '操作失败: $e');
    }
  }

  /// 作废礼物卡（需要当前用户是赠送人或接收人）
  Future<OperateResult<void>> voidGiftCard(String id) async {
    final userId = AppConfigManager.instance.userId;
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    // 检查当前用户是否是赠送人或接收人
    if (card.fromUserId != userId && card.toUserId != userId) {
      return OperateResult.failWithMessage(message: '只有赠送人或接收人才能作废礼物卡');
    }

    // 已使用和已作废的不能再次作废
    if (card.status == GiftCardStatus.used.code ||
        card.status == GiftCardStatus.voided.code) {
      return OperateResult.failWithMessage(message: '当前状态不可作废');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await DaoManager.giftCardDao.update(
        id,
        GiftCardTableCompanion(
          status: Value(GiftCardStatus.voided.code),
          updatedBy: Value(userId),
          updatedAt: Value(now),
        ),
      );
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '操作失败: $e');
    }
  }

  /// 删除礼物卡（只能删除草稿状态的）
  Future<OperateResult<void>> deleteGiftCard(String id) async {
    final card = await DaoManager.giftCardDao.findById(id);

    if (card == null) {
      return OperateResult.failWithMessage(message: '礼物卡不存在');
    }

    if (card.status != GiftCardStatus.draft.code) {
      return OperateResult.failWithMessage(message: '只能删除草稿状态的礼物卡');
    }

    try {
      await DaoManager.giftCardDao.delete(id);
      await loadGiftCards();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '删除失败: $e');
    }
  }

  /// 根据邀请码查找用户
  Future<OperateResult<({String userId, String nickname})>> findUserByInviteCode(String inviteCode) async {
    try {
      final user = await DaoManager.userDao.findByInviteCode(inviteCode);
      if (user == null) {
        return OperateResult.failWithMessage(message: '邀请码无效');
      }
      return OperateResult.success((
        userId: user.id,
        nickname: user.nickname ?? user.username ?? '未知用户',
      ));
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
  Future<List<({String userId, String nickname})>> getSelectableRecipients() async {
    final userId = AppConfigManager.instance.userId;
    final users = await DaoManager.userDao.findSelectableRecipients(userId);

    return users
        .map((u) => (
              userId: u.id,
              nickname: u.nickname ?? u.username ?? '未知用户',
            ))
        .toList();
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