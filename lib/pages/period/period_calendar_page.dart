import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
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
      return _buildEmptyDateCard();
    }
    return PeriodDayDetailCard(
      record: record,
      onEdit: () => _navigateToForm(record),
      onDelete: () => _confirmDelete(provider, record.recordDate),
    );
  }

  Widget _buildEmptyDateCard() {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _navigateToForm(null),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text('点击记录经期', style: TextStyle(color: cs.primary)),
          ],
        ),
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

  void _navigateToForm(dynamic record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodDayFormPage(
          recordDate: _selectedDate!,
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
}
