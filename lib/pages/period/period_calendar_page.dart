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
      try {
        await context.read<PeriodRecordProvider>().loadRecords();
      } catch (_) {
        // 数据加载失败不影响引导判断
      }
      if (mounted) _checkOnboarding();
    });
  }

  void _checkOnboarding() {
    final provider = context.read<PeriodRecordProvider>();
    // 只要用户从未录入过任何经期数据就引导（不依赖持久化标志，
    // 避免用户曾点过"跳过"后引导被永久关闭）
    if (provider.cycles.isEmpty && provider.statistics.totalRecords == 0) {
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

      // 结束日未知时不伪造 endDate（创建为进行中周期，由用户后续手动结束），
      // 避免虚假的经期长度数据进入统计
      final end = result.lastPeriodEnd != null
          ? DateTime.parse(result.lastPeriodEnd!)
          : null;

      await provider.backfillPeriod(
        _dateStr(start),
        end != null ? _dateStr(end) : null,
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

          return Column(
            children: [
              // 滚动内容区
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Hero 状态卡片（顶部，紧凑）
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                        child: PeriodHeroCard(
                          onStartPeriod: () => _handleStartPeriod(provider),
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
                          cycles: provider.cycles,
                          recentCycles: provider.recentCycles,
                          statistics: provider.statistics,
                          selectedDate: _selectedDate,
                          onDateTap: _onDateTap,
                          onPreviousMonth: _previousMonth,
                          onNextMonth: _nextMonth,
                        ),
                      ),
                    ),
                    // 统计 Tile（位于日历下方）
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                        child: PeriodPredictionCard(statistics: provider.statistics),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: spacing.formGroupSpacing)),
                  ],
                ),
              ),
              // 底部操作面板（点击日期后出现，替代底部抽屉）
              _buildBottomActionPanel(provider),
            ],
          );
        },
      ),
    );
  }

  // ── 交互方法 ──

  void _onDateTap(String date) async {
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

    // 日期属于某个周期（活跃或已结束）时，先加载该周期的每日明细，
    // 保证底部面板能展示该日期的明细（已记录的日期只显示明细操作，不再出现补记）
    final cycleInDate = provider.findCycleForDate(date);
    if (cycleInDate != null) {
      await provider.loadDailyRecordsForCycle(cycleInDate.id);
      if (!mounted) return;
    }

    // 选中日期 → 底部操作面板出现
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

  // ── 底部操作面板 ──

  /// 页面底部操作面板（点击日期后内嵌显示，替代原底部抽屉）
  ///
  /// 根据日期状态渲染不同操作：
  /// - 属于某周期（活跃或已结束）：查看/编辑每日详情；活跃周期内可结束经期；
  ///   已记录明细可删除单日；任何周期可删除整个周期
  /// - 不属于任何周期：今天 → 标记开始；历史日期 → 补记
  Widget _buildBottomActionPanel(PeriodRecordProvider provider) {
    final date = _selectedDate;
    if (date == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final l10n = L10nManager.l10n;
    final today = DateTime.now();
    final todayStr = _dateStr(DateTime(today.year, today.month, today.day));

    final cycle = provider.findCycleForDate(date);
    final dailyRecord = provider.getDailyRecordByDate(date);
    final activeCycle = provider.activeCycle;
    final isInActiveCycle = activeCycle != null &&
        date.compareTo(activeCycle.startDate) >= 0 &&
        (activeCycle.endDate == null || date.compareTo(activeCycle.endDate!) <= 0);

    return Material(
      color: cs.surface,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withAlpha(100)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(16),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：日期 + 已记录标记 + 关闭
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(date,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  if (dailyRecord != null) ...[
                    const SizedBox(width: 8),
                    Text(l10n.periodDailyRecordExists,
                      style: TextStyle(fontSize: 12, color: cs.primary)),
                  ],
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _selectedDate = null),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (cycle != null) ...[
                // 查看/编辑每日详情
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: provider.operating
                        ? null
                        : () => _openDailyDetailSheet(provider, date, cycle.id),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: Text(dailyRecord != null
                        ? l10n.periodEditDailyRecord
                        : l10n.periodAddDailyRecord),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                // 结束经期（仅当前进行中的周期内显示）
                if (isInActiveCycle) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: provider.operating
                          ? null
                          : () => _confirmEndPeriod(provider, date),
                      icon: provider.operating
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.stop_circle_outlined, size: 18),
                      label: Text(l10n.periodEnd,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: cs.error.withAlpha(100),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // 删除操作（单日明细 + 整个周期）
                Row(
                  children: [
                    if (dailyRecord != null) ...[
                      Expanded(
                        child: _buildDeleteButton(
                          icon: Icons.delete_outline,
                          label: l10n.deleteDayOnly,
                          onTap: () => _confirmDeleteDailyRecord(provider, cycle.id, date),
                          cs: cs,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: _buildDeleteButton(
                        icon: Icons.delete_forever_outlined,
                        label: l10n.deleteCycle,
                        subtitle:
                            '${cycle.startDate} ~ ${cycle.endDate ?? l10n.periodOngoing}',
                        onTap: () => _confirmDeleteCycle(provider, cycle.id),
                        cs: cs,
                      ),
                    ),
                  ],
                ),
              ] else if (date == todayStr) ...[
                // 今天且不在任何周期内 → 标记经期开始
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.operating
                        ? null
                        : () => _confirmStartPeriod(provider, date),
                    icon: provider.operating
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_circle_outline, size: 18),
                    label: Text(l10n.periodMarkStart,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ] else ...[
                // 历史空白日 → 补记
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: provider.operating
                        ? null
                        : () => _openBackfillSheet(provider, date),
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: Text(l10n.periodBackfill),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: cs.error),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: TextStyle(color: cs.error, fontSize: 13, fontWeight: FontWeight.w500)),
          if (subtitle != null)
            Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(color: cs.error.withAlpha(80)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 确认删除单日明细
  void _confirmDeleteDailyRecord(
      PeriodRecordProvider provider, String cycleId, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.deleteRecord),
        content: Text(L10nManager.l10n.confirmDeleteDayRecord),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10nManager.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteDailyRecord(cycleId, date);
              if (context.mounted) setState(() => _selectedDate = null);
            },
            child: Text(L10nManager.l10n.deleteBtn,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  /// 确认删除整个周期
  void _confirmDeleteCycle(PeriodRecordProvider provider, String cycleId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.deleteCycle),
        content: Text(L10nManager.l10n.deleteCycleConfirm(0)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(L10nManager.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteCycle(cycleId);
              if (context.mounted) setState(() => _selectedDate = null);
            },
            child: Text(L10nManager.l10n.deleteBtn,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  // ── 操作方法 ──

  void _handleStartPeriod(PeriodRecordProvider provider) {
    if (provider.cycles.isEmpty && provider.statistics.totalRecords == 0) {
      _showOnboarding();
    } else {
      final today = DateTime.now();
      final todayStr = _dateStr(today);
      _confirmStartPeriod(provider, todayStr);
    }
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

    // 二次确认，防止误点
    final startDate = provider.activeCycle!.startDate;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.confirmPeriodEnd),
        content: Text('$startDate → $date\n\n${L10nManager.l10n.periodEndConfirmContent}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(L10nManager.l10n.confirm,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

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

    if (mounted) {
      setState(() => _selectedDate = null);
      // 切换到补记开始月份，立即看到结果
      await provider.changeMonth(range.start.year, range.start.month);
    }
  }

  void _openDailyDetailSheet(
      PeriodRecordProvider provider, String date, String cycleId) async {
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
          cycleId: cycleId,
        );
      },
    );
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
