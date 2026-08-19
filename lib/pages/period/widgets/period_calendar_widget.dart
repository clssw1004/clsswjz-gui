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
  final List<PeriodCycleVO> recentCycles;
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
    this.recentCycles = const [],
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
    // 合并当月周期 + 近期周期（去重），确保跨月/历史周期都能渲染
    final allCycles = [
      ...cycles,
      ...recentCycles.where(
        (c) => !cycles.any((m) => m.id == c.id),
      ),
    ];
    // 从 cycles 计算日期类型
    final dateTypes = PeriodPredictionService.getMonthDateTypes(allCycles, statistics);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final firstDay = DateTime(year, month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withAlpha(50),
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
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$year',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: '  /  '),
                      TextSpan(
                        text: month.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 17,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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
          const SizedBox(height: 10),
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
                        fontSize: 11,
                        letterSpacing: 0.4,
                        color: isWeekend
                            ? _PeriodPalette.of(context).weekend
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
          // 日期网格（圆角矩形格子）
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
                      return const Expanded(child: SizedBox(height: 38));
                    }
                    final dateStr =
                        '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                    final dateType = dateTypes[dateStr];
                    final isToday = dateStr == todayStr;
                    final isSelected = dateStr == selectedDate;
                    final isFuture = dateStr.compareTo(todayStr) > 0;
                    final isWeekend =
                        (cellIndex % 7 == 0) || (cellIndex % 7 == 6);
                    final style = _styleFor(context, dateType);
                    final isPredicted = dateType == DateType.predictedPeriod;

                    // 经期连续日连成胶囊条：左右相邻同为经期时横向无缝衔接
                    final isPeriod = dateType == DateType.period;
                    final leftIsPeriod = isPeriod &&
                        dateTypes[_addDays(dateStr, -1)] == DateType.period;
                    final rightIsPeriod = isPeriod &&
                        dateTypes[_addDays(dateStr, 1)] == DateType.period;
                    final leftMargin = leftIsPeriod ? 0.0 : 2.0;
                    final rightMargin = rightIsPeriod ? 0.0 : 2.0;
                    final borderRadius = (isPeriod && !isSelected)
                        ? BorderRadius.horizontal(
                            left: Radius.circular(leftIsPeriod ? 0 : 10),
                            right: Radius.circular(rightIsPeriod ? 0 : 10),
                          )
                        : BorderRadius.circular(10);

                    return Expanded(
                      child: GestureDetector(
                        onTap: isFuture ? null : () => onDateTap(dateStr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 38,
                          margin: EdgeInsets.fromLTRB(
                              leftMargin, 2, rightMargin, 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary
                                : (isPredicted
                                    ? Colors.transparent
                                    : style.background),
                            borderRadius: borderRadius,
                            border: isSelected
                                ? null
                                : isToday
                                    ? Border.all(color: cs.primary, width: 1.5)
                                    : (!isPredicted && style.border != null)
                                        ? Border.all(
                                            color: style.border!, width: 1)
                                        : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 预测经期：虚线描边（区别于实心经期）
                              if (isPredicted && !isSelected && !isToday)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _DashedBorderPainter(
                                      color: style.border!,
                                      radius: 10,
                                    ),
                                  ),
                                ),
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isFuture
                                      ? cs.onSurfaceVariant.withAlpha(90)
                                      : isSelected
                                          ? cs.onPrimary
                                          : (dateType == null && isWeekend)
                                              ? _PeriodPalette
                                                  .of(context)
                                                  .weekend
                                              : style.text,
                                  fontWeight: (isToday ||
                                          isSelected ||
                                          dateType == DateType.ovulation)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              // 今天：数字下方小圆点，增强辨识
                              if (isToday && !isSelected)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
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
            child: _buildLegend(context, theme, l10n),
          ),
        ],
      ),
    );
  }

  String _addDays(String date, int days) {
    final d = DateTime.parse(date).add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _buildNavButton({
    required IconData icon,
    required ColorScheme cs,
    VoidCallback? onPressed,
  }) {    return SizedBox(
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

  /// 日期类型配色（柔和粉彩，适配深浅色主题）
  ///
  /// - 经期：玫瑰粉实心；预测经期：玫瑰粉描边圆环（区分"未发生"）
  /// - 排卵日：紫罗兰实心（加粗）；易孕期：更淡紫填充 + 淡紫描边
  /// - 安全期：鼠尾草绿
  _DateTypeStyle _styleFor(BuildContext context, DateType? type) {
    final p = _PeriodPalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return switch (type) {
      DateType.period => _DateTypeStyle(
          background: p.periodBg,
          text: p.period,
        ),
      DateType.predictedPeriod => _DateTypeStyle(
          background: Colors.transparent,
          text: p.period.withAlpha(dark ? 255 : 235),
          border: p.period.withAlpha(dark ? 160 : 120),
        ),
      DateType.ovulation => _DateTypeStyle(
          background: p.ovulationBg,
          text: p.ovulation,
        ),
      DateType.fertile => _DateTypeStyle(
          background: p.fertileBg,
          text: p.ovulation.withAlpha(dark ? 235 : 220),
          border: p.ovulation.withAlpha(dark ? 110 : 75),
        ),
      DateType.safe => _DateTypeStyle(
          background: p.safeBg,
          text: p.safe,
        ),
      null => _DateTypeStyle(
          background: Colors.transparent,
          text: cs.onSurface,
        ),
    };
  }

  Widget _buildLegend(BuildContext context, ThemeData theme, dynamic l10n) {
    final p = _PeriodPalette.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
            context, theme, DateType.period, l10n.legendPeriod, p.periodBg),
        const SizedBox(width: 14),
        _buildLegendItem(context, theme, DateType.ovulation,
            l10n.legendOvulation, p.ovulationBg),
        const SizedBox(width: 14),
        _buildLegendItem(
            context, theme, DateType.safe, l10n.legendSafe, p.safeBg),
        const SizedBox(width: 14),
        _buildLegendItem(context, theme, DateType.predictedPeriod,
            l10n.periodStatusPredicted, Colors.transparent),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, ThemeData theme, DateType type,
      String label, Color background) {
    final style = _styleFor(context, type);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(
              color: style.border ?? style.text,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 柔和粉彩配色板（light / dark 两套）
class _PeriodPalette {
  final Color period;
  final Color periodBg;
  final Color ovulation;
  final Color ovulationBg;
  final Color fertileBg;
  final Color safe;
  final Color safeBg;
  final Color weekend;

  const _PeriodPalette({
    required this.period,
    required this.periodBg,
    required this.ovulation,
    required this.ovulationBg,
    required this.fertileBg,
    required this.safe,
    required this.safeBg,
    required this.weekend,
  });

  static _PeriodPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }

  /// 浅色：低饱和高明度，粉白基底
  static const _light = _PeriodPalette(
    period: Color(0xFFD9536F), // 玫瑰粉
    periodBg: Color(0xFFFDE9EF), // 极淡粉
    ovulation: Color(0xFF8A6BD1), // 柔和紫罗兰
    ovulationBg: Color(0xFFF0EAFB), // 淡紫
    fertileBg: Color(0xFFF7F3FD), // 更淡紫
    safe: Color(0xFF4E9A77), // 鼠尾草绿
    safeBg: Color(0xFFE9F4ED), // 淡绿
    weekend: Color(0xFFC79AA6), // 淡玫瑰灰（周末）
  );

  /// 深色：同色相提亮，背景加深保证对比度
  static const _dark = _PeriodPalette(
    period: Color(0xFFF48BA6),
    periodBg: Color(0xFF482230),
    ovulation: Color(0xFFC7ABF0),
    ovulationBg: Color(0xFF362A4B),
    fertileBg: Color(0xFF2E2540),
    safe: Color(0xFF8FD0B0),
    safeBg: Color(0xFF1F372B),
    weekend: Color(0xFFD9A5B2),
  );
}

/// 日期类型配色数据
class _DateTypeStyle {
  final Color background;
  final Color text;
  final Color? border;

  const _DateTypeStyle({
    required this.background,
    required this.text,
    this.border,
  });
}

/// 虚线圆角矩形描边（用于预测经期，区别于实心经期）
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  /// 虚线单元长度
  static const double _dashWidth = 3.5;

  /// 虚线间隙
  static const double _dashGap = 2.5;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
