import 'package:flutter/material.dart';
import '../../../manager/l10n_manager.dart';

/// 历史补记底部抽屉
///
/// 两个日期选择器：开始日期 + 结束日期（**必填**，补记历史不允许"进行中"）。
/// 选择结束日期时，日历定位到开始日期所在月份。
class PeriodBackfillSheet extends StatefulWidget {
  final String fromDate;
  final String? minDate;
  final String? maxDate;

  const PeriodBackfillSheet({
    super.key,
    required this.fromDate,
    this.minDate,
    this.maxDate,
  });

  static Future<DateTimeRange?> show(
    BuildContext context,
    String fromDate, {
    String? minDate,
    String? maxDate,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PeriodBackfillSheet(
        fromDate: fromDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }

  @override
  State<PeriodBackfillSheet> createState() => _PeriodBackfillSheetState();
}

class _PeriodBackfillSheetState extends State<PeriodBackfillSheet> {
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.parse(widget.fromDate);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽条
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 标题
          Text(
            l10n.periodBackfill,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.periodBackfillDesc,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // 开始日期
          _buildLabel(theme, l10n.periodOnboardingLastStart),
          const SizedBox(height: 8),
          _buildDatePicker(
            context,
            date: _startDate,
            firstDate: DateTime(2020),
            lastDate: todayOnly,
            onSelect: (d) {
              setState(() {
                _startDate = d;
                // 结束日期早于新开始日期时重置
                if (_endDate != null && _endDate!.isBefore(d)) {
                  _endDate = null;
                }
              });
            },
            cs: cs,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // 结束日期（必填，不允许"进行中"）
          _buildLabel(theme, l10n.periodOnboardingLastEnd),
          const SizedBox(height: 8),
          _buildDatePicker(
            context,
            date: _endDate,
            firstDate: _startDate,
            lastDate: todayOnly,
            // 未选结束日期时，日历定位到开始日期所在月份
            initialDate: _endDate ?? _startDate,
            onSelect: (d) => setState(() => _endDate = d),
            cs: cs,
            theme: theme,
            hint: l10n.periodOnboardingSelectDate,
          ),
          const SizedBox(height: 24),

          // 按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canConfirm() ? _onConfirm : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.confirm),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  bool _canConfirm() => _endDate != null;

  void _onConfirm() {
    final startOnly = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    Navigator.pop(context, DateTimeRange(start: startOnly, end: endOnly));
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required DateTime? date,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onSelect,
    required ColorScheme cs,
    required ThemeData theme,
    String? hint,
    DateTime? initialDate,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? date ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: date != null
              ? cs.primary.withAlpha(15)
              : cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? cs.primary.withAlpha(80)
                : cs.outlineVariant.withAlpha(60),
            width: date != null ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: date != null ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              date != null ? _fmt(date) : (hint ?? ''),
              style: TextStyle(
                fontSize: 15,
                color: date != null ? cs.primary : cs.onSurfaceVariant,
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
