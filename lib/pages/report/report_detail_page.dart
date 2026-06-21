import 'dart:convert';
import 'package:flutter/material.dart';
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
    final up = s.expenseDiff > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        // ═══ HEADER ═══
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // 月份
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('${r.period.year}.${r.period.month.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onPrimaryContainer)),
          ),
          const SizedBox(width: 12),
          // 支出变化
          Text('支出 ${up ? "↑" : "↓"}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: up ? cs.error : cs.primary)),
          const SizedBox(width: 4),
          Text('¥${s.expenseDiff.abs().toStringAsFixed(0)}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
                  color: up ? cs.error : cs.primary, fontFamily: 'monospace', height: 1.1)),
          if (hasComp) ...[
            const SizedBox(width: 6),
            Text('(${(s.expenseChangeRatio * 100).toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: up ? cs.error : cs.primary)),
          ],
        ]),
        const SizedBox(height: 20),

        // ═══ KPI ROW ═══
        Row(children: [
          _kpi(cs, '支出', s.totalExpense, cs.error),
          const SizedBox(width: 10),
          _kpi(cs, '收入', s.totalIncome, cs.primary),
          const SizedBox(width: 10),
          _kpi(cs, '结余', s.balance, cs.tertiary),
        ]),
        const SizedBox(height: 24),

        // ═══ CATEGORY BAR CHART ═══
        if (r.categoryExpenses.isNotEmpty) ...[
          _sectionTitle(cs, '支出分类'),
          const SizedBox(height: 12),
          // 表头
          Row(children: [
            const SizedBox(width: 60, child: Text('分类', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
            Expanded(child: Container()),
            const SizedBox(width: 6, child: Text('金额', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
            const SizedBox(width: 12, child: Text('占比', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
            if (hasComp) const SizedBox(width: 6),
          ]),
          const SizedBox(height: 6),
          ...r.categoryExpenses.take(6).map((c) => _catBar(cs, c, s.totalExpense, hasComp)),
          const SizedBox(height: 20),
        ],

        // ═══ INSIGHTS ═══
        _sectionTitle(cs, '本月要点'),
        const SizedBox(height: 10),
        ..._buildInsights(cs, s, r),

        // ═══ TREND ═══
        const SizedBox(height: 20),
        _sectionTitle(cs, '支出趋势'),
        const SizedBox(height: 8),
        _trendBox(cs, r.trends),

        // ═══ FOOTER ═══
        const SizedBox(height: 24),
        Center(child: Text(DateUtil.format(r.generatedAt),
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant))),
      ],
    );
  }

  // ------- KPI -------
  Widget _kpi(ColorScheme cs, String label, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text('¥${amount.abs().toStringAsFixed(0)}',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color, fontFamily: 'monospace', height: 1.1)),
        ]),
      ),
    );
  }

  // ------- HORIZONTAL BAR -------
  Widget _catBar(ColorScheme cs, CategoryExpenseItem c, double total, bool hasComp) {
    final ratio = total.abs() > 0 ? (c.amount / total.abs()).clamp(0.0, 1.0) : 0.0;
    final isUp = c.diff > 0;
    final hasDiff = c.prevAmount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 60,
          child: Text(c.categoryName,
              style: TextStyle(fontSize: 12, color: cs.onSurface),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.error.withValues(alpha: 0.5),
                minHeight: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 52,
          child: Text('¥${c.amount.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface, fontFamily: 'monospace'),
              textAlign: TextAlign.right),
        ),
        const SizedBox(width: 4),
        SizedBox(width: 40,
          child: Text('${c.percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              textAlign: TextAlign.right),
        ),
        if (hasDiff) ...[
          const SizedBox(width: 4),
          Text(
            isUp ? '↑' : '↓',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUp ? cs.error : cs.primary),
          ),
          Text('${(c.diffPercent * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, color: isUp ? cs.error : cs.primary, fontWeight: FontWeight.w500)),
        ],
      ]),
    );
  }

  // ------- INSIGHTS -------
  List<Widget> _buildInsights(ColorScheme cs, ReportSummary s, MonthlyReportVO report) {
    final list = <Widget>[];

    // 1. 支出变化
    if (s.hasComparison) {
      final up = s.expenseDiff > 0;
      list.add(_insightRow(cs,
        up ? Icons.trending_up : Icons.trending_down,
        up ? cs.error : cs.primary,
        '${up ? "增加" : "减少"}支出 ¥${s.expenseDiff.abs().toStringAsFixed(0)}'
            '（${(s.expenseChangeRatio * 100).toStringAsFixed(1)}%）',
      ));
    }

    // 2. 日均
    list.add(_insightRow(cs, Icons.schedule, cs.primary,
        '日均支出 ¥${s.dailyAverage.toStringAsFixed(1)}'));

    // 3. Top 1 category
    if (report.categoryExpenses.isNotEmpty) {
      final top = report.categoryExpenses.first;
      list.add(_insightRow(cs, Icons.pie_chart, cs.tertiary,
          '最大支出「${top.categoryName}」¥${top.amount.toStringAsFixed(0)}'
          '（${top.percentage.toStringAsFixed(1)}%）'));
    }

    // 4. Anomalies
    final warnings = report.alerts.where((a) => a.severity == 'warning').toList();
    for (final a in warnings.take(2)) {
      list.add(_insightRow(cs, Icons.warning_amber_rounded, cs.error, a.message));
    }

    // 5. 大笔支出
    for (final t in report.largeTransactions.take(1)) {
      list.add(_insightRow(cs, Icons.receipt_long, cs.error,
          '${t.date.substring(5)} ${t.categoryName}${t.description != null ? " ${t.description!}" : ""} ¥${t.amount.toStringAsFixed(0)}'));
    }

    if (list.isEmpty) {
      list.add(_insightRow(cs, Icons.check_circle_outline, cs.primary, '本月无异常支出'));
    }

    return list;
  }

  Widget _insightRow(ColorScheme cs, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
            style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.3))),
      ]),
    );
  }

  // ------- TREND -------
  Widget _trendBox(ColorScheme cs, ReportTrends t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        _trendLine(cs, '日均', '¥${t.dailyAverage.toStringAsFixed(1)}', Icons.trending_up),
        if (t.maxSpendDay != null)
          Padding(padding: const EdgeInsets.only(top: 6),
              child: _trendLine(cs, '最高', '${t.maxSpendDay!.substring(5)}  ¥${t.maxSpendAmount?.toStringAsFixed(0) ?? ""}', Icons.arrow_upward)),
        if (t.minSpendDay != null)
          Padding(padding: const EdgeInsets.only(top: 6),
              child: _trendLine(cs, '最低', '${t.minSpendDay!.substring(5)}  ¥${t.minSpendAmount?.toStringAsFixed(0) ?? ""}', Icons.arrow_downward)),
      ]),
    );
  }

  Widget _trendLine(ColorScheme cs, String label, String value, IconData icon) {
    return Row(children: [
      Icon(icon, size: 14, color: cs.onSurfaceVariant),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface, fontFamily: 'monospace')),
    ]);
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
