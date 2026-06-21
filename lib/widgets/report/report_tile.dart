import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/date_util.dart';

/// 报告笔记在列表中的预览卡片
class ReportTile extends StatelessWidget {
  final UserNoteVO note;
  final VoidCallback? onTap;

  const ReportTile({
    super.key,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    // 解析报告数据
    final report = _parseReport(note.content);
    final summary = report?.summary;

    return Padding(
      padding: spacing.listItemMargin,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spacing.listItemPadding.left),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.4),
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assessment_rounded,
                        size: 22, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        note.title ?? '月度收支报告',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.scope == 'global')
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '全局',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.tertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (note.createdAt != null)
                      Text(
                        DateUtil.format(note.createdAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // KPI 预览
              if (summary != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.listItemPadding.left,
                    0,
                    spacing.listItemPadding.right,
                    spacing.listItemPadding.bottom,
                  ),
                  child: Row(
                    children: [
                      _buildKpiChip(
                          context, '收入', summary.totalIncome,
                          colorScheme.primary, summary.incomeDiff, summary.hasComparison),
                      const SizedBox(width: 8),
                      _buildKpiChip(
                          context, '支出', summary.totalExpense,
                          colorScheme.error, summary.expenseDiff, summary.hasComparison),
                      const SizedBox(width: 8),
                      _buildKpiChip(
                          context, '结余', summary.balance,
                          colorScheme.tertiary, summary.balance - summary.prevBalance,
                          summary.hasComparison),
                    ],
                  ),
                ),
              // 预警标签
              if (report != null && report.alerts.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.listItemPadding.left,
                    0,
                    spacing.listItemPadding.right,
                    spacing.listItemPadding.bottom,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: colorScheme.error),
                      const SizedBox(width: 4),
                      Text(
                        '${report.alerts.length}条预警',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right,
                          size: 18, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiChip(
    BuildContext context,
    String label,
    double amount,
    Color color,
    double diff,
    bool hasComparison,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPositive = diff >= 0;
    final sign = isPositive ? '+' : '';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '¥${amount.abs().toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasComparison)
              Text(
                '$sign${diff.toStringAsFixed(0)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isPositive ? colorScheme.error : colorScheme.primary,
                  fontSize: 9,
                ),
              ),
          ],
        ),
      ),
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
