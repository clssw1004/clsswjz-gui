import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../enums/period_status.dart';
import '../../../providers/period_record_provider.dart';
import '../../../manager/l10n_manager.dart';

/// 首页经期状态组件
///
/// 显示当前周期阶段和操作按钮，嵌入首页列表
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: switch (phase) {
        PeriodPhase.period => _buildPeriod(context, provider, cs),
        PeriodPhase.ovulation => _buildOvulation(context, provider, cs),
        PeriodPhase.safe => _buildSafe(context, provider, cs),
        PeriodPhase.noData => _buildNoData(context, cs),
      },
    );
  }

  // ── 经期中 ──
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.error.withAlpha(26), cs.error.withAlpha(8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行：标签 + 查看全部
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.periodOngoingTag,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        L10nManager.l10n.viewAll,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: cs.primary),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 数字 + 文字
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: cs.error,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.periodDayCount(day),
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: cs.error.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(cs.error),
            ),
          ),
          const SizedBox(height: 12),
          // 按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.operating ? null : onEndPeriod,
              icon: provider.operating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.stop_circle_outlined, size: 16, color: cs.error),
              label: Text(l10n.periodEnd, style: TextStyle(color: cs.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.error.withAlpha(100)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 排卵期 ──
  Widget _buildOvulation(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final daysUntil = provider.daysUntilNextPeriod;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.tertiary.withAlpha(26), cs.tertiary.withAlpha(8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.tertiary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🥚 ${l10n.legendOvulation}',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        L10nManager.l10n.viewAll,
                        style: TextStyle(fontSize: 12, color: cs.primary),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: cs.primary),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.highFertility,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (provider.statistics.ovulationDate != null)
            Text(
              l10n.ovulationDayLabel(provider.statistics.ovulationDate!),
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          if (provider.statistics.fertileWindowStart != null &&
              provider.statistics.fertileWindowEnd != null) ...[
            const SizedBox(height: 2),
            Text(
              l10n.fertileWindowLabel(
                provider.statistics.fertileWindowStart!,
                provider.statistics.fertileWindowEnd!,
              ),
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
          if (daysUntil != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.daysUntilPeriod(daysUntil),
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  // ── 安全期 ──
  Widget _buildSafe(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
  ) {
    final l10n = L10nManager.l10n;
    final daysUntil = provider.daysUntilNextPeriod;
    final safeColor = Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [safeColor.withAlpha(20), safeColor.withAlpha(6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: safeColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '✿ ${l10n.legendSafe}',
                  style: TextStyle(
                    fontSize: 11,
                    color: safeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        L10nManager.l10n.viewAll,
                        style: TextStyle(fontSize: 12, color: cs.primary),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: cs.primary),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.lowFertility,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (daysUntil != null)
            Text(
              l10n.daysUntilPeriod(daysUntil),
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          if (provider.statistics.nextPeriodDate != null) ...[
            const SizedBox(height: 2),
            Text(
              l10n.expectedDate(provider.statistics.nextPeriodDate!),
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  // ── 无数据 ──
  Widget _buildNoData(BuildContext context, ColorScheme cs) {
    final l10n = L10nManager.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 28,
            color: cs.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noPeriodData,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recordFirstPeriod,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onStartPeriod,
              icon: const Icon(Icons.play_circle_outline, size: 16),
              label: Text(l10n.periodMarkStart),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
