import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../enums/operate_type.dart';
import '../manager/l10n_manager.dart';
import '../enums/symbol_type.dart';
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

  // 引用数据（用于名称解析）
  final Map<String, String> _categoryNames = {};
  final Map<String, String> _fundNames = {};
  final Map<String, String> _shopNames = {};
  final Map<String, String> _tagNames = {};
  final Map<String, String> _projectNames = {};

  List<BookkeepingRuleVO> get rules => _rules;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, String> get categoryNames => _categoryNames;
  Map<String, String> get fundNames => _fundNames;
  Map<String, String> get shopNames => _shopNames;
  Map<String, String> get tagNames => _tagNames;
  Map<String, String> get projectNames => _projectNames;

  /// 加载当前账本的规则列表及引用数据
  Future<void> loadRules(String bookId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = AppConfigManager.instance.userId;
      final rulesResult = await DriverFactory.driver.listBookkeepingRules(userId, bookId);
      final catsResult = await DriverFactory.driver.listCategoriesByBook(userId, bookId);
      final fundsResult = await DriverFactory.driver.listFundsByBook(userId, bookId);
      final shopsResult = await DriverFactory.driver.listShopsByBook(userId, bookId);
      final tagsResult = await DriverFactory.driver.listSymbolsByBook(userId, bookId, symbolType: SymbolType.tag);
      final projectsResult = await DriverFactory.driver.listSymbolsByBook(userId, bookId, symbolType: SymbolType.project);

      if (rulesResult.ok) {
        _rules.clear();
        _rules.addAll(rulesResult.data ?? []);
      } else {
        _error = rulesResult.message;
      }
      _categoryNames.clear();
      for (final c in (catsResult.data ?? [])) {
        _categoryNames[c.code] = c.name;
      }
      _fundNames.clear();
      for (final f in (fundsResult.data ?? [])) {
        _fundNames[f.id] = f.name;
      }
      _shopNames.clear();
      for (final s in (shopsResult.data ?? [])) {
        _shopNames[s.code] = s.name;
      }
      _tagNames.clear();
      for (final s in (tagsResult.data ?? [])) {
        _tagNames[s.code] = s.name;
      }
      _projectNames.clear();
      for (final s in (projectsResult.data ?? [])) {
        _projectNames[s.code] = s.name;
      }
    } catch (e) {
      _error = L10nManager.l10n.bookkeepingRuleMessageLoadFailed(e.toString());
    }

    _loading = false;
    notifyListeners();
  }

  /// 解析字段值code为展示名称
  String resolveValue(String field, dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    final key = value.toString();
    switch (field) {
      case 'type':
        return switch (key) {
          'EXPENSE' => L10nManager.l10n.expense,
          'INCOME' => L10nManager.l10n.income,
          'TRANSFER' => L10nManager.l10n.transfer,
          _ => key,
        };
      case 'categoryCode':
        return _categoryNames[key] ?? key;
      case 'fundId':
        return _fundNames[key] ?? key;
      case 'shopCode':
        return _shopNames[key] ?? key;
      case 'tagCode':
        return _tagNames[key] ?? key;
      case 'projectCode':
        return _projectNames[key] ?? key;
      default:
        return key;
    }
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
