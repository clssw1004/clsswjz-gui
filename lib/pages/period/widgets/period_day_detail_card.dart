import 'package:flutter/material.dart';
import '../../../constants/period_symptoms.dart';
import '../../../enums/period_status.dart';
import '../../../models/vo/period_record_vo.dart';
import '../../../theme/theme_spacing.dart';

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

    return Container(
      padding: spacing.contentPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${record.recordDate} ${_weekDay(record.recordDate)}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildInfoRow(theme, '状态', record.periodStatus.text),
          if (record.periodStatus == PeriodStatus.period)
            _buildInfoRow(theme, '流量', record.flowLevel.text),
          if (record.symptoms.isNotEmpty)
            _buildInfoRow(theme, '症状',
                record.symptoms.map((s) => PeriodSymptoms.labelOf(s)).join('、')),
          _buildInfoRow(theme, '情绪', record.mood.text),
          if (record.remark != null && record.remark!.isNotEmpty)
            _buildInfoRow(theme, '备注', record.remark!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _weekDay(String date) {
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[DateTime.parse(date).weekday - 1];
  }
}
