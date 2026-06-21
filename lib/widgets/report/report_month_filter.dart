import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../enums/note_type.dart';
import '../../manager/dao_manager.dart';
import '../../services/monthly_report_service.dart';
import '../../utils/toast_util.dart';

/// 报表月份筛选组件
/// 动态显示最近月份列表，已生成报告的可跳转，未生成的提供生成按钮
class ReportMonthFilter extends StatefulWidget {
  final String bookId;
  final void Function(String reportNoteId)? onReportSelected;
  final VoidCallback? onReportGenerated;

  const ReportMonthFilter({
    super.key,
    required this.bookId,
    this.onReportSelected,
    this.onReportGenerated,
  });

  @override
  State<ReportMonthFilter> createState() => _ReportMonthFilterState();
}

class _ReportMonthFilterState extends State<ReportMonthFilter> {
  final List<_MonthReportStatus> _months = [];
  bool _loading = true;
  final _service = MonthlyReportService();

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    setState(() => _loading = true);
    try {
      // 生成最近 12 个月列表
      final now = DateTime.now();
      final months = <_MonthReportStatus>[];
      for (int i = 0; i < 12; i++) {
        final dt = DateTime(now.year, now.month - i, 1);
        months.add(_MonthReportStatus(
          year: dt.year,
          month: dt.month,
        ));
      }

      // 查询已有报告
      final allNotes = await DaoManager.noteDao.listByBook(widget.bookId, limit: 200);
      final reportNotes = allNotes.where((n) => n.noteType == NoteType.report.code).toList();

      for (final m in months) {
        final title = '月度收支报告 —— ${m.year}年${m.month}月';
        final match = reportNotes.cast<AccountNote?>().firstWhere(
          (n) => n!.title == title,
          orElse: () => null,
        );
        if (match != null) {
          m.noteId = match.id;
          m.generated = true;
        }
      }

      if (mounted) {
        setState(() {
          _months..clear()..addAll(months);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('加载报表月份列表失败: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generateReport(_MonthReportStatus m) async {
    final noteId = await _service.regenerateReport(widget.bookId, m.year, m.month);
    if (mounted) {
      if (noteId != null) {
        m.noteId = noteId;
        m.generated = true;
        setState(() {});
        ToastUtil.showSuccess('${m.year}年${m.month}月报告已生成');
        widget.onReportGenerated?.call();
      } else {
        ToastUtil.showError('生成失败，该月可能无记账数据');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(maxHeight: 420),
      child: _loading
          ? const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _months.length + 1, // +1 for header
              separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16,
                  color: cs.outline.withValues(alpha: 0.1)),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(children: [
                      Icon(Icons.assessment_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('月度报告', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${_months.length}个月', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    ]),
                  );
                }
                return _buildMonthRow(_months[index - 1], cs, theme);
              },
            ),
    );
  }

  Widget _buildMonthRow(_MonthReportStatus m, ColorScheme cs, ThemeData theme) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: m.generated
              ? cs.primaryContainer.withValues(alpha: 0.5)
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('${m.month}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: m.generated ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
        ),
      ),
      title: Text('${m.year}年${m.month}月',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
      subtitle: Text(m.generated ? '已生成' : '未生成',
          style: TextStyle(fontSize: 11, color: m.generated ? cs.primary : cs.onSurfaceVariant)),
      trailing: m.generated
          ? Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant)
          : SizedBox(
              height: 30,
              child: OutlinedButton.icon(
                onPressed: () => _generateReport(m),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('生成', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
      onTap: m.generated ? () => widget.onReportSelected?.call(m.noteId!) : null,
    );
  }
}

class _MonthReportStatus {
  final int year;
  final int month;
  bool generated;
  String? noteId;

  _MonthReportStatus({
    required this.year,
    required this.month,
    this.generated = false,
    this.noteId,
  });
}
