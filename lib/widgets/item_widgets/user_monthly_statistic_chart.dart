import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/vo/statistic_vo.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_card_container.dart';
import '../../utils/color_util.dart';

/// 当月按用户统计（双Y轴柱状图）：笔数（左轴）、金额（右轴）
class UserMonthlyStatisticChart extends StatelessWidget {
  final List<UserMonthlyStatisticVO> data;
  final bool loading;

  const UserMonthlyStatisticChart({
    super.key,
    required this.data,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (data.isEmpty) {
      return CommonCardContainer(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stacked_bar_chart_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CommonCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  L10nManager.l10n.members,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // 图表
          SizedBox(
            height: 260,
            child: SfCartesianChart(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                axisLine: AxisLine(color: colorScheme.outline.withAlpha(50), width: 1),
              ),
              // 主Y轴放左侧，隐藏文字（不占横向空间），保留网格线
              primaryYAxis: NumericAxis(
                isVisible: true,
                opposedPosition: false,
                // 展示数值与网格，样式与每日统计一致
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                majorGridLines: MajorGridLines(
                  color: colorScheme.outline.withAlpha(20),
                  width: 0.5,
                  dashArray: const [3, 3],
                ),
                axisLine: AxisLine(color: colorScheme.outline.withAlpha(50), width: 1),
                majorTickLines: const MajorTickLines(size: 0),
                minorTickLines: const MinorTickLines(size: 0),
              ),
              axes: <ChartAxis>[
                // 关闭右侧轴
                NumericAxis(name: 'amountAxis', opposedPosition: true, isVisible: false),
              ],
              legend: const Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (dynamic d, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                  final row = d as ChartUserRow;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outline.withAlpha(80), width: 1),
                    ),
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.user, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('${L10nManager.l10n.accountItem}: ${row.count}'),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: ColorUtil.INCOME, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                                  children: [
                                    TextSpan(text: '${L10nManager.l10n.income}: '),
                                    TextSpan(text: row.income.toStringAsFixed(0), style: TextStyle(color: ColorUtil.INCOME, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: ColorUtil.EXPENSE, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                                  children: [
                                    TextSpan(text: '${L10nManager.l10n.expense}: '),
                                    TextSpan(text: row.expense.toStringAsFixed(0), style: TextStyle(color: ColorUtil.EXPENSE, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              plotAreaBorderWidth: 0,
              series: <CartesianSeries<dynamic, dynamic>>[
                // 收入
                ColumnSeries<ChartUserRow, String>(
                  name: L10nManager.l10n.income,
                  dataSource: data
                      .map((e) => ChartUserRow(user: e.userName, count: e.count, income: e.income, expense: e.expense.abs()))
                      .toList(),
                  xValueMapper: (r, _) => r.user,
                  yValueMapper: (r, _) => r.income,
                  color: ColorUtil.INCOME,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  width: 0.4,
                  spacing: 0.2,
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorUtil.INCOME.withAlpha(180),
                      ColorUtil.INCOME.withAlpha(220),
                    ],
                  ),
                ),
                // 支出
                ColumnSeries<ChartUserRow, String>(
                  name: L10nManager.l10n.expense,
                  dataSource: data
                      .map((e) => ChartUserRow(user: e.userName, count: e.count, income: e.income, expense: e.expense.abs()))
                      .toList(),
                  xValueMapper: (r, _) => r.user,
                  yValueMapper: (r, _) => r.expense,
                  color: ColorUtil.EXPENSE,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  width: 0.4,
                  spacing: 0.2,
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorUtil.EXPENSE.withAlpha(180),
                      ColorUtil.EXPENSE.withAlpha(220),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartUserRow {
  final String user;
  final int count;
  final double income;
  final double expense;
  ChartUserRow({required this.user, required this.count, required this.income, required this.expense});
}


