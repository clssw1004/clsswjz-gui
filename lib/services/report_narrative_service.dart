import '../generated/l10n/app_localizations.dart';
import '../models/vo/monthly_report_vo.dart';

/// 报告叙事数据类
class ReportNarrative {
  /// 执行摘要（2-3句话）
  final String executiveSummary;

  /// 支出分类解读
  final String? categoryNarrative;

  /// 收入来源解读
  final String? incomeNarrative;

  /// 日均支出解读
  final String? dailyNarrative;

  /// 年度累计解读
  final String? ytdNarrative;

  /// 趋势解读
  final String? trendNarrative;

  /// 建议列表（2-4条）
  final List<String> recommendations;

  const ReportNarrative({
    required this.executiveSummary,
    this.categoryNarrative,
    this.incomeNarrative,
    this.dailyNarrative,
    this.ytdNarrative,
    this.trendNarrative,
    this.recommendations = const [],
  });
}

/// 报告叙事生成服务
/// 根据 MonthlyReportVO 数据，模板化生成分析性文字
class ReportNarrativeService {
  final AppLocalizations l10n;

  ReportNarrativeService(this.l10n);

  ReportNarrative generate(MonthlyReportVO r) {
    final summary = r.summary;
    final curExpense = summary.totalExpense.abs();
    final prevExpense = summary.prevExpense.abs();
    final curIncome = summary.totalIncome.abs();
    final prevIncome = summary.prevIncome.abs();
    final expDiff = curExpense - prevExpense; // 正=增加，负=减少
    final hasComp = summary.hasComparison;

    // ── 1. 执行摘要 ──
    final execSummary = _buildExecutiveSummary(r, curExpense, prevExpense,
        curIncome, expDiff, hasComp);

    // ── 2. 分类解读 ──
    final catNarrative = _buildCategoryNarrative(r, curExpense, hasComp);

    // ── 3. 收入解读 ──
    final incNarrative = _buildIncomeNarrative(r, curIncome, prevIncome, hasComp);

    // ── 4. 日均支出解读 ──
    final dailyNar = _buildDailyNarrative(r, curExpense);

    // ── 5. YTD 解读 ──
    final ytdNar = _buildYtdNarrative(r, curExpense);

    // ── 6. 趋势解读 ──
    final trendNar = _buildTrendNarrative(r);

    // ── 7. 建议 ──
    final recs = _buildRecommendations(r, curExpense, prevExpense,
        curIncome, prevIncome, expDiff, hasComp);

    return ReportNarrative(
      executiveSummary: execSummary,
      categoryNarrative: catNarrative,
      incomeNarrative: incNarrative,
      dailyNarrative: dailyNar,
      ytdNarrative: ytdNar,
      trendNarrative: trendNar,
      recommendations: recs,
    );
  }

  // ═══ 执行摘要 ═══

  String _buildExecutiveSummary(MonthlyReportVO r, double curExpense,
      double prevExpense, double curIncome, double expDiff, bool hasComp) {
    final buf = StringBuffer();

    // 第一句：支出变化
    if (hasComp && prevExpense > 0) {
      final pct = (expDiff / prevExpense * 100).toStringAsFixed(1);
      if (expDiff < -0.01) {
        // 减少
        buf.write(l10n.narrativeExpenseDecrease(
            curExpense.toStringAsFixed(0),
            expDiff.abs().toStringAsFixed(0), pct));
      } else if (expDiff > 0.01) {
        buf.write(l10n.narrativeExpenseIncrease(
            curExpense.toStringAsFixed(0),
            expDiff.toStringAsFixed(0), pct));
      } else {
        buf.write(l10n.narrativeExpenseStable(
            curExpense.toStringAsFixed(0),
            expDiff.toStringAsFixed(0), pct));
      }
    } else {
      buf.write(l10n.narrativeNoPrevData);
    }

    // 第二句：主要驱动因素
    if (hasComp && r.categoryExpenses.isNotEmpty) {
      final top = r.categoryExpenses.first;
      final topDiff = top.amount - top.prevAmount;
      if (topDiff.abs() > 5) {
        if (topDiff > 0) {
          buf.write(l10n.narrativeDriverIncrease(
              topDiff.toStringAsFixed(0), top.categoryName));
        } else {
          buf.write(l10n.narrativeDriverDecrease(
              topDiff.abs().toStringAsFixed(0), top.categoryName));
        }
      }
    }

    // 第三句：储蓄率评估
    if (r.savingsRate >= 30) {
      buf.write(l10n.narrativeSavingsExcellent(
          r.savingsRate.toStringAsFixed(1)));
    } else if (r.savingsRate >= 20) {
      buf.write(l10n.narrativeSavingsGood(
          r.savingsRate.toStringAsFixed(1)));
    } else if (r.savingsRate >= 10) {
      buf.write(l10n.narrativeSavingsFair(
          r.savingsRate.toStringAsFixed(1)));
    } else {
      buf.write(l10n.narrativeSavingsPoor(
          r.savingsRate.toStringAsFixed(1)));
    }

    // 第四句：最值得关注的问题
    final warnings = r.alerts.where((a) => a.severity == 'warning').toList();
    if (warnings.isNotEmpty) {
      final w = warnings.first;
      if (w.type == 'overThreshold' && w.exceededAmount != null) {
        buf.write(l10n.narrativeConcernThreshold(
            w.exceededAmount!.toStringAsFixed(0), w.categoryName));
      } else if (w.type == 'abnormalGrowth' && w.diffPercent != null) {
        buf.write(l10n.narrativeConcernGrowth(
            w.diffPercent!.toStringAsFixed(1), w.categoryName));
      }
    } else if (curExpense > curIncome) {
      buf.write(l10n.narrativeConcernDeficit);
    } else {
      buf.write(l10n.narrativeNoConcern);
    }

    return buf.toString();
  }

  // ═══ 分类解读 ═══

  String? _buildCategoryNarrative(MonthlyReportVO r, double curExpense, bool hasComp) {
    if (r.categoryExpenses.isEmpty) return null;
    final top = r.categoryExpenses.first;
    final pct = curExpense > 0 ? (top.amount / curExpense * 100) : 0.0;
    final pctDiff = top.prevAmount > 0
        ? ((top.amount - top.prevAmount) / top.prevAmount * 100)
        : 0.0;
    final diff = top.amount - top.prevAmount;

    if (hasComp && top.prevAmount > 0) {
      if (diff.abs() > 5) {
        if (diff > 0) {
          return l10n.narrativeCategoryTop(top.categoryName,
              top.amount.toStringAsFixed(0), pct.toStringAsFixed(1),
              diff.toStringAsFixed(0), pctDiff.toStringAsFixed(1));
        } else {
          return l10n.narrativeCategoryTopDown(top.categoryName,
              top.amount.toStringAsFixed(0), pct.toStringAsFixed(1),
              diff.abs().toStringAsFixed(0), pctDiff.abs().toStringAsFixed(1));
        }
      }
    }
    return l10n.narrativeCategoryTopStable(top.categoryName,
        top.amount.toStringAsFixed(0), pct.toStringAsFixed(1));
  }

  // ═══ 收入解读 ═══

  String? _buildIncomeNarrative(MonthlyReportVO r, double curIncome, double prevIncome, bool hasComp) {
    if (r.categoryIncomes.isEmpty) return null;
    final top = r.categoryIncomes.first;
    final pct = curIncome > 0 ? (top.amount / curIncome * 100) : 0.0;
    final result = l10n.narrativeIncomeTop(top.categoryName,
        top.amount.toStringAsFixed(0), pct.toStringAsFixed(1));

    final incomeDiff = curIncome - prevIncome;
    if (hasComp && prevIncome > 0) {
      final ipct = (incomeDiff / prevIncome * 100).toStringAsFixed(1);
      if (incomeDiff.abs() > 5) {
        if (incomeDiff > 0) {
          return '$result${l10n.narrativeIncomeChangeUp(incomeDiff.toStringAsFixed(0), ipct)}';
        } else {
          return '$result${l10n.narrativeIncomeChangeDown(incomeDiff.abs().toStringAsFixed(0), ipct)}';
        }
      }
      return '$result${l10n.narrativeIncomeChangeStable}';
    }
    return result;
  }

  // ═══ 日均支出解读 ═══

  String? _buildDailyNarrative(MonthlyReportVO r, double curExpense) {
    if (r.dailyAmounts.isEmpty) return null;
    final daysWithData = r.dailyAmounts.where((d) => d > 0).length;
    if (daysWithData == 0) return null;
    final dailyAvg = curExpense / daysWithData;

    if (r.ytdSummary != null) {
      final ytdAvg = r.ytdSummary!.monthlyAvgExpense;
      if (dailyAvg < ytdAvg) {
        return l10n.narrativeDailyBelowAvg(
            dailyAvg.toStringAsFixed(1), ytdAvg.toStringAsFixed(1));
      } else {
        return l10n.narrativeDailyAboveAvg(
            dailyAvg.toStringAsFixed(1), ytdAvg.toStringAsFixed(1));
      }
    }
    return l10n.narrativeDailyNoYtd(dailyAvg.toStringAsFixed(1));
  }

  // ═══ YTD 解读 ═══

  String? _buildYtdNarrative(MonthlyReportVO r, double curExpense) {
    if (r.ytdSummary == null) return null;
    final ytd = r.ytdSummary!;
    final ytdAvg = ytd.monthlyAvgExpense;

    final buf = StringBuffer();
    if (curExpense > ytdAvg) {
      buf.write(l10n.narrativeYtdAbove(ytdAvg.toStringAsFixed(0)));
    } else {
      buf.write(l10n.narrativeYtdBelow(ytdAvg.toStringAsFixed(0)));
    }
    buf.write(l10n.narrativeYtdSavings(
        ytd.savingsRate.toStringAsFixed(1),
        ytd.monthsWithData, ytd.monthCount));
    return buf.toString();
  }

  // ═══ 趋势解读 ═══

  String? _buildTrendNarrative(MonthlyReportVO r) {
    if (r.monthlyTrend.length < 2) return null;

    final first = r.monthlyTrend.first.expense;
    final last = r.monthlyTrend.last.expense;
    final diff = last - first;

    final buf = StringBuffer();
    if (diff > first * 0.1) {
      buf.write(l10n.narrativeTrendUp);
    } else if (diff < -first * 0.1) {
      buf.write(l10n.narrativeTrendDown);
    } else {
      buf.write(l10n.narrativeTrendStable);
    }

    // 最高月
    final peak = r.monthlyTrend.reduce(
        (a, b) => a.expense > b.expense ? a : b);
    buf.write(l10n.narrativeTrendPeak(
        '${peak.month}月', peak.expense.toStringAsFixed(0)));

    return buf.toString();
  }

  // ═══ 建议列表 ═══

  List<String> _buildRecommendations(MonthlyReportVO r, double curExpense,
      double prevExpense, double curIncome, double prevIncome,
      double expDiff, bool hasComp) {
    final recs = <String>[];

    // 1. 超阈值分类 → 预算建议
    for (final a in r.alerts) {
      if (a.type == 'overThreshold' && a.exceededAmount != null) {
        recs.add(l10n.recommendBudgetCap(
            a.categoryName, a.exceededAmount!.toStringAsFixed(0)));
      }
    }

    // 2. 异常增长 → 回顾建议
    for (final a in r.alerts) {
      if (a.type == 'abnormalGrowth' && a.diffPercent != null) {
        recs.add(l10n.recommendReviewGrowth(
            a.categoryName, a.diffPercent!.toStringAsFixed(1)));
      }
    }

    // 3. 储蓄率偏低
    if (r.savingsRate < 20 && r.savingsRate > 0) {
      recs.add(l10n.recommendIncreaseSavings(
          r.savingsRate.toStringAsFixed(1)));
    }

    // 4. 收入下降
    if (hasComp && curIncome < prevIncome && prevIncome > 0) {
      final incomeDiff = prevIncome - curIncome;
      recs.add(l10n.recommendMonitorIncome(
          incomeDiff.toStringAsFixed(0)));
    }

    // 5. 新增分类
    for (final a in r.alerts) {
      if (a.type == 'newCategory' && a.exceededAmount != null) {
        recs.add(l10n.recommendNewCategory(
            a.categoryName, a.exceededAmount!.toStringAsFixed(0)));
      }
    }

    // 6. 消失分类
    for (final a in r.alerts) {
      if (a.type == 'disappearedCategory' && a.exceededAmount != null) {
        recs.add(l10n.recommendDisappearedCategory(
            a.categoryName, a.exceededAmount!.toStringAsFixed(0)));
      }
    }

    // 7. 分类过多
    if (r.categoryExpenses.length >= 8) {
      recs.add(l10n.recommendSimplifyCats(
          r.categoryExpenses.length.toString()));
    }

    // 如果没有预警和问题，正向鼓励
    if (recs.isEmpty) {
      recs.add(l10n.recommendKeepGood);
    }

    // 最多返回4条
    return recs.take(4).toList();
  }
}
