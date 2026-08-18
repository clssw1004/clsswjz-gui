import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'widgets/period_hero_card.dart';
import 'widgets/period_calendar_widget.dart';
import 'widgets/period_prediction_card.dart';
import 'widgets/period_day_detail_card.dart';
import 'widgets/period_date_picker_sheet.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodRecordProvider>().loadRecords();
    });
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
                    onStartPeriod: () => _pickStartDate(provider),
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
            Icon(Icons.add_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.periodBackfill, style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(L10nManager.l10n.periodMarkFirstDay,
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

  void _confirmStartPeriod(PeriodRecordProvider provider, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.markPeriodStart),
        content: Text(L10nManager.l10n.confirmMarkFirstDay(date)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10nManager.l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.startPeriod(date);
              setState(() => _selectedDate = null);
            },
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// 选择经期开始日期（底部日期选择器）
  void _pickStartDate(PeriodRecordProvider provider) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final selected = await PeriodDatePickerSheet.show(
      context: context,
      title: L10nManager.l10n.selectStartDate,
      confirmText: L10nManager.l10n.confirmStartDate,
      maxDate: todayStr,
    );
    if (selected != null && mounted) {
      await provider.startPeriod(selected);
      setState(() => _selectedDate = null);
    }
  }

  /// 选择经期结束日期（底部日期选择器）
  void _pickEndDate(PeriodRecordProvider provider) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final startDate = provider.periodStartDate;
    final selected = await PeriodDatePickerSheet.show(
      context: context,
      title: L10nManager.l10n.selectEndDate,
      confirmText: L10nManager.l10n.confirmEndDate,
      minDate: startDate,
      maxDate: todayStr,
      initialDate: todayStr,
    );
    if (selected != null && mounted) {
      await provider.endPeriod(endDate: selected);
      setState(() => _selectedDate = null);
    }
  }
}
