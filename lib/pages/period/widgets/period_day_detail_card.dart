import 'package:flutter/material.dart';
import '../../../constants/period_symptoms.dart';
import '../../../enums/period_status.dart';
import '../../../models/vo/period_record_vo.dart';
import '../../../theme/theme_spacing.dart';
import '../../../manager/l10n_manager.dart';

/// 升级版日期详情卡片
///
/// - 左侧 4px 色条（根据 periodStatus 变色）
/// - 标题行：日期 + 星期 + 操作按钮
/// - 信息行：状态、流量、症状 chip、心情图标、备注
class PeriodDayDetailCard extends StatelessWidget {
  final PeriodRecordVO record;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PeriodDayDetailCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;

    final accentColor = record.periodStatus == PeriodStatus.period
        ? cs.error
        : cs.primary;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左侧色条
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // 内容
            Expanded(
              child: Padding(
                padding: spacing.contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.recordDate,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _weekDay(record.recordDate, l10n),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (onEdit != null)
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: cs.primary,
                            onPressed: onEdit!,
                          ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 4),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: cs.error,
                            onPressed: onDelete!,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: spacing.formItemSpacing),
                    // 状态标签
                    _buildStatusChip(cs, theme),
                    // 信息行
                    _buildInfoSection(theme, cs, l10n, spacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme cs, ThemeData theme) {
    final label = record.periodStatus == PeriodStatus.period
        ? L10nManager.l10n.periodRecord
        : L10nManager.l10n.periodStatusNone;
    final color = record.periodStatus == PeriodStatus.period
        ? cs.error
        : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    ColorScheme cs,
    dynamic l10n,
    ThemeSpacing spacing,
  ) {
    return Column(
      children: [
        if (record.periodStatus == PeriodStatus.period)
          _buildInfoRow(theme, l10n.flowLevel, record.flowLevel.text),
        if (record.symptoms.isNotEmpty)
          _buildSymptomsRow(theme, cs, l10n),
        _buildInfoRow(theme, l10n.mood, record.mood.text),
        if (record.remark != null && record.remark!.isNotEmpty)
          _buildInfoRow(theme, l10n.remark, record.remark!),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsRow(
    ThemeData theme,
    ColorScheme cs,
    dynamic l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              l10n.symptoms,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: record.symptoms.map((s) {
                final symptom = PeriodSymptoms.all
                    .where((p) => p.code == s)
                    .firstOrNull;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (symptom != null) ...[
                        Icon(symptom.icon, size: 12, color: cs.primary),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        symptom?.label ?? s,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _weekDay(String date, dynamic l10n) {
    final days = [
      l10n.monday, l10n.tuesday, l10n.wednesday,
      l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday,
    ];
    return days[DateTime.parse(date).weekday - 1];
  }
}
