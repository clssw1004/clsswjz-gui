import 'package:flutter/material.dart';
import '../../../manager/l10n_manager.dart';

/// 经期初次进入引导底部弹窗
///
/// 引导用户填写上次经期信息，帮助系统建立预测模型。
/// 用户可跳过，不影响使用。
class PeriodOnboardingSheet extends StatefulWidget {
  const PeriodOnboardingSheet({super.key});

  static Future<PeriodOnboardingResult?> show(BuildContext context) {
    return showModalBottomSheet<PeriodOnboardingResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PeriodOnboardingSheet(),
    );
  }

  @override
  State<PeriodOnboardingSheet> createState() => _PeriodOnboardingSheetState();
}

/// 引导结果
class PeriodOnboardingResult {
  /// 上次经期开始日期 (yyyy-MM-dd)，null 表示跳过
  final String? lastPeriodStart;

  /// 上次经期结束日期 (yyyy-MM-dd)，null 表示不知道/跳过
  final String? lastPeriodEnd;

  const PeriodOnboardingResult({this.lastPeriodStart, this.lastPeriodEnd});
}

class _PeriodOnboardingSheetState extends State<PeriodOnboardingSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _knowDuration = false;

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;

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
          // 顶部指示条
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 标题
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: cs.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.periodOnboardingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.periodOnboardingDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // 上次经期开始日期
          Text(
            l10n.periodOnboardingLastStart,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDateButton(
            context,
            label: _startDate != null
                ? _formatDate(_startDate!)
                : l10n.periodOnboardingSelectDate,
            isSelected: _startDate != null,
            cs: cs,
            theme: theme,
            onTap: () => _pickDate(context, isStart: true),
          ),
          const SizedBox(height: 20),

          // 是否知道持续天数
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.periodOnboardingKnowDuration,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _knowDuration,
                onChanged: (v) => setState(() {
                  _knowDuration = v;
                  if (!v) _endDate = null;
                }),
              ),
            ],
          ),

          // 结束日期（可选）
          if (_knowDuration) ...[
            const SizedBox(height: 8),
            Text(
              l10n.periodOnboardingLastEnd,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _buildDateButton(
              context,
              label: _endDate != null
                  ? _formatDate(_endDate!)
                  : l10n.periodOnboardingSelectDate,
              isSelected: _endDate != null,
              cs: cs,
              theme: theme,
              onTap: _startDate != null
                  ? () => _pickDate(context, isStart: false)
                  : null,
            ),
          ],
          const SizedBox(height: 24),

          // 按钮行
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    const PeriodOnboardingResult(),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.skip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _startDate == null
                      ? null
                      : () => Navigator.pop(
                            context,
                            PeriodOnboardingResult(
                              lastPeriodStart: _formatDate(_startDate!),
                              lastPeriodEnd: _endDate != null
                                  ? _formatDate(_endDate!)
                                  : null,
                            ),
                          ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required ColorScheme cs,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withAlpha(15)
              : cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary.withAlpha(80) : cs.outlineVariant.withAlpha(60),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    final firstDate = isStart
        ? now.subtract(const Duration(days: 90))
        : _startDate ?? now.subtract(const Duration(days: 90));
    final lastDate = isStart ? now : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // 如果结束日期早于新的开始日期，重置结束日期
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
