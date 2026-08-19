import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'widgets/period_hero_card.dart';
import 'widgets/period_calendar_widget.dart';
import 'widgets/period_prediction_card.dart';
import 'widgets/period_backfill_sheet.dart';
import 'widgets/period_daily_detail_sheet.dart';
import 'widgets/period_onboarding_sheet.dart';

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

  void _checkOnboarding() {
    final provider = context.read<PeriodRecordProvider>();
    if (provider.cycles.isEmpty &&
        provider.statistics.totalRecords == 0 &&
        !AppConfigManager.instance.periodOnboardingDone) {
      _showOnboarding();
    }
  }

  void _showOnboarding() async {
    final result = await PeriodOnboardingSheet.show(context);
    if (result == null || !mounted) return;

    await AppConfigManager.instance.setPeriodOnboardingDone();

    if (result.lastPeriodStart != null && mounted) {
      final provider = context.read<PeriodRecordProvider>();
      final start = DateTime.parse(result.lastPeriodStart!);
      final end = result.lastPeriodEnd != null
          ? DateTime.parse(result.lastPeriodEnd!)
          : start.add(const Duration(days: 4));

      await provider.backfillPeriod(
        _dateStr(start),
        _dateStr(end),
        typicalPeriodDays: result.typicalPeriodDays,
        typicalCycleDays: result.typicalCycleDays,
      );
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
          if (provider.loading && provider.cycles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // 统计 Tile
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding.copyWith(bottom: spacing.formItemSpacing),
                  child: PeriodPredictionCard(statistics: provider.statistics),
                ),
              ),
              // Hero 状态卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                  child: PeriodHeroCard(
                    onStartPeriod: () => _handleStartPeriod(provider),
                    onEndPeriod: () => _handleEndPeriod(provider),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: spacing.formItemSpacing)),
              // 日历网格
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                  child: PeriodCalendarWidget(
                    year: provider.currentYear,
                    month: provider.currentMonth,
                    cycles: provider.recentCycles,
                    statistics: provider.statistics,
                    selectedDate: _selectedDate,
                    onDateTap: _onDateTap,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: spacing.formGroupSpacing)),
            ],
          );
        },
      ),
    );
  }

  // ── 交互方法 ──

  void _onDateTap(String date) {
    final provider = context.read<PeriodRecordProvider>();
    final today = DateTime.now();
    final todayStr = _dateStr(DateTime(today.year, today.month, today.day));

    // 未来日期 → 不可操作
    if (date.compareTo(todayStr) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10nManager.l10n.periodFutureDate),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // 根据状态决定底部弹窗内容
    final activeCycle = provider.activeCycle;

    if (activeCycle == null) {
      // 无未结束周期
      if (date.compareTo(todayStr) < 0) {
        _showBackfillAction(date, provider);
      } else {
        _showStartAction(date, provider);
      }
    } else {
      // 有未结束周期
      if (date.compareTo(activeCycle.startDate) < 0) {
        _showBackfillAction(date, provider);
      } else if (date.compareTo(todayStr) <= 0) {
        _showDayAction(date, provider);
      }
    }
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

  // ── 底部弹窗操作 ──

  /// 标记经期开始（底部弹窗）
  void _showStartAction(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final l10n = L10nManager.l10n;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                )),
              const SizedBox(height: 16),
              Icon(Icons.play_circle_outline, color: cs.primary, size: 40),
              const SizedBox(height: 12),
              Text(l10n.periodRecordStart,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text('$date  ${l10n.periodMarkTodayFirst}',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.operating ? null : () async {
                    Navigator.pop(ctx);
                    _confirmStartPeriod(provider, date);
                  },
                  icon: provider.operating
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_circle_outline, size: 18),
                  label: Text(l10n.periodMarkStart),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 补记历史经期（底部弹窗）
  void _showBackfillAction(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final l10n = L10nManager.l10n;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                )),
              const SizedBox(height: 16),
              Icon(Icons.date_range_outlined, color: cs.primary, size: 40),
              const SizedBox(height: 12),
              Text(l10n.periodBackfill,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(l10n.periodBackfillDesc,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.operating ? null : () async {
                    Navigator.pop(ctx);
                    _openBackfillSheet(provider, date);
                  },
                  icon: provider.operating
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.edit_calendar, size: 18),
                  label: Text(l10n.periodBackfill),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 日期操作（补充明细 / 结束经期）
  void _showDayAction(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final l10n = L10nManager.l10n;
    final dailyRecord = provider.getDailyRecordByDate(date);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                )),
              const SizedBox(height: 16),
              // 日期标题
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(date, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                ],
              ),
              if (dailyRecord != null) ...[
                const SizedBox(height: 6),
                Text(l10n.periodDailyRecordExists,
                  style: TextStyle(fontSize: 12, color: cs.primary)),
              ],
              const SizedBox(height: 16),

              // 补充明细按钮
              ListTile(
                leading: Icon(Icons.edit_note, color: cs.primary),
                title: Text(dailyRecord != null
                    ? l10n.periodEditDailyRecord
                    : l10n.periodAddDailyRecord),
                subtitle: Text(l10n.periodDailyRecord,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.outlineVariant.withAlpha(80)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  _openDailyDetailSheet(provider, date);
                },
              ),
              const SizedBox(height: 8),

              // 结束经期按钮
              ListTile(
                leading: Icon(Icons.stop_circle_outlined, color: cs.error),
                title: Text(l10n.periodEnd, style: TextStyle(color: cs.error)),
                subtitle: Text(date,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: cs.error.withAlpha(80)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: provider.operating ? null : () {
                  Navigator.pop(ctx);
                  _confirmEndPeriod(provider, date);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── 操作方法 ──

  void _handleStartPeriod(PeriodRecordProvider provider) {
    if (provider.cycles.isEmpty &&
        provider.statistics.totalRecords == 0 &&
        !AppConfigManager.instance.periodOnboardingDone) {
      _showOnboarding();
    } else {
      final today = DateTime.now();
      final todayStr = _dateStr(today);
      _confirmStartPeriod(provider, todayStr);
    }
  }

  void _handleEndPeriod(PeriodRecordProvider provider) {
    if (!provider.isInPeriod) return;
    final today = DateTime.now();
    final todayStr = _dateStr(today);
    _confirmEndPeriod(provider, todayStr);
  }

  void _confirmStartPeriod(PeriodRecordProvider provider, String date) async {
    if (provider.operating) return;

    if (provider.isInPeriod) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(L10nManager.l10n.periodAutoEndConfirmTitle),
          content: Text(L10nManager.l10n.periodAutoEndConfirmContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: Text(L10nManager.l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(L10nManager.l10n.confirm)),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final ok = await provider.startPeriod(date);
    if (mounted) {
      setState(() => _selectedDate = null);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10nManager.l10n.alreadyInPeriod)),
        );
      }
    }
  }

  void _confirmEndPeriod(PeriodRecordProvider provider, String date) async {
    if (provider.operating || provider.activeCycle == null) return;

    if (provider.lastDailyRecordDate != null) {
      final lastRecord = DateTime.parse(provider.lastDailyRecordDate!);
      final endDate = DateTime.parse(date);
      if (endDate.isBefore(lastRecord)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10nManager.l10n.periodEndDateBeforeLastRecord)),
          );
        }
        return;
      }
    }

    final ok = await provider.endPeriod(date);
    if (mounted) {
      setState(() => _selectedDate = null);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10nManager.l10n.periodEndFailed)),
        );
      }
    }
  }

  void _openBackfillSheet(PeriodRecordProvider provider, String fromDate) async {
    if (provider.operating) return;

    final prevCycle = provider.findPreviousCycle(fromDate);
    final nextCycle = provider.findNextCycle(fromDate);

    final range = await PeriodBackfillSheet.show(
      context,
      fromDate,
      minDate: prevCycle?.endDate,
      maxDate: nextCycle?.startDate,
    );
    if (range == null || !mounted) return;

    await provider.backfillPeriod(
      _dateStr(range.start),
      _dateStr(range.end),
    );
    setState(() => _selectedDate = null);
  }

  void _openDailyDetailSheet(PeriodRecordProvider provider, String date) async {
    final existing = provider.getDailyRecordByDate(date);
    await PeriodDailyDetailSheet.show(
      context,
      date: date,
      existing: existing,
      onSave: (data) async {
        await provider.upsertDailyRecord(
          date,
          flowLevel: data.flowLevel,
          symptoms: data.symptoms,
          mood: data.mood,
          remark: data.remark,
        );
      },
    );
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
