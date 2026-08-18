import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'widgets/period_hero_card.dart';
import 'widgets/period_calendar_widget.dart';
import 'widgets/period_prediction_card.dart';
import 'widgets/period_day_detail_card.dart';
import 'widgets/period_date_picker_sheet.dart';
import 'widgets/period_onboarding_sheet.dart';
import 'period_day_form_page.dart';

class PeriodCalendarPage extends StatefulWidget {
  const PeriodCalendarPage({super.key});

  @override
  State<PeriodCalendarPage> createState() => _PeriodCalendarPageState();
}

class _PeriodCalendarPageState extends State<PeriodCalendarPage> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PeriodRecordProvider>().loadRecords();
      _checkOnboarding();
    });
  }

  /// 检查是否需要显示初次引导
  void _checkOnboarding() {
    final provider = context.read<PeriodRecordProvider>();
    if (provider.records.isEmpty &&
        provider.statistics.totalRecords == 0 &&
        !AppConfigManager.instance.periodOnboardingDone) {
      _showOnboarding();
    }
  }

  void _showOnboarding() async {
    final result = await PeriodOnboardingSheet.show(context);
    if (result == null || !mounted) return;

    // 标记引导已完成
    await AppConfigManager.instance.setPeriodOnboardingDone();

    // 如果用户填写了数据，创建对应记录
    if (result.lastPeriodStart != null && mounted) {
      final provider = context.read<PeriodRecordProvider>();
      final start = DateTime.parse(result.lastPeriodStart!);
      final end = result.lastPeriodEnd != null
          ? DateTime.parse(result.lastPeriodEnd!)
          : start.add(const Duration(days: 4)); // 默认 5 天

      // 创建每天的经期记录
      var current = start;
      while (!current.isAfter(end)) {
        final ds = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
        await provider.updatePeriodDay(
          ds,
          periodStatus: 'period',
          flowLevel: 'medium',
        );
        current = current.add(const Duration(days: 1));
      }

      // 切换到开始日期所在月份
      await provider.changeMonth(start.year, start.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(title: Text(L10nManager.l10n.periodRecord)),
      body: Consumer<PeriodRecordProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Hero 状态卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding,
                  child: PeriodHeroCard(
                    onStartPeriod: () {
                      // 无数据且未完成引导 → 打开引导页
                      if (provider.records.isEmpty &&
                          provider.statistics.totalRecords == 0 &&
                          !AppConfigManager.instance.periodOnboardingDone) {
                        _showOnboarding();
                      } else {
                        _pickStartDate(provider);
                      }
                    },
                    onEndPeriod: () => _pickEndDate(provider),
                  ),
                ),
              ),
              // 日历网格（含图例）
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                  child: PeriodCalendarWidget(
                    year: provider.currentYear,
                    month: provider.currentMonth,
                    records: provider.records,
                    statistics: provider.statistics,
                    selectedDate: _selectedDate,
                    onDateTap: _onDateTap,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                  ),
                ),
              ),
              // 预测统计 Tile
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                  child: PeriodPredictionCard(statistics: provider.statistics),
                ),
              ),
              // 选中日期详情
              if (_selectedDate != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                    child: _buildSelectedDateDetail(provider),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: spacing.formGroupSpacing)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateDetail(PeriodRecordProvider provider) {
    final record = provider.getRecordByDate(_selectedDate!);
    if (record == null) {
      return _buildEmptyDateCard(provider);
    }
    return PeriodDayDetailCard(
      record: record,
      onEdit: () => _navigateToForm(record),
      onDelete: () => _confirmDelete(provider, record.recordDate),
      onDeleteCycle: record.periodStatus == PeriodStatus.period
          ? () => _confirmDeleteCycle(provider, record.recordDate)
          : null,
    );
  }

  Widget _buildEmptyDateCard(PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final inPeriod = provider.isInPeriod;
    final operating = provider.operating;
    final today = DateTime.now();
    final selected = DateTime.parse(_selectedDate!);
    final isPast = selected.isBefore(DateTime(today.year, today.month, today.day));

    return Container(
      padding: spacing.formItemPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
          if (inPeriod) ...[
            Icon(Icons.check_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.periodOngoing, style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(L10nManager.l10n.periodAutoRecord,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: operating ? null : () => _pickEndDate(provider),
                icon: operating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.stop_circle_outlined, size: 18, color: cs.error),
                label: Text(L10nManager.l10n.periodEnd, style: TextStyle(color: cs.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.error.withAlpha(128)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (isPast) ...[
            Icon(Icons.date_range_outlined, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.periodBackfill, style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(L10nManager.l10n.periodSelectRange,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: operating ? null : () => _backfillPeriodRange(provider, _selectedDate!),
                icon: operating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.date_range, size: 18),
                label: Text(L10nManager.l10n.periodSelectRange),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            Icon(Icons.add_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.periodRecordStart, style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(L10nManager.l10n.periodMarkTodayFirst,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: operating ? null : () => _confirmStartPeriod(provider, _selectedDate!),
                icon: operating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_circle_outline, size: 18),
                label: Text(L10nManager.l10n.periodMarkStart),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onDateTap(String date) {
    setState(() => _selectedDate = date);
  }

  void _previousMonth() {
    final provider = context.read<PeriodRecordProvider>();
    var month = provider.currentMonth - 1;
    var year = provider.currentYear;
    if (month < 1) { month = 12; year--; }
    provider.changeMonth(year, month);
    setState(() => _selectedDate = null);
  }

  void _nextMonth() {
    final provider = context.read<PeriodRecordProvider>();
    var month = provider.currentMonth + 1;
    var year = provider.currentYear;
    if (month > 12) { month = 1; year++; }
    provider.changeMonth(year, month);
    setState(() => _selectedDate = null);
  }

  void _navigateToForm(PeriodRecordVO record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodDayFormPage(
          recordDate: record.recordDate,
          record: record,
        ),
      ),
    );
    setState(() => _selectedDate = null);
  }

  void _confirmDelete(PeriodRecordProvider provider, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.deleteRecord),
        content: Text(L10nManager.l10n.confirmDeleteDayRecord),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10nManager.l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePeriodDay(date);
              setState(() => _selectedDate = null);
            },
            child: Text(L10nManager.l10n.deleteBtn, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCycle(PeriodRecordProvider provider, String date) {
    final dates = provider.findCycleDates(date);
    final count = dates.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.deleteCycle),
        content: Text(L10nManager.l10n.deleteCycleConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteCycle(date);
              setState(() => _selectedDate = null);
            },
            child: Text(
              L10nManager.l10n.deleteBtn,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStartPeriod(PeriodRecordProvider provider, String date) {
    if (provider.operating || provider.isInPeriod) return;
    // 无数据且未完成引导 → 打开引导页
    if (provider.records.isEmpty &&
        provider.statistics.totalRecords == 0 &&
        !AppConfigManager.instance.periodOnboardingDone) {
      _showOnboarding();
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.markPeriodStart),
        content: Text(L10nManager.l10n.confirmMarkFirstDay(date)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10nManager.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.startPeriod(date);
              if (mounted) {
                setState(() => _selectedDate = null);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(L10nManager.l10n.alreadyInPeriod)),
                  );
                }
              }
            },
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// 选择经期开始日期（底部日期选择器）
  /// 历史补记：选择日期范围，一次性填充
  void _backfillPeriodRange(PeriodRecordProvider provider, String fromDate) async {
    if (provider.operating) return;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final start = DateTime.parse(fromDate);

    final range = await showDateRangePicker(
      context: context,
      firstDate: start,
      lastDate: todayOnly,
      initialDateRange: DateTimeRange(start: start, end: start),
    );

    if (range == null || !mounted) return;

    // 从 range.start 到 range.end 全部填充为 period
    var current = range.start;
    while (!current.isAfter(range.end)) {
      final ds = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      await provider.updatePeriodDay(
        ds,
        periodStatus: 'period',
        flowLevel: 'medium',
      );
      current = current.add(const Duration(days: 1));
    }

    setState(() => _selectedDate = null);
  }

  void _pickStartDate(PeriodRecordProvider provider) async {
    if (provider.isInPeriod) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final selected = await PeriodDatePickerSheet.show(
      context: context,
      title: L10nManager.l10n.selectStartDate,
      confirmText: L10nManager.l10n.confirmStartDate,
      maxDate: todayStr,
    );
    if (selected != null && mounted) {
      final ok = await provider.startPeriod(selected);
      setState(() => _selectedDate = null);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10nManager.l10n.alreadyInPeriod)),
        );
      }
    }
  }

  /// 选择经期结束日期（底部日期选择器）
  void _pickEndDate(PeriodRecordProvider provider) async {
    if (provider.operating) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final startDate = provider.periodStartDate;
    // 默认选中用户点击的日期（支持历史补记）
    final initialDate = _selectedDate ?? todayStr;
    final selected = await PeriodDatePickerSheet.show(
      context: context,
      title: L10nManager.l10n.selectEndDate,
      confirmText: L10nManager.l10n.confirmEndDate,
      minDate: startDate,
      maxDate: todayStr,
      initialDate: initialDate,
    );
    if (selected != null && mounted) {
      await provider.endPeriod(endDate: selected);
      setState(() => _selectedDate = null);
    }
  }
}
