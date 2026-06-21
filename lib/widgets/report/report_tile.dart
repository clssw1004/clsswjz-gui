import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/date_util.dart';

class ReportTile extends StatelessWidget {
  final UserNoteVO note;
  final VoidCallback? onTap;

  const ReportTile({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.spacing;
    final report = _parseReport(note.content);
    final s = report?.summary;

    return Padding(
      padding: spacing.listItemMargin,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assessment_rounded,
                        size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.title ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.createdAt != null)
                      Text(DateUtil.format(note.createdAt!),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
                if (s != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _miniKpi(cs, '支出', s.totalExpense, cs.error,
                          s.expenseDiff, s.hasComparison),
                      const SizedBox(width: 8),
                      _miniKpi(cs, '收入', s.totalIncome, cs.primary,
                          s.incomeDiff, s.hasComparison),
                      const SizedBox(width: 8),
                      _miniKpi(cs, '结余', s.balance, cs.tertiary,
                          s.balance - s.prevBalance, s.hasComparison),
                    ],
                  ),
                  if (report != null && report.alerts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 13, color: cs.error),
                          const SizedBox(width: 4),
                          Text('${report.alerts.length}条关注',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Icon(Icons.chevron_right,
                              size: 16, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniKpi(ColorScheme cs, String label, double amount, Color color,
      double diff, bool hasComp) {
    final isUp = diff >= 0;
    final sign = isUp ? '+' : '';
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: cs.onSurfaceVariant)),
          const SizedBox(height: 1),
          Text('¥${amount.abs().toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1)),
          if (hasComp)
            Text('$sign${diff.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 9,
                    color: isUp && label == '支出'
                        ? color
                        : cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  MonthlyReportVO? _parseReport(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      return MonthlyReportVO.fromJson(
          jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
