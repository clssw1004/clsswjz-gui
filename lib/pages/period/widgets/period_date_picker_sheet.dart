import 'package:flutter/material.dart';
import '../../../manager/l10n_manager.dart';

/// 底部弹出日期选择器
///
/// 显示当月日历网格，支持：
/// - 禁用未来日期
/// - 可选：限制最小日期
/// - 默认选中今天
class PeriodDatePickerSheet extends StatefulWidget {
  /// 标题
  final String title;

  /// 确认按钮文字
  final String confirmText;

  /// 默认选中日期 (yyyy-MM-dd)
  final String? initialDate;

  /// 最早可选日期 (yyyy-MM-dd)，之前的日子置灰不可选
  final String? minDate;

  /// 最晚可选日期 (yyyy-MM-dd)，之后的日子置灰不可选
  final String? maxDate;

  const PeriodDatePickerSheet({
    super.key,
    required this.title,
    required this.confirmText,
    this.initialDate,
    this.minDate,
    this.maxDate,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String confirmText,
    String? initialDate,
    String? minDate,
    String? maxDate,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PeriodDatePickerSheet(
        title: title,
        confirmText: confirmText,
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }

  @override
  State<PeriodDatePickerSheet> createState() => _PeriodDatePickerSheetState();
}

class _PeriodDatePickerSheetState extends State<PeriodDatePickerSheet> {
  late int _year;
  late int _month;
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initial = widget.initialDate != null
        ? DateTime.parse(widget.initialDate!)
        : now;
    _year = initial.year;
    _month = initial.month;
    _selectedDate = widget.initialDate ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isDisabled(String dateStr) {
    final date = DateTime.parse(dateStr);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 未来日期禁用
    if (date.isAfter(todayOnly)) return true;

    // 最早日期限制
    if (widget.minDate != null && dateStr.compareTo(widget.minDate!) < 0) {
      return true;
    }

    // 最晚日期限制
    if (widget.maxDate != null && dateStr.compareTo(widget.maxDate!) > 0) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final firstDay = DateTime(_year, _month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(_year, _month + 1, 0).day;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 月份导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: cs.onSurface),
                onPressed: () {
                  setState(() {
                    _month--;
                    if (_month < 1) {
                      _month = 12;
                      _year--;
                    }
                  });
                },
              ),
              Text(
                '$_year / ${_month.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: cs.onSurface),
                onPressed: () {
                  setState(() {
                    _month++;
                    if (_month > 12) {
                      _month = 1;
                      _year++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 星期头
          Row(
            children: [l10n.sunday, l10n.monday, l10n.tuesday, l10n.wednesday,
                    l10n.thursday, l10n.friday, l10n.saturday]
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // 日期网格
          ...List.generate(
            ((startWeekday + daysInMonth + 6) ~/ 7),
            (weekIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  final dayNum = cellIndex - startWeekday + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 42));
                  }
                  final dateStr =
                      '$_year-${_month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                  final isToday = dateStr == todayStr;
                  final isSelected = dateStr == _selectedDate;
                  final disabled = _isDisabled(dateStr);

                  return Expanded(
                    child: GestureDetector(
                      onTap: disabled
                          ? null
                          : () => setState(() => _selectedDate = dateStr),
                      child: Container(
                        height: 42,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : isToday
                                  ? cs.primary.withAlpha(20)
                                  : null,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 14,
                              color: disabled
                                  ? cs.onSurface.withAlpha(60)
                                  : isSelected
                                      ? cs.onPrimary
                                      : cs.onSurface,
                              fontWeight:
                                  isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selectedDate),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(widget.confirmText),
            ),
          ),
        ],
      ),
    );
  }
}
