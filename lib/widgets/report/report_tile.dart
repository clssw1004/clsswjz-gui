import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/vo/monthly_report_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../utils/date_util.dart';

class ReportTile extends StatelessWidget {
  final UserNoteVO note;
  final VoidCallback? onTap;
  const ReportTile({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = _parse(note.content);
    final s = r?.summary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surface,
            border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 头: 图标 + 标题 + 日期
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.assessment_rounded, size: 16, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(note.title ?? '',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (note.createdAt != null)
                Text(DateUtil.format(note.createdAt!).substring(5, 10),
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ]),
            if (s != null) ...[
              const SizedBox(height: 12),
              // 支出变化(大号醒目)
              Row(children: [
                _changeTag(cs, s.totalExpense, s.expenseDiff, s.hasComparison),
                const Spacer(),
                Text('收入 ¥${s.totalIncome.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                const SizedBox(width: 10),
                Text('结余 ¥${s.balance.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ]),
              // 预警提示
              if (r != null && r.alerts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded, size: 13, color: cs.error),
                    const SizedBox(width: 4),
                    Text('${r.alerts.length}项关注',
                        style: TextStyle(fontSize: 11, color: cs.error, fontWeight: FontWeight.w500)),
                  ]),
                ),
            ],
          ]),
      ),
    );
  }

  Widget _changeTag(ColorScheme cs, double amount, double diff, bool hasComp) {
    if (!hasComp) {
      return Text('支出 ¥${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface));
    }
    final up = diff > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (up ? cs.error : cs.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '支出 ${up ? "↑" : "↓"} ¥${diff.abs().toStringAsFixed(0)}',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: up ? cs.error : cs.primary),
      ),
    );
  }

  MonthlyReportVO? _parse(String? c) {
    try { return c != null && c.isNotEmpty
        ? MonthlyReportVO.fromJson(jsonDecode(c) as Map<String, dynamic>) : null; }
    catch (_) { return null; }
  }
}
