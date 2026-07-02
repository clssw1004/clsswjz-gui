import '../database/database.dart';
import '../manager/dao_manager.dart';

/// 智能排序评分服务
///
/// 根据历史账目数据对分类/商户评分，用于"推荐"视图排序。
/// 评分维度：频率 + 冷静期 + 时段模式 + 金额相似度。
class SmartSortService {
  /// 获取近 [days] 天内的历史账目，默认 30 天
  static Future<List<AccountItem>> loadRecentItems(
    String bookId, {
    int days = 30,
  }) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    return await DaoManager.itemDao.listRecentByDate(bookId, startStr);
  }

  /// 对分类列表计算智能评分，keyed by 分类 id
  static Map<String, double> computeCategoryScores({
    required List<AccountItem> recentItems,
    required List<AccountCategory> categories,
    required double currentAmount,
    required DateTime currentTime,
  }) {
    // 按 categoryCode 分组
    final itemsByCode = <String, List<AccountItem>>{};
    for (final item in recentItems) {
      if (item.categoryCode == null || item.categoryCode!.isEmpty) continue;
      itemsByCode
          .putIfAbsent(item.categoryCode!, () => [])
          .add(item);
    }

    final scores = <String, double>{};
    for (final cat in categories) {
      final items = itemsByCode[cat.code] ?? [];
      scores[cat.code] = _compute(items, currentAmount, currentTime);
    }
    return scores;
  }

  /// 对商户列表计算智能评分，keyed by 商户 code
  static Map<String, double> computeShopScores({
    required List<AccountItem> recentItems,
    required List<AccountShop> shops,
    required double currentAmount,
    required DateTime currentTime,
  }) {
    final itemsByCode = <String, List<AccountItem>>{};
    for (final item in recentItems) {
      if (item.shopCode == null || item.shopCode!.isEmpty) continue;
      itemsByCode.putIfAbsent(item.shopCode!, () => []).add(item);
    }

    final scores = <String, double>{};
    for (final shop in shops) {
      final items = itemsByCode[shop.code] ?? [];
      scores[shop.code] = _compute(items, currentAmount, currentTime);
    }
    return scores;
  }

  /// 核心评分算法
  static double _compute(
    List<AccountItem> items,
    double currentAmount,
    DateTime currentTime,
  ) {
    if (items.isEmpty) return 0;

    double score = 0;

    // 1. 频率 (0-20) — 历史使用次数越多分越高
    score += (items.length * 2).clamp(0, 20).toDouble();

    // 2. 冷静期 (0-25) — 刚用过的短期冷静，1~7 天达峰后衰减
    final sorted = List<AccountItem>.from(items)
      ..sort((a, b) => b.accountDate.compareTo(a.accountDate));
    final latestStr = sorted.first.accountDate;
    try {
      final lastUsed = DateTime.parse(latestStr.replaceFirst(' ', 'T'));
      final hoursSince =
          currentTime.difference(lastUsed).inHours.toDouble();
      if (hoursSince < 1) {
        score += 5; // 刚用过，冷却中
      } else if (hoursSince < 24) {
        score += 5 + 20 * (hoursSince / 24); // 1~24h 线性恢复
      } else if (hoursSince < 168) {
        score += 25; // 1~7天高峰期
      } else {
        score += 25 *
            (1 - ((hoursSince - 168) / 720)).clamp(0, 1).toDouble(); // 衰减
      }
    } catch (_) {}

    // 3. 时段模式 (0-25) — 当前小时 ±2h 内使用越多分越高
    final currentHour = currentTime.hour;
    int sameTimeCount = 0;
    for (final h in items) {
      try {
        final dt = DateTime.parse(h.accountDate.replaceFirst(' ', 'T'));
        if ((dt.hour - currentHour).abs() <= 2) {
          sameTimeCount++;
        }
      } catch (_) {}
    }
    score += (sameTimeCount * 5).clamp(0, 25).toDouble();

    // 4. 金额相似度 (0-30) — 仅当前金额 > 0 时生效
    if (currentAmount > 0) {
      final absAmount = currentAmount.abs();
      double closestDiff = double.infinity;
      for (final h in items) {
        final diff = (h.amount.abs() - absAmount).abs();
        if (diff < closestDiff) closestDiff = diff;
      }
      final ratio = closestDiff / absAmount;
      if (ratio < 0.1) {
        score += 30;
      } else if (ratio < 0.25) {
        score += 20;
      } else if (ratio < 0.5) {
        score += 10;
      } else {
        score += 3;
      }
    }

    return score;
  }
}
