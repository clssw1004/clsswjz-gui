import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'widgets/period_calendar_widget.dart';
import 'widgets/period_prediction_card.dart';
import 'widgets/period_day_detail_card.dart';
import 'widgets/period_legend.dart';
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
      appBar: const CommonAppBar(title: Text('经期记录')),
      body: Consumer<PeriodRecordProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                  child: const PeriodLegend(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                  child: PeriodPredictionCard(statistics: provider.statistics),
                ),
              ),
              if (_selectedDate != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                    child: _buildSelectedDateDetail(provider),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
    final inPeriod = provider.isInPeriod;
    final today = DateTime.now();
    final selected = DateTime.parse(_selectedDate!);
    final isPast = selected.isBefore(DateTime(today.year, today.month, today.day));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
          if (inPeriod) ...[
            Icon(Icons.check_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text('经期进行中', style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text('下次经期开始时会自动记录',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmEndPeriod(provider),
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: const Text('经期结束'),
              ),
            ),
          ] else if (isPast) ...[
            Icon(Icons.add_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text('补记经期', style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text('将从该日起标记约${provider.statistics.averagePeriodLength > 0 ? provider.statistics.averagePeriodLength : 5}天为经期',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _confirmStartPeriod(provider, _selectedDate!),
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('标记经期开始'),
              ),
            ),
          ] else ...[
            Icon(Icons.add_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text('记录经期', style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text('将从今天开始自动记录经期',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _confirmStartPeriod(provider, _selectedDate!),
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('标记经期开始'),
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
        title: const Text('删除记录'),
        content: const Text('确定删除该日的经期记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePeriodDay(date);
              setState(() => _selectedDate = null);
            },
            child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _confirmStartPeriod(PeriodRecordProvider provider, String date) {
    final fillDays = provider.statistics.averagePeriodLength > 0
        ? provider.statistics.averagePeriodLength
        : 5;
    final selected = DateTime.parse(date);
    final end = selected.add(Duration(days: fillDays - 1));
    final today = DateTime.now();
    final actualEnd = end.isAfter(DateTime(today.year, today.month, today.day))
        ? DateTime(today.year, today.month, today.day)
        : end;
    final days = actualEnd.difference(selected).inDays + 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('标记经期开始'),
        content: Text('将从 $date 起标记 $days 天为经期，确定吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.startPeriod(date);
              setState(() => _selectedDate = null);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmEndPeriod(PeriodRecordProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('经期结束'),
        content: const Text('今天将被标记为经期最后一天，之后不再自动记录。确定吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.endPeriod();
              setState(() => _selectedDate = null);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
