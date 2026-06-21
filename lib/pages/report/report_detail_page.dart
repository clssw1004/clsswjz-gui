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
    final report = _parse(note.content);
    return Scaffold(
      appBar: CommonAppBar(title: Text(note.title ?? '月度报告')),
      body: report == null
          ? Center(child: Text('无法解析报告',
              style: Theme.of(context).textTheme.bodyLarge))
          : _Body(report: report),
    );
  }

  MonthlyReportVO? _parse(String? c) {
    try {
      return c != null && c.isNotEmpty
          ? MonthlyReportVO.fromJson(jsonDecode(c) as Map<String, dynamic>)
          : null;
    } catch (_) {
      return null;
    }
  }
}

class _Body extends StatelessWidget {
  final MonthlyReportVO report;
  const _Body({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = report.summary;
    final hasComp = s.hasComparison;
    final spentMore = s.expenseDiff > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ━━ 头：月份 + 总览变化 ━━
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${report.period.year}/${report.period.month}',
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: cs.onPrimaryContainer)),
            ),
            const SizedBox(width: 10),
            if (hasComp)
              Expanded(
                child: Text(
                  '支出 ${spentMore ? "↑" : "↓"} ¥${s.expenseDiff.abs().toStringAsFixed(0)}  '
                  '(${(s.expenseChangeRatio * 100).toStringAsFixed(1)}%)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: spentMore ? cs.error : cs.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ━━ KPI 行 ━━
        Row(
          children: [
            _kpi(cs, '支出', s.totalExpense, cs.error, null, null),
            const SizedBox(width: 12),
            _kpi(cs, '收入', s.totalIncome, cs.primary, null, null),
            const SizedBox(width: 12),
            _kpi(cs, '结余', s.balance, cs.tertiary, null, null),
          ],
        ),
        const SizedBox(height: 20),

        // ━━ 分类排行 ━━
        if (report.categoryExpenses.isNotEmpty) ...[
          _sectionHeader(cs, '分类支出'),
          const SizedBox(height: 8),
          ...report.categoryExpenses.take(6).map((c) => _catRow(c, cs, theme)),
          const SizedBox(height: 20),
        ],

        // ━━ 关注点 ━━
        if (report.alerts.isNotEmpty ||
            report.largeTransactions.isNotEmpty) ...[
          _sectionHeader(cs, '关注点'),
          const SizedBox(height: 8),
          ...report.largeTransactions.take(3).map(
              (t) => _alertItem(theme, cs, Icons.error_outline, cs.error,
                  '${t.date.substring(5)} ${t.categoryName}${t.description != null ? " ${t.description!}" : ""}',
                  '¥${t.amount.toStringAsFixed(0)}  ${t.percentage.toStringAsFixed(1)}%')),
          ...report.alerts.map((a) => _alertItem(theme, cs,
              a.severity == 'warning' ? Icons.warning_amber_rounded : Icons.info_outline,
              a.severity == 'warning' ? cs.error : cs.primary,
              a.message, null)),
          const SizedBox(height: 20),
        ],

        // ━━ 趋势 ━━
        _sectionHeader(cs, '支出趋势'),
        const SizedBox(height: 8),
        _trendRow(cs, theme, report.trends),

        // ━━ 时间戳 ━━
        const SizedBox(height: 24),
        Center(
          child: Text(DateUtil.format(report.generatedAt),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _sectionHeader(ColorScheme cs, String text) {
    return Row(children: [
      Container(width: 3, height: 14,
          decoration: BoxDecoration(color: cs.primary,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
    ]);
  }

  Widget _kpi(ColorScheme cs, String label, double amount, Color color,
      double? diff, bool? hasComp) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text('¥${amount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: color,
                    height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _catRow(CategoryExpenseItem c, ColorScheme cs, ThemeData theme) {
    final ratio = c.amount / report.summary.totalExpense.abs().clamp(0.01, double.infinity);
    final hasDiff = c.prevAmount > 0;
    final isUp = c.diff > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(c.categoryName,
                style: TextStyle(fontSize: 13, color: cs.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.error.withValues(alpha: 0.55),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text('¥${c.amount.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: cs.onSurface),
                textAlign: TextAlign.right),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 46,
            child: Text('${c.percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                textAlign: TextAlign.right),
          ),
          if (hasDiff) ...[
            const SizedBox(width: 4),
            Text(
              '${isUp ? "↑" : "↓"}${(c.diffPercent * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 10,
                  color: isUp ? cs.error : cs.primary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _alertItem(ThemeData theme, ColorScheme cs, IconData icon,
      Color color, String message, String? trailing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.3)),
          ),
          if (trailing != null)
            Text(trailing,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _trendRow(ColorScheme cs, ThemeData theme, ReportTrends t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _trendLine(cs, '日均', '¥${t.dailyAverage.toStringAsFixed(1)}',
              Icons.trending_up),
          if (t.maxSpendDay != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _trendLine(cs, '最多',
                  '${t.maxSpendDay!.substring(5)}  ¥${t.maxSpendAmount?.toStringAsFixed(0) ?? ""}',
                  Icons.arrow_upward),
            ),
          if (t.minSpendDay != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _trendLine(cs, '最少',
                  '${t.minSpendDay!.substring(5)}  ¥${t.minSpendAmount?.toStringAsFixed(0) ?? ""}',
                  Icons.arrow_downward),
            ),
        ],
      ),
    );
  }

  Widget _trendLine(ColorScheme cs, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
      ],
    );
  }
}
