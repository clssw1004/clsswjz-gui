import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/item_list_provider.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';

import '../../utils/color_util.dart';

/// 日历视图账目列表
class ItemListCalendar extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 点击账目回调
  final void Function(UserItemVO item)? onItemTap;

  const ItemListCalendar({
    super.key,
    required this.accountBook,
    this.onItemTap,
  });

  @override
  State<ItemListCalendar> createState() => _ItemListCalendarState();
}

class _ItemListCalendarState extends State<ItemListCalendar> {
  /// 当前选中的日期
  DateTime _selectedDate = DateTime.now();

  /// 当前月份的账目数据
  List<UserItemVO>? _monthItems;

  /// 是否正在加载
  bool _loading = false;

  /// 比较是否同一天（仅年月日）
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  /// 加载当前月份的数据
  Future<void> _loadMonthData() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final provider = context.read<ItemListProvider>();
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      final items = await provider.loadItemsByDateRange(start, end);
      if (mounted) {
        setState(() {
          _monthItems = items;
          _loading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void didUpdateWidget(ItemListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountBook.id != widget.accountBook.id) {
      _loadMonthData();
    }
  }

  /// 获取某天账目
  List<UserItemVO> _itemsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day)
        .toIso8601String()
        .substring(0, 10);
    return _monthItems
            ?.where((e) => e.accountDateOnly == key)
            .toList() ??
        [];
  }

  /// 构建日期单元格
  Widget _buildDateCell(DateTime day, ThemeData theme,
      {bool isSelected = false, bool isToday = false}) {
    final colorScheme = theme.colorScheme;
    final items = _itemsForDay(day);
    final hasIncome = items.any((e) => e.amount > 0);
    final hasExpense = items.any((e) => e.amount <= 0);

    // 选择态：实心圆
    if (isSelected) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 今天：空心圆
    if (isToday) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 普通日期
    return SizedBox(
      width: 40,
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          // 小圆点标记：有收支时显示
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasIncome)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorUtil.income,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasIncome && hasExpense) const SizedBox(width: 2),
                  if (hasExpense)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorUtil.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建选中日期的账目列表
  Widget _buildSelectedDayItems(ThemeData theme) {
    final spacing = theme.spacing;
    final items = _itemsForDay(_selectedDate);

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 16,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                L10nManager.l10n.noAccountItems,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 计算当天总收支
    double income = 0;
    double expense = 0;
    for (var item in items) {
      if (item.amount > 0) {
        income += item.amount;
      } else {
        expense += item.amount.abs();
      }
    }

    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMd(locale);

    return Column(
      children: [
        // 日期摘要条
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.listItemMargin.horizontal, 12,
              spacing.listItemMargin.horizontal, 4),
          child: Row(
            children: [
              Text(
                dateFormat.format(_selectedDate),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (income > 0)
                Text(
                  '+${income.toStringAsFixed(2)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorUtil.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (income > 0 && expense > 0) const SizedBox(width: 8),
              if (expense > 0)
                Text(
                  '-${expense.toStringAsFixed(2)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorUtil.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.listItemMargin.horizontal,
          ),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 48,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isIncome = item.amount > 0;
            final color = isIncome ? ColorUtil.income : ColorUtil.expense;

            return InkWell(
              onTap: () => widget.onItemTap?.call(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 颜色圆点
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 中间内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.categoryName ?? '',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.description?.isNotEmpty == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    item.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule_outlined,
                                  size: 11,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                              const SizedBox(width: 3),
                              Text(
                                item.accountTimeOnly,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                              // 标签
                              if (item.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                ...() {
                                  final tagWidgets = <Widget>[];
                                  for (var i = 0;
                                      i < item.tags.length && i < 2;
                                      i++) {
                                    tagWidgets.add(_buildTagChip(
                                        item.tags[i].name, theme));
                                    if (i < item.tags.length - 1 &&
                                        i < 1) {
                                      tagWidgets.add(
                                          const SizedBox(width: 4));
                                    }
                                  }
                                  if (item.tags.length > 2) {
                                    tagWidgets.add(const SizedBox(width: 4));
                                    tagWidgets.add(Text(
                                      '+${item.tags.length - 2}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ));
                                  }
                                  return tagWidgets;
                                }(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 金额
                    Text(
                      '${isIncome ? '+' : ''}${item.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagChip(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    if (_loading && (_monthItems == null || _monthItems!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(L10nManager.l10n.loading),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 8,
        bottom: spacing.listItemMargin.vertical,
      ),
      child: Column(
        children: [
          Container(
            margin: spacing.listItemMargin,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 380,
                  child: SfCalendar(
                    view: CalendarView.month,
                    showNavigationArrow: true,
                    showDatePickerButton: false,
                    initialDisplayDate: _selectedDate,
                    initialSelectedDate: _selectedDate,
                    minDate: DateTime.utc(2010, 1, 1),
                    maxDate: DateTime.now(),
                    selectionDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    monthViewSettings: MonthViewSettings(
                      numberOfWeeksInView: 6,
                      showAgenda: false,
                      showTrailingAndLeadingDates: false,
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.none,
                    ),
                    headerStyle: CalendarHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ) ??
                          const TextStyle(),
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                      dayTextStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
                          ) ??
                          const TextStyle(fontSize: 11),
                    ),
                    monthCellBuilder: (context, details) {
                      final DateTime day = DateTime(
                          details.date.year, details.date.month,
                          details.date.day);
                      // 仅显示当前月份日期
                      if (day.month != _selectedDate.month ||
                          day.year != _selectedDate.year) {
                        return const SizedBox.shrink();
                      }
                      final bool isToday = _isSameDate(day, DateTime.now());
                      final bool isSelected =
                          _isSameDate(day, _selectedDate);
                      return _buildDateCell(
                        day,
                        theme,
                        isSelected: isSelected,
                        isToday: isToday,
                      );
                    },
                    onSelectionChanged: (details) {
                      final DateTime? date = details.date;
                      if (date == null) return;
                      if (!mounted) return;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() {
                          _selectedDate = DateTime(
                              date.year, date.month, date.day);
                        });
                      });
                    },
                    onViewChanged: (details) {
                      final visible = details.visibleDates;
                      if (visible.isEmpty) return;
                      final mid = visible[visible.length ~/ 2];
                      final monthAnchor =
                          DateTime(mid.year, mid.month, 1);
                      final currentAnchor = DateTime(_selectedDate.year,
                          _selectedDate.month, 1);
                      if (monthAnchor != currentAnchor) {
                        if (!mounted) return;
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _selectedDate = monthAnchor;
                          });
                          _loadMonthData();
                        });
                      }
                    },
                    todayHighlightColor: colorScheme.primary,
                    backgroundColor: Colors.transparent,
                    cellBorderColor:
                        colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                // 选中日期账目列表
                _buildSelectedDayItems(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
