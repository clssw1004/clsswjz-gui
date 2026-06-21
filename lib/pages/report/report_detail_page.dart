import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../utils/date_util.dart';
import '../../widgets/common/common_app_bar.dart';

class ReportDetailPage extends StatelessWidget {
  final UserNoteVO note;
  const ReportDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final r = _parse(note.content);
    return Scaffold(
      appBar: CommonAppBar(title: Text(note.title ?? '月度报告')),
      body: r == null
          ? Center(child: Text('无法解析报告', style: Theme.of(context).textTheme.bodyLarge))
          : _Body(r: r),
    );
  }

  MonthlyReportVO? _parse(String? c) {
    try { return c != null && c.isNotEmpty
        ? MonthlyReportVO.fromJson(jsonDecode(c) as Map<String, dynamic>) : null; }
    catch (_) { return null; }
  }
}

class _Body extends StatelessWidget {
  final MonthlyReportVO r;
  const _Body({required this.r});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = r.summary;
    final hasComp = s.hasComparison;
    // 支出金额为负值，用绝对值计算变化方向
    final expAbsDiff = s.totalExpense.abs() - s.prevExpense.abs();
    final expDown = expAbsDiff < 0;
    final expDiffDisplay = expAbsDiff.abs();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ═══ HEADER ═══
        _Header(period: r.period, expenseDiffDisplay: expDiffDisplay,
            expenseDown: expDown, hasComp: hasComp, cs: cs),
        const SizedBox(height: 20),

        // ═══ KPI COMPARISON CARDS ═══
        _KpiComparisonRow(cs: cs, s: s, hasComp: hasComp),
        const SizedBox(height: 24),

        // ═══ CATEGORY DONUT CHART ═══
        if (r.categoryExpenses.isNotEmpty) ...[
          _sectionTitle(cs, '支出构成'),
          const SizedBox(height: 8),
          _CategoryDonut(categories: r.categoryExpenses),
          const SizedBox(height: 24),
        ],

        // ═══ CATEGORY COMPARISON BARS ═══
        if (r.categoryExpenses.isNotEmpty) ...[
          _sectionTitle(cs, '分类同比（本月 vs 上月）'),
          const SizedBox(height: 8),
          _CategoryComparison(categories: r.categoryExpenses, cs: cs, hasComp: hasComp),
          const SizedBox(height: 24),
        ],

        // ═══ DAILY EXPENSE CHART ═══
        if (r.dailyAmounts.isNotEmpty) ...[
          _sectionTitle(cs, '每日支出趋势'),
          const SizedBox(height: 8),
          _DailyChart(dailyAmounts: r.dailyAmounts, cs: cs),
          const SizedBox(height: 24),
        ],

        // ═══ KEY METRICS ═══
        _sectionTitle(cs, '关键指标'),
        const SizedBox(height: 10),
        _KeyMetrics(s: s, r: r, cs: cs),

        // ═══ FOOTER ═══
        const SizedBox(height: 24),
        Center(child: Text('生成于 ${DateUtil.format(r.generatedAt)}',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))),
      ],
    );
  }

  Widget _sectionTitle(ColorScheme cs, String text) {
    return Row(children: [
      Container(width: 3, height: 14,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
    ]);
  }
}

// ═══ HEADER ═══
class _Header extends StatelessWidget {
  final ReportPeriod period;
  final double expenseDiffDisplay;
  final bool expenseDown;
  final bool hasComp;
  final ColorScheme cs;
  const _Header({required this.period, required this.expenseDiffDisplay,
      required this.expenseDown, required this.hasComp, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('${period.year}.${period.month.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
      ),
      const SizedBox(width: 14),
      if (hasComp) ...[
        Text('支出', style: TextStyle(fontSize: 15, color: cs.onSurfaceVariant)),
        const SizedBox(width: 6),
        Icon(expenseDown ? Icons.arrow_downward : Icons.arrow_upward,
            size: 20, color: expenseDown ? cs.primary : cs.error),
        const SizedBox(width: 4),
        Text('¥${expenseDiffDisplay.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                color: expenseDown ? cs.primary : cs.error, fontFamily: 'monospace', height: 1.1)),
      ],
    ]);
  }
}

// ═══ KPI + COMPARISON ═══
class _KpiComparisonRow extends StatelessWidget {
  final ColorScheme cs;
  final ReportSummary s;
  final bool hasComp;
  const _KpiComparisonRow({required this.cs, required this.s, required this.hasComp});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Row 1: KPI values only
      Row(children: [
        _kpiValue(cs, '支出', s.totalExpense, cs.error),
        const SizedBox(width: 10),
        _kpiValue(cs, '收入', s.totalIncome, cs.primary),
        const SizedBox(width: 10),
        _kpiValue(cs, '结余', s.balance, cs.tertiary),
      ]),
      // Row 2: Full-width comparison
      if (hasComp) ...[
        const SizedBox(height: 10),
        _ComparisonStrip(cs: cs, s: s),
      ],
    ]);
  }

  Widget _kpiValue(ColorScheme cs, String label, double current, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('¥${current.abs().toStringAsFixed(0)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace', height: 1.1)),
        ]),
      ),
    );
  }
}

/// 全宽环比对比条
class _ComparisonStrip extends StatelessWidget {
  final ColorScheme cs;
  final ReportSummary s;
  const _ComparisonStrip({required this.cs, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        _compLine(cs, '支出', s.prevExpense, s.totalExpense),
        const SizedBox(height: 6),
        _compLine(cs, '收入', s.prevIncome, s.totalIncome),
        const SizedBox(height: 6),
        _compLine(cs, '结余', s.prevBalance, s.balance),
      ]),
    );
  }

  Widget _compLine(ColorScheme cs, String label, double prev, double current) {
    // 金额可能为负值（支出），用绝对值计算变化
    final absPrev = prev.abs();
    final absCur = current.abs();
    final absDiff = absCur - absPrev;
    final isDown = absDiff < 0; // 绝对值减少 = 降低
    final displayDiff = absDiff.abs();
    final pct = absPrev > 0 ? (displayDiff / absPrev) * 100 : 0.0;
    // 费用降低（支出减少）意味着正向变化，用 primary 色；费用升高用 error 色
    final isGoodChange = label == '支出' ? isDown : !isDown;
    final changeColor = isGoodChange ? cs.primary : cs.error;
    return Row(children: [
      SizedBox(width: 36, child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface))),
      const SizedBox(width: 8),
      Text('上月 ¥${absPrev.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontFamily: 'monospace')),
      const SizedBox(width: 8),
      Icon(Icons.arrow_forward, size: 12, color: cs.onSurfaceVariant),
      const SizedBox(width: 8),
      Text('¥${absCur.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace')),
      const Spacer(),
      Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: changeColor),
      const SizedBox(width: 2),
      Text(displayDiff.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: changeColor, fontFamily: 'monospace')),
      const SizedBox(width: 4),
      Text('(${pct.toStringAsFixed(1)}%)',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    ]);
  }
}

// ═══ CATEGORY DONUT CHART ═══
class _CategoryDonut extends StatelessWidget {
  final List<CategoryExpenseItem> categories;
  const _CategoryDonut({required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = categories.map((c) => _ChartData(c.categoryName, c.amount.abs())).toList();
    final total = data.fold<double>(0, (s, d) => s + d.y);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        SizedBox(
          height: 180,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            legend: Legend(isVisible: false),
            series: <CircularSeries>[
              DoughnutSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.y,
                pointColorMapper: (d, _) => d.color,
                dataLabelMapper: (d, _) => d.y / total >= 0.05 ? '${(d.y / total * 100).toStringAsFixed(0)}%' : '',
                animationDuration: 600,
                innerRadius: '60%',
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        ...data.take(6).map((d) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Expanded(child: Text(d.x, style: TextStyle(fontSize: 11, color: cs.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text('${(d.y / total * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('¥${d.y.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace')),
          ]),
        )),
      ]),
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  final Color color;
  _ChartData(this.x, this.y) : color = _palette[x.hashCode.abs() % _palette.length];
}

const List<Color> _palette = [
  Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
  Color(0xFFFB8C00), Color(0xFF8E24AA), Color(0xFF00ACC1),
  Color(0xFFD81B60), Color(0xFF3949AB), Color(0xFF6D4C41),
  Color(0xFF546E7A),
];

// ═══ CATEGORY COMPARISON ═══
class _CategoryComparison extends StatelessWidget {
  final List<CategoryExpenseItem> categories;
  final ColorScheme cs;
  final bool hasComp;
  const _CategoryComparison({required this.categories, required this.cs, required this.hasComp});

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.fold<double>(0, (m, c) => max(m, c.amount));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: [
        // Header row
        Row(children: [
          const SizedBox(width: 60, child: Text('分类', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Container()),
          SizedBox(width: 44, child: Text('本月', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey), textAlign: TextAlign.right)),
          if (hasComp) SizedBox(width: 44, child: Text('上月', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey), textAlign: TextAlign.right)),
          const SizedBox(width: 6),
        ]),
        const SizedBox(height: 6),
        ...categories.take(5).map((c) => _compRow(c, maxAmount, cs, hasComp)),
      ]),
    );
  }

  Widget _compRow(CategoryExpenseItem c, double maxAmt, ColorScheme cs, bool hasComp) {
    final thisRatio = maxAmt > 0 ? (c.amount / maxAmt).clamp(0.0, 1.0) : 0.0;
    final prevRatio = maxAmt > 0 && c.prevAmount > 0 ? (c.prevAmount / maxAmt).clamp(0.0, 1.0) : 0.0;
    final isUp = c.diff > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 60,
            child: Text(c.categoryName, style: TextStyle(fontSize: 12, color: cs.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(children: [
            // This month bar
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: thisRatio,
                    backgroundColor: Colors.transparent,
                    color: cs.error,
                    minHeight: 8,
                  ),
                ),
              ),
            ]),
            // Previous month bar
            if (hasComp && c.prevAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: prevRatio,
                        backgroundColor: Colors.transparent,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
        const SizedBox(width: 6),
        SizedBox(width: 44,
            child: Text('¥${c.amount.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace'),
                textAlign: TextAlign.right)),
        if (hasComp) SizedBox(width: 44,
            child: Text(c.prevAmount > 0 ? '¥${c.prevAmount.toStringAsFixed(0)}' : '-',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontFamily: 'monospace'),
                textAlign: TextAlign.right)),
        const SizedBox(width: 4),
        if (hasComp && c.prevAmount > 0)
          Text(isUp ? '↑' : '↓',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUp ? cs.error : cs.primary)),
      ]),
    );
  }
}

// ═══ DAILY EXPENSE CHART ═══
class _DailyChart extends StatelessWidget {
  final List<double> dailyAmounts;
  final ColorScheme cs;
  const _DailyChart({required this.dailyAmounts, required this.cs});

  @override
  Widget build(BuildContext context) {
    final data = List.generate(dailyAmounts.length, (i) =>
        _ChartData('${i + 1}', dailyAmounts[i]));
    if (data.every((d) => d.y == 0)) return const SizedBox();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: SizedBox(
        height: 140,
        child: SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
            interval: dailyAmounts.length > 20 ? 5 : 3,
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            minimum: 0,
          ),
          series: <CartesianSeries>[
            ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (d, _) => d.x,
              yValueMapper: (d, _) => d.y,
              pointColorMapper: (d, _) => d.y > 0 ? cs.error.withValues(alpha: 0.6) : Colors.transparent,
              width: 0.6,
              spacing: 0.15,
              borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ KEY METRICS ═══
class _KeyMetrics extends StatelessWidget {
  final ReportSummary s;
  final MonthlyReportVO r;
  final ColorScheme cs;
  const _KeyMetrics({required this.s, required this.r, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Wrap(spacing: 4, runSpacing: 10, children: [
        _metric(cs, '储蓄率', '${r.savingsRate.toStringAsFixed(1)}%', r.savingsRate >= 20 ? cs.primary : cs.error),
        _metric(cs, '日均支出', '¥${s.dailyAverage.toStringAsFixed(1)}', cs.onSurface),
        _metric(cs, '记账笔数', '${r.itemCount}', cs.onSurface),
        _metric(cs, '分类数', '${r.categoryExpenses.length}', cs.onSurface),
        _metric(cs, '有支出天数', '${r.dailyAmounts.where((d) => d > 0).length}天', cs.onSurface),
        _metric(cs, '单笔最高', '¥${r.trends.maxSpendAmount?.toStringAsFixed(0) ?? "-"}', cs.onSurface),
      ]),
    );
  }

  Widget _metric(ColorScheme cs, String label, String value, Color valueColor) {
    return SizedBox(
      width: 100,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor, fontFamily: 'monospace')),
      ]),
    );
  }
}
