import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../enums/period_status.dart';
import '../../../providers/period_record_provider.dart';
import '../../../theme/theme_spacing.dart';
import '../../../manager/l10n_manager.dart';

/// 日历页顶部的 Hero 状态卡片
///
/// 根据当前周期阶段显示不同视觉：
/// - 经期中：粉色渐变 + 进度条 + 结束按钮
/// - 排卵期：暖色渐变 + 信息
/// - 安全期：绿色渐变 + 倒计时
/// - 无数据：引导卡片
class PeriodHeroCard extends StatelessWidget {
  final VoidCallback? onStartPeriod;
  final VoidCallback? onEndPeriod;

  const PeriodHeroCard({
    super.key,
    this.onStartPeriod,
    this.onEndPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodRecordProvider>();
    final phase = provider.currentPhase;
    final cs = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).spacing;
    final l10n = L10nManager.l10n;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: switch (phase) {
        PeriodPhase.period => _buildPeriodPhase(
            context, provider, cs, spacing, l10n),
        PeriodPhase.ovulation => _buildOvulationPhase(
            context, provider, cs, spacing, l10n),
        PeriodPhase.safe => _buildSafePhase(
            context, provider, cs, spacing, l10n),
        PeriodPhase.noData => provider.statistics.totalRecords > 0
            ? _buildNeedMoreDataPhase(context, provider, cs, spacing, l10n)
            : _buildNoDataPhase(context, cs, spacing, l10n),
      },
    );
  }

  // ── 经期中（紧凑版）──
  Widget _buildPeriodPhase(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
    ThemeSpacing spacing,
    dynamic l10n,
  ) {
    final day = provider.currentPeriodDay ?? 1;
    final avgPeriod = provider.statistics.canPredict
        ? provider.statistics.averagePeriodLength
        : 5;
    final progress = (day / avgPeriod).clamp(0.0, 1.0);
    final startDate = provider.periodStartDate ?? '';

    return Container(
      key: const ValueKey('period'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.error.withAlpha(30),
            cs.error.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withAlpha(40), width: 1),
      ),
      child: Column(
        children: [
          // 顶部行：标签 + 结束按钮
          Row(
            children: [
              // 标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.periodOngoingTag,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // 大数字（第几天）
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
              Text(
                l10n.periodDayCount(day),
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 开始日期
          if (startDate.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.periodStarted(startDate),
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.periodDayCountOf(day, avgPeriod),
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 结束按钮
          SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: provider.operating ? null : onEndPeriod,
              icon: provider.operating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.stop_circle_outlined, size: 16, color: cs.error),
              label: Text(
                l10n.periodEnd,
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.error.withAlpha(128)),
                padding: const EdgeInsets.symmetric(vertical: 8),
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
  Widget _buildOvulationPhase(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
    ThemeSpacing spacing,
    dynamic l10n,
  ) {
    final daysUntil = provider.daysUntilNextPeriod;

    return Container(
      key: const ValueKey('ovulation'),
      width: double.infinity,
      padding: spacing.contentPadding.copyWith(top: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.tertiary.withAlpha(30),
            cs.tertiary.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.tertiary.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.tertiary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🥚 ${l10n.legendOvulation}',
              style: TextStyle(
                fontSize: 12,
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.highFertility,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (provider.statistics.ovulationDate != null)
            _buildInfoRow(
              Icons.circle,
              l10n.ovulationDayLabel(provider.statistics.ovulationDate!),
              cs,
            ),
          if (provider.statistics.fertileWindowStart != null &&
              provider.statistics.fertileWindowEnd != null)
            _buildInfoRow(
              Icons.circle,
              l10n.fertileWindowLabel(
                provider.statistics.fertileWindowStart!,
                provider.statistics.fertileWindowEnd!,
              ),
              cs,
            ),
          if (daysUntil != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.daysUntilPeriod(daysUntil),
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  // ── 安全期 ──
  Widget _buildSafePhase(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
    ThemeSpacing spacing,
    dynamic l10n,
  ) {
    final daysUntil = provider.daysUntilNextPeriod;
    final safeColor = Colors.green;

    return Container(
      key: const ValueKey('safe'),
      width: double.infinity,
      padding: spacing.contentPadding.copyWith(top: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            safeColor.withAlpha(22),
            safeColor.withAlpha(6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: safeColor.withAlpha(36), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: safeColor.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '✿ ${l10n.legendSafe}',
              style: TextStyle(
                fontSize: 12,
                color: safeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.lowFertility,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (daysUntil != null)
            Text(
              l10n.daysUntilPeriod(daysUntil),
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          if (provider.statistics.ovulationDate != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              Icons.circle,
              l10n.ovulationDayLabel(provider.statistics.ovulationDate!),
              cs,
            ),
          ],
          if (provider.statistics.nextPeriodDate != null) ...[
            _buildInfoRow(
              Icons.circle,
              l10n.expectedDate(provider.statistics.nextPeriodDate!),
              cs,
            ),
          ],
        ],
      ),
    );
  }

  // ── 无数据 ──
  Widget _buildNoDataPhase(
    BuildContext context,
    ColorScheme cs,
    ThemeSpacing spacing,
    dynamic l10n,
  ) {
    return Container(
      key: const ValueKey('noData'),
      width: double.infinity,
      padding: spacing.contentPadding.copyWith(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 36,
            color: cs.onSurfaceVariant.withAlpha(120),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noPeriodData,
            style: TextStyle(
              fontSize: 15,
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recordFirstPeriod,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartPeriod,
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text(l10n.periodMarkStart),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 有记录但数据不足 ──
  Widget _buildNeedMoreDataPhase(
    BuildContext context,
    PeriodRecordProvider provider,
    ColorScheme cs,
    ThemeSpacing spacing,
    dynamic l10n,
  ) {
    final totalRecords = provider.statistics.totalRecords;
    final cycleCount = provider.statistics.recentCycleLengths.length + 1;

    return Container(
      key: const ValueKey('needMoreData'),
      width: double.infinity,
      padding: spacing.contentPadding.copyWith(top: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withAlpha(15),
            cs.primary.withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withAlpha(30),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 32,
            color: cs.primary.withAlpha(150),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.needMoreCycles,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$totalRecords ${l10n.days} · $cycleCount ${l10n.periodStatusNone}期',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 6, color: cs.onSurfaceVariant.withAlpha(120)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
