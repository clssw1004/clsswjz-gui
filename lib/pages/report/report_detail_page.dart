import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/date_util.dart';
import '../../widgets/common/common_app_bar.dart';

/// 月度收支报告详情页
class ReportDetailPage extends StatelessWidget {
  final UserNoteVO note;

  const ReportDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final report = _parseReport(note.content);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(note.title ?? '月度收支报告'),
        actions: [
          if (report != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '${report.period.year}年${report.period.month}月',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
        ],
      ),
      body: report == null
          ? Center(
              child: Text(
                '报告数据解析失败',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : _ReportContentView(report: report),
    );
  }

  MonthlyReportVO? _parseReport(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      final json = jsonDecode(content);
      return MonthlyReportVO.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class _ReportContentView extends StatelessWidget {
  final MonthlyReportVO report;

  const _ReportContentView({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return ListView(
      padding: spacing.contentPadding,
      children: [
        // ━━ 一、总体概览 ━━
        _SectionHeader(title: '总体概览'),
        SizedBox(height: spacing.formItemSpacing),
        _SummaryCards(summary: report.summary),
        SizedBox(height: spacing.formGroupSpacing),

        // ━━ 二、支出分类排行榜 ━━
        if (report.categoryExpenses.isNotEmpty) ...[
          _SectionHeader(title: '支出分类排行榜'),
          SizedBox(height: spacing.formItemSpacing),
          ...report.categoryExpenses.map((item) => Padding(
                padding: EdgeInsets.only(bottom: spacing.listItemSpacing),
                child: _CategoryRankRow(item: item, total: report.summary.totalExpense),
              )),
          SizedBox(height: spacing.formGroupSpacing),
        ],

        // ━━ 三、大笔支出 ━━
        if (report.largeTransactions.isNotEmpty) ...[
          _SectionHeader(
            title: '大笔支出',
            trailing: Text(
              '单笔 ≥ 总支出5%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),
          ...report.largeTransactions.map((txn) => Padding(
                padding: EdgeInsets.only(bottom: spacing.listItemSpacing),
                child: _LargeTransactionCard(transaction: txn),
              )),
          SizedBox(height: spacing.formGroupSpacing),
        ],

        // ━━ 四、预警分析 ━━
        if (report.alerts.isNotEmpty) ...[
          _SectionHeader(title: '预警分析'),
          SizedBox(height: spacing.formItemSpacing),
          ...report.alerts.map((alert) => Padding(
                padding: EdgeInsets.only(bottom: spacing.listItemSpacing),
                child: _AlertCard(alert: alert),
              )),
          SizedBox(height: spacing.formGroupSpacing),
        ],

        // ━━ 五、支出趋势 ━━
        _SectionHeader(title: '支出趋势'),
        SizedBox(height: spacing.formItemSpacing),
        _TrendsCard(trends: report.trends),
        SizedBox(height: spacing.formGroupSpacing),

        // 底部信息
        Center(
          child: Text(
            '报告生成时间: ${DateUtil.format(report.generatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: spacing.formGroupSpacing),
      ],
    );
  }
}

/// 段落标题
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

/// KPI 卡片组（收入、支出、结余）
class _SummaryCards extends StatelessWidget {
  final ReportSummary summary;

  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
            child: _KpiCard(
          label: '收入',
          amount: summary.totalIncome,
          color: colorScheme.primary,
          diff: summary.incomeDiff,
          hasComparison: summary.hasComparison,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: _KpiCard(
          label: '支出',
          amount: summary.totalExpense,
          color: colorScheme.error,
          diff: summary.expenseDiff,
          hasComparison: summary.hasComparison,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: _KpiCard(
          label: '结余',
          amount: summary.balance,
          color: colorScheme.tertiary,
          diff: summary.balance - summary.prevBalance,
          hasComparison: summary.hasComparison,
        )),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double diff;
  final bool hasComparison;

  const _KpiCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.diff,
    required this.hasComparison,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = diff >= 0;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¥${amount.abs().toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.1,
            ),
          ),
          if (hasComparison) ...[
            const SizedBox(height: 2),
            Text(
              '$sign${diff.toStringAsFixed(0)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isPositive && label == '支出'
                    ? color
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 分类排行行
class _CategoryRankRow extends StatelessWidget {
  final CategoryExpenseItem item;
  final double total;

  const _CategoryRankRow({required this.item, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barRatio = total > 0 ? item.amount / total.abs() : 0.0;
    final hasDiff = item.prevAmount > 0;
    final isUp = item.diff > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Expanded(
                child: Text(
                  item.categoryName.isEmpty ? '未分类' : item.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '¥${item.amount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: barRatio.clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.error.withValues(alpha: 0.6),
              minHeight: 6,
            ),
          ),
          // 环比行
          if (hasDiff)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '上月 ¥${item.prevAmount.toStringAsFixed(0)}  '
                '${isUp ? '+' : ''}${item.diff.toStringAsFixed(0)}  '
                '${isUp ? '↑' : '↓'}${(item.diffPercent * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 大笔支出卡片
class _LargeTransactionCard extends StatelessWidget {
  final LargeTransaction transaction;

  const _LargeTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.categoryName}${transaction.description != null ? ' - ${transaction.description}' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${transaction.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.error,
                ),
              ),
              Text(
                '${transaction.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 预警卡片
class _AlertCard extends StatelessWidget {
  final ReportAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isWarning = alert.severity == 'warning';
    final icon = isWarning ? Icons.warning_amber_rounded : Icons.info_outline;
    final color = isWarning ? colorScheme.error : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 支出趋势卡片
class _TrendsCard extends StatelessWidget {
  final ReportTrends trends;

  const _TrendsCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _TrendRow(
            label: '日均支出',
            value: '¥${trends.dailyAverage.toStringAsFixed(1)}',
            icon: Icons.trending_up,
            colorScheme: colorScheme,
          ),
          if (trends.maxSpendDay != null) ...[
            const SizedBox(height: 8),
            _TrendRow(
              label: '支出最多日',
              value: '${trends.maxSpendDay}  ¥${trends.maxSpendAmount?.toStringAsFixed(0)}',
              icon: Icons.arrow_upward,
              colorScheme: colorScheme,
            ),
          ],
          if (trends.minSpendDay != null) ...[
            const SizedBox(height: 8),
            _TrendRow(
              label: '支出最少日（有记录）',
              value: '${trends.minSpendDay}  ¥${trends.minSpendAmount?.toStringAsFixed(0)}',
              icon: Icons.arrow_downward,
              colorScheme: colorScheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;

  const _TrendRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
