import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_radius.dart';

/// 日历账目列表
class ItemListCalendar extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 初始账目列表
  final List<UserItemVO>? initialItems;

  /// 是否加载中
  final bool loading;

  /// 点击账目回调
  final void Function(UserItemVO item)? onItemTap;

  /// 加载更多回调
  final Future<void> Function()? onLoadMore;

  /// 是否还有更多数据
  final bool hasMore;

  const ItemListCalendar({
    super.key,
    required this.accountBook,
    this.initialItems,
    this.loading = false,
    this.onItemTap,
    this.onLoadMore,
    this.hasMore = true,
  });

  @override
  State<ItemListCalendar> createState() => _ItemListCalendarState();
}

class _ItemListCalendarState extends State<ItemListCalendar> {
  /// 当前选中的日期
  DateTime _selectedDay = DateTime.now();

  /// 当前显示的月份
  DateTime _focusedDay = DateTime.now();

  /// 账目按日期分组的Map
  Map<DateTime, List<UserItemVO>> _itemsByDay = {};

  @override
  void initState() {
    super.initState();
    _groupItemsByDay();
  }

  @override
  void didUpdateWidget(ItemListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _groupItemsByDay();
    }
  }

  /// 将账目按日期分组
  void _groupItemsByDay() {
    if (widget.initialItems == null) return;

    _itemsByDay = {};
    for (var item in widget.initialItems!) {
      final dateParts = item.accountDateOnly.split('-');
      if (dateParts.length == 3) {
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        ).toLocal();

        final key = DateTime(date.year, date.month, date.day);
        if (!_itemsByDay.containsKey(key)) {
          _itemsByDay[key] = [];
        }
        _itemsByDay[key]!.add(item);
      }
    }

    setState(() {});
  }

  /// 构建日期单元格装饰
  BoxDecoration? _buildCellDecoration(DateTime day, ThemeData theme) {
    final key = DateTime(day.year, day.month, day.day);
    final hasItems = _itemsByDay.containsKey(key);
    if (!hasItems) return null;

    final radius = theme.extension<ThemeRadius>()?.radius ?? 8.0;
    return BoxDecoration(
      color: theme.colorScheme.primary.withAlpha(10),
      border: Border.all(
        color: theme.colorScheme.primary.withAlpha(38),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 构建日期单元格标记
  Widget? _buildCellMarker(DateTime day, ThemeData theme,
      {bool isSelected = false}) {
    final key = DateTime(day.year, day.month, day.day);
    final items = _itemsByDay[key] ?? [];
    if (items.isEmpty) return null;

    final radius = theme.extension<ThemeRadius>()?.radius ?? 8.0;
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.onPrimary.withAlpha(51)
                : theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(radius / 2),
          ),
          child: Text(
            '${items.length}笔',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              fontSize: 8,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (income > 0 || expense > 0)
          Container(
            margin: const EdgeInsets.only(top: 0.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (income > 0)
                  Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withAlpha(204)
                          : ColorUtil.INCOME,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (income > 0 && expense > 0) const SizedBox(width: 1),
                if (expense > 0)
                  Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withAlpha(204)
                          : ColorUtil.EXPENSE,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建选中日期的账目列表
  Widget _buildSelectedDayItems(ThemeData theme) {
    final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final items = _itemsByDay[key] ?? [];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: theme.colorScheme.outline.withAlpha(128),
              ),
              const SizedBox(height: 12),
              Text(
                L10nManager.l10n.noAccountItems,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline.withAlpha(128),
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dateFormat.format(_selectedDay),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length}笔',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorUtil.INCOME.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '收入',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorUtil.INCOME,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${income.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: ColorUtil.INCOME,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorUtil.EXPENSE.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '支出',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorUtil.EXPENSE,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '-${expense.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: ColorUtil.EXPENSE,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isIncome = item.amount > 0;
            final color = isIncome ? ColorUtil.INCOME : ColorUtil.EXPENSE;

            return InkWell(
              onTap: () => widget.onItemTap?.call(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isIncome ? Icons.add : Icons.remove,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item.accountTimeOnly.substring(0, 5),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withAlpha(128),
                                  height: 1.2,
                                ),
                              ),
                              if (item.description?.isNotEmpty == true) ...[
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withAlpha(128),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withAlpha(128),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${isIncome ? '+' : ''}${item.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
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

  /// 构建日期单元格
  Widget _buildDateCell(DateTime day, ThemeData theme,
      {bool isSelected = false, bool isToday = false}) {
    final hasItems = _buildCellDecoration(day, theme) != null;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(2),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  colorScheme.primary,
                  colorScheme.primary.withAlpha(230),
                ]
              : isToday
                  ? [
                      colorScheme.primary.withAlpha(38),
                      colorScheme.primary.withAlpha(13),
                    ]
                  : [
                      Colors.transparent,
                      Colors.transparent,
                    ],
        ),
        border: isToday
            ? Border.all(
                color: colorScheme.primary.withAlpha(77),
                width: 1.5,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(64),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : isToday
                      ? colorScheme.primary
                      : null,
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasItems)
            _buildCellMarker(day, theme, isSelected: isSelected) ??
                const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 8.0;
    final locale = Localizations.localeOf(context).toString();

    if (widget.loading &&
        (widget.initialItems == null || widget.initialItems!.isEmpty)) {
      return Center(child: Text(L10nManager.l10n.loading));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(radius * 2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TableCalendar<UserItemVO>(
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: locale,
                  availableCalendarFormats: const {
                    CalendarFormat.month: '',
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    headerPadding: EdgeInsets.all(radius * 2),
                    headerMargin: EdgeInsets.zero,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: theme.textTheme.bodySmall!.copyWith(
                      color: ColorUtil.EXPENSE.withAlpha(204),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: ColorUtil.EXPENSE.withAlpha(204),
                    ),
                    holidayTextStyle: theme.textTheme.bodyMedium!,
                    todayDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withAlpha(26),
                          colorScheme.primary.withAlpha(13),
                        ],
                      ),
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(77),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withAlpha(230),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(64),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    cellMargin: EdgeInsets.all(radius / 2),
                    cellPadding: EdgeInsets.zero,
                    rangeHighlightColor: colorScheme.primary.withAlpha(20),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDateCell(day, theme);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDateCell(day, theme, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDateCell(day, theme, isSelected: true);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectedDayItems(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
