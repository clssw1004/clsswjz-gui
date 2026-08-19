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

  /// 检查是否需要显示初次引导
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

      // 创建周期（含典型天数配置）
      await provider.backfillPeriod(
        _dateStr(start),
        _dateStr(end),
        typicalPeriodDays: result.typicalPeriodDays,
        typicalCycleDays: result.typicalCycleDays,
      );

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

  /// 构建选中日期的详情/操作卡片
  Widget _buildSelectedDateDetail(PeriodRecordProvider provider) {
    final date = _selectedDate!;
    final today = DateTime.now();
    final todayStr = _dateStr(DateTime(today.year, today.month, today.day));
    final activeCycle = provider.activeCycle;

    // 点击未来日期 → 不可操作
    if (date.compareTo(todayStr) > 0) {
      return _buildDisabledCard(L10nManager.l10n.periodFutureDate);
    }

    if (activeCycle == null) {
      // 无未结束周期
      if (date.compareTo(todayStr) < 0) {
        // 历史日期 → 补记经期
        return _buildBackfillCard(date, provider);
      } else {
        // 今天 → 标记经期开始
        return _buildStartCard(date, provider);
      }
    } else {
      // 有未结束周期
      if (date.compareTo(activeCycle.startDate) < 0) {
        // 周期开始日之前 → 补记历史
        return _buildBackfillCard(date, provider);
      } else if (date.compareTo(todayStr) <= 0) {
        // 周期内且不晚于今天 → 补充明细 或 结束经期
        return _buildDayActionCard(date, provider);
      } else {
        return _buildDisabledCard(L10nManager.l10n.periodFutureDate);
      }
    }
  }

  /// 无操作卡片（未来日期）
  Widget _buildDisabledCard(String message) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Container(
      padding: spacing.formItemPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 32),
          const SizedBox(height: 8),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          )),
        ],
      ),
    );
  }

  /// 补记经期卡片
  Widget _buildBackfillCard(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Container(
      padding: spacing.formItemPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.date_range_outlined, color: cs.primary, size: 32),
          const SizedBox(height: 8),
          Text(L10nManager.l10n.periodBackfill, style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.primary, fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: 4),
          Text(L10nManager.l10n.periodBackfillDesc,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.operating ? null : () => _openBackfillSheet(provider, date),
              icon: provider.operating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.edit_calendar, size: 18),
              label: Text(L10nManager.l10n.periodBackfill),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 标记经期开始卡片
  Widget _buildStartCard(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Container(
      padding: spacing.formItemPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
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
              onPressed: provider.operating ? null : () => _confirmStartPeriod(provider, date),
              icon: provider.operating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_circle_outline, size: 18),
              label: Text(L10nManager.l10n.periodMarkStart),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 日期操作卡片（补充明细 或 结束经期）
  Widget _buildDayActionCard(String date, PeriodRecordProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final dailyRecord = provider.getDailyRecordByDate(date);

    return Container(
      padding: spacing.formItemPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        children: [
          // 已有明细时显示
          if (dailyRecord != null) ...[
            Icon(Icons.check_circle_outline, color: cs.primary, size: 32),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.periodDailyRecordExists,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.primary, fontWeight: FontWeight.w500,
              )),
            const SizedBox(height: 4),
          ] else ...[
            Icon(Icons.edit_note, color: cs.primary, size: 32),
            const SizedBox(height: 8),
          ],

          // 补充明细按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.operating ? null : () => _openDailyDetailSheet(provider, date),
              icon: const Icon(Icons.edit_note, size: 18),
              label: Text(dailyRecord != null
                  ? L10nManager.l10n.periodEditDailyRecord
                  : L10nManager.l10n.periodAddDailyRecord),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 结束经期按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.operating ? null : () => _confirmEndPeriod(provider, date),
              icon: provider.operating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.stop_circle_outlined, size: 18, color: cs.error),
              label: Text(L10nManager.l10n.periodEnd, style: TextStyle(color: cs.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.error.withAlpha(128)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 交互方法 ──

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

  /// 处理「开始经期」（从 Hero 卡片或空日期卡片触发）
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

  /// 处理「结束经期」（从 Hero 卡片触发）
  void _handleEndPeriod(PeriodRecordProvider provider) {
    if (!provider.isInPeriod) return;
    final today = DateTime.now();
    final todayStr = _dateStr(today);
    _confirmEndPeriod(provider, todayStr);
  }

  /// 确认标记经期开始
  void _confirmStartPeriod(PeriodRecordProvider provider, String date) async {
    if (provider.operating) return;

    // 如果有未结束周期，需要确认自动结束
    if (provider.isInPeriod) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(L10nManager.l10n.periodAutoEndConfirmTitle),
          content: Text(L10nManager.l10n.periodAutoEndConfirmContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(L10nManager.l10n.confirm),
            ),
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

  /// 确认结束经期（直接用点击日期）
  void _confirmEndPeriod(PeriodRecordProvider provider, String date) async {
    if (provider.operating || provider.activeCycle == null) return;

    // 校验：endDate ≥ 最后一条明细记录日期
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

  /// 打开补记抽屉
  void _openBackfillSheet(PeriodRecordProvider provider, String fromDate) async {
    if (provider.operating) return;

    // 查找前后相邻周期，用于范围约束
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

  /// 打开每日明细表单
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
        if (mounted) {
          setState(() => _selectedDate = null);
        }
      },
    );
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
