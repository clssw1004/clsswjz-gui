import 'package:flutter/material.dart';
import '../../../models/vo/period_cycle_vo.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../services/period_prediction_service.dart';
import '../../../manager/l10n_manager.dart';

/// 经期日历网格组件
///
/// 基于 cycles 渲染经期、预测期、排卵日、易孕期等状态。
class PeriodCalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final List<PeriodCycleVO> cycles;
  final PeriodStatisticsVO? statistics;
  final String? selectedDate;
  final ValueChanged<String> onDateTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const PeriodCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.cycles,
    this.statistics,
    this.selectedDate,
    required this.onDateTap,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;
    // 从 cycles 计算日期类型
    final dateTypes = PeriodPredictionService.getMonthDateTypes(cycles, statistics);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final firstDay = DateTime(year, month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 月份导航
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  icon: Icons.chevron_left,
                  cs: cs,
                  onPressed: onPreviousMonth,
                ),
                Text(
                  '$year / ${month.toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildNavButton(
                  icon: Icons.chevron_right,
                  cs: cs,
                  onPressed: onNextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 星期头
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [l10n.sunday, l10n.monday, l10n.tuesday, l10n.wednesday,
                      l10n.thursday, l10n.friday, l10n.saturday]
                  .map((d) {
                final idx = [l10n.sunday, l10n.monday, l10n.tuesday,
                    l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday].indexOf(d);
                final isWeekend = idx == 0 || idx == 6;
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isWeekend
                            ? cs.error.withAlpha(160)
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          // 日期网格
          ...List.generate(
            ((startWeekday + daysInMonth + 6) ~/ 7),
            (weekIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final cellIndex = weekIndex * 7 + dayIndex;
                    final dayNum = cellIndex - startWeekday + 1;
                    if (dayNum < 1 || dayNum > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 42));
                    }
                    final dateStr =
                        '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                    final dateType = dateTypes[dateStr];
                    final isToday = dateStr == todayStr;
                    final isSelected = dateStr == selectedDate;
                    final isFuture = dateStr.compareTo(todayStr) > 0;
                    final isWeekend =
                        (cellIndex % 7 == 0) || (cellIndex % 7 == 6);

                    return Expanded(
                      child: GestureDetector(
                        onTap: isFuture ? null : () => onDateTap(dateStr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 42,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary
                                : _getBackgroundColor(cs, dateType),
                            shape: BoxShape.circle,
                            border: _getBorder(
                              cs, dateType, isToday, isSelected),
                          ),
                          child: Center(
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 13,
                                color: isFuture
                                    ? cs.onSurfaceVariant.withAlpha(100)
                                    : isSelected
                                        ? cs.onPrimary
                                        : _getTextColor(cs, dateType, isWeekend),
                                fontWeight: (isToday || isSelected)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // 图例
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLegend(cs, theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required ColorScheme cs,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, color: cs.onSurface, size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  Color? _getBackgroundColor(ColorScheme cs, DateType? type) {
    return switch (type) {
      DateType.period => cs.error.withAlpha(46),
      DateType.ovulation => cs.tertiary.withAlpha(60),
      DateType.fertile => cs.tertiary.withAlpha(30),
      DateType.safe => cs.tertiaryContainer.withAlpha(60),
      DateType.predictedPeriod => cs.error.withAlpha(15),
      null => null,
    };
  }

  Color _getTextColor(ColorScheme cs, DateType? type, bool isWeekend) {
    return switch (type) {
      DateType.period => cs.error,
      DateType.ovulation => cs.tertiary,
      DateType.fertile => cs.tertiary,
      DateType.predictedPeriod => cs.error.withAlpha(180),
      _ => isWeekend ? cs.error.withAlpha(180) : cs.onSurface,
    };
  }

  BoxBorder? _getBorder(
    ColorScheme cs, DateType? type, bool isToday, bool isSelected) {
    if (isSelected) return null;
    if (isToday) {
      return Border.all(color: cs.primary, width: 1.5);
    }
    if (type == DateType.predictedPeriod) {
      return Border.all(
        color: cs.error.withAlpha(100),
        width: 1,
      );
    }
    return null;
  }

  Widget _buildLegend(ColorScheme cs, ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(cs, theme, cs.error, l10n.legendPeriod),
        const SizedBox(width: 12),
        _buildLegendItem(cs, theme, cs.tertiary, l10n.legendOvulation),
        const SizedBox(width: 12),
        _buildLegendItem(cs, theme, cs.tertiaryContainer, l10n.legendSafe),
        const SizedBox(width: 12),
        _buildLegendItem(cs, theme, cs.error.withAlpha(80), l10n.periodStatusPredicted),
      ],
    );
  }

  Widget _buildLegendItem(
      ColorScheme cs, ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withAlpha(46),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
