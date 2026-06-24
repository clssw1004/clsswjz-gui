import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../enums/operate_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_bookkeeping_rule.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/bookkeeping_rule_vo.dart';

/// 记账规则状态管理
class BookkeepingRuleProvider extends ChangeNotifier {
  final List<BookkeepingRuleVO> _rules = [];
  bool _loading = false;
  String? _error;

  List<BookkeepingRuleVO> get rules => _rules;
  bool get loading => _loading;
  String? get error => _error;

  /// 加载当前账本的规则列表
  Future<void> loadRules(String bookId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listBookkeepingRules(
        AppConfigManager.instance.userId,
        bookId,
      );
      if (result.ok) {
        _rules.clear();
        _rules.addAll(result.data ?? []);
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = '加载失败：$e';
    }

    _loading = false;
    notifyListeners();
  }

  /// 创建规则
  Future<OperateResult<String>> createRule(
    String bookId, {
    required String name,
    required bool isActive,
    required int priority,
    required String conditionsJson,
    required String actionsJson,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.createBookkeepingRule(
      userId, bookId,
      name: name,
      isActive: isActive,
      priority: priority,
      conditionsJson: conditionsJson,
      actionsJson: actionsJson,
    );
    if (result.ok) {
      await loadRules(bookId);
      final rule = getRuleById(result.data!);
      if (rule != null) {
        EventBus.instance.emit(BookkeepingRuleChangedEvent(OperateType.create, rule));
      }
    }
    return result;
  }

  /// 更新规则
  Future<OperateResult<void>> updateRule(
    String ruleId, {
    String? name,
    bool? isActive,
    int? priority,
    String? conditionsJson,
    String? actionsJson,
    String? bookId,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updateBookkeepingRule(
      userId, ruleId,
      name: name,
      isActive: isActive,
      priority: priority,
      conditionsJson: conditionsJson,
      actionsJson: actionsJson,
    );
    if (result.ok) {
      if (bookId != null) await loadRules(bookId);
      final rule = getRuleById(ruleId);
      if (rule != null) {
        EventBus.instance.emit(BookkeepingRuleChangedEvent(OperateType.update, rule));
      }
    }
    return result;
  }

  /// 删除规则
  Future<OperateResult<void>> deleteRule(String ruleId, {String? bookId}) async {
    final userId = AppConfigManager.instance.userId;
    final rule = getRuleById(ruleId);

    final result = await DriverFactory.driver.deleteBookkeepingRule(userId, ruleId);
    if (result.ok) {
      if (bookId != null) await loadRules(bookId);
      if (rule != null) {
        EventBus.instance.emit(BookkeepingRuleChangedEvent(OperateType.delete, rule));
      }
    }
    return result;
  }

  /// 根据ID获取规则
  BookkeepingRuleVO? getRuleById(String id) {
    try {
      return _rules.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
