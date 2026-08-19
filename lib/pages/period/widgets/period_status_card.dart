import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../enums/period_status.dart';
import '../../../providers/period_record_provider.dart';
import '../../../manager/l10n_manager.dart';
import '../../../widgets/common/common_card_container.dart';

/// 首页经期状态组件（紧凑版）
///
/// 与主页其他卡片（BookStatisticCard / DailyStatisticBar 等）统一使用
/// CommonCardContainer，紧凑单行/双行布局，不再使用大号渐变背景与全宽按钮。
class PeriodStatusCard extends StatelessWidget {
  final VoidCallback? onViewAll;
  final VoidCallback? onStartPeriod;
  final VoidCallback? onEndPeriod;

  const PeriodStatusCard({
    super.key,
    this.onViewAll,
    this.onStartPeriod,
    this.onEndPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodRecordProvider>();
    final phase = provider.currentPhase;
    final cs = Theme.of(context).colorScheme;

    return CommonCardContainer(
      margin: EdgeInsets.zero,
      child: switch (phase) {
        PeriodPhase.period => _buildPeriod(context, provider, cs),
        PeriodPhase.predicted => _buildPredicted(context, provider, cs),
        PeriodPhase.ovulation => _buildOvulation(context, provider, cs),
        PeriodPhase.safe => _buildSafe(context, provider, cs),
        PeriodPhase.noData => _buildNoData(context, cs),
      },
    );
  }

  // ── 通用小部件 ──

  Widget _header(IconData icon, String tag, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(tag,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _trailingSeeAll(ColorScheme cs) {
    if (onViewAll == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onViewAll,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(L10nManager.l10n.viewAll,
            style: TextStyle(fontSize: 12, color: cs.primary)),
          Icon(Icons.chevron_right, size: 14, color: cs.primary),
        ],
      ),
    );
  }

  Widget _smallAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 30),
        visualDensity: VisualDensity.compact,
        backgroundColor: color?.withAlpha(24),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── 经期中：紧凑单行 + 细进度条 ──

  Widget _buildPeriod(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final day = provider.currentPeriodDay ?? 1;
    final avgPeriod = provider.statistics.canPredict
        ? provider.statistics.averagePeriodLength
        : 5;
    final progress = (day / avgPeriod).clamp(0.0, 1.0);
    final overAvg = day > avgPeriod;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _header(Icons.water_drop, l10n.periodOngoingTag, cs.error),
            const Spacer(),
            Text(
              l10n.periodDayCount(day),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.error,
              ),
            ),
            const SizedBox(width: 8),
            _smallAction(
              icon: Icons.stop_circle_outlined,
              label: l10n.periodEnd,
              color: cs.error,
              onTap: provider.operating ? null : onEndPeriod,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: cs.error.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(cs.error),
          ),
        ),
        if (overAvg) ...[
          const SizedBox(height: 4),
          Text(
            l10n.periodLongerThanAverage(day, avgPeriod),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: cs.error),
          ),
        ],
      ],
    );
  }

  // ── 预测经期窗口内 ──

  Widget _buildPredicted(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final next = provider.statistics.nextPeriodDate;
    final overdueDays = provider.periodOverdueDays;
    final showOverdue = overdueDays != null && next != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _header(Icons.event_available, l10n.periodUpcomingTag, cs.primary),
            const Spacer(),
            _trailingSeeAll(cs),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          showOverdue
              ? l10n.periodOverdueHint(next, overdueDays)
              : (next != null ? l10n.expectedDate(next) : l10n.needMoreCycles),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: showOverdue ? cs.error : cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: _smallAction(
            icon: Icons.play_circle_outline,
            label: l10n.periodMarkStart,
            color: cs.primary,
            onTap: provider.operating ? null : onStartPeriod,
          ),
        ),
      ],
    );
  }

  // ── 排卵期 ──

  Widget _buildOvulation(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final ov = provider.statistics.ovulationDate;
    final fs = provider.statistics.fertileWindowStart;
    final fe = provider.statistics.fertileWindowEnd;
    final daysUntil = provider.daysUntilNextPeriod;

    final subtitleParts = <String>[
      if (ov != null) l10n.ovulationDayLabel(ov),
      if (fs != null && fe != null) l10n.fertileWindowLabel(fs, fe),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _header(Icons.egg_alt, l10n.legendOvulation, cs.tertiary),
            const Spacer(),
            _trailingSeeAll(cs),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.highFertility,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        if (subtitleParts.isNotEmpty)
          Text(
            subtitleParts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        if (daysUntil != null)
          Text(
            l10n.daysUntilPeriod(daysUntil),
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
      ],
    );
  }

  // ── 安全期 ──

  Widget _buildSafe(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final next = provider.statistics.nextPeriodDate;
    final overdueDays = provider.periodOverdueDays;
    final safeColor = Colors.green.shade600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _header(Icons.eco_outlined, l10n.legendSafe, safeColor),
            const Spacer(),
            _trailingSeeAll(cs),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.lowFertility,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        if (next != null)
          Text(
            l10n.expectedDate(next),
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        // 预测经期已过未记录：显示延迟提示
        if (overdueDays != null && next != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.periodOverdueHint(next, overdueDays),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: cs.error),
          ),
        ],
      ],
    );
  }

  // ── 无数据 ──

  Widget _buildNoData(BuildContext context, ColorScheme cs) {
    final l10n = L10nManager.l10n;

    return Row(
      children: [
        Icon(
          Icons.water_drop_outlined,
          size: 22,
          color: cs.onSurfaceVariant.withAlpha(120),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.noPeriodData,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              Text(
                l10n.recordFirstPeriod,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        _smallAction(
          icon: Icons.play_circle_outline,
          label: l10n.periodMarkStart,
          color: cs.primary,
          onTap: onStartPeriod,
        ),
      ],
    );
  }
}
