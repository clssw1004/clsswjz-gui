import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../models/vo/statistic_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/color_util.dart';

/// 每日收支统计图表组件
class DailyStatisticChart extends StatelessWidget {
  /// 每日统计数据
  final List<DailyStatisticVO> dailyStats;

  /// 加载状态
  final bool loading;

  /// 高度
  final double height;

  /// 是否使用对数Y轴（当数据范围差异很大时建议启用）
  final bool useLogarithmicYAxis;
  
  /// 是否显示收入（true显示收入，false显示支出）
  final bool showIncome;

  const DailyStatisticChart({
    super.key,
    required this.dailyStats,
    this.loading = false,
    this.height = 200,
    this.useLogarithmicYAxis = false,
    this.showIncome = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return SizedBox(
        height: height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dailyStats.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
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
              const SizedBox(height: 8),
              Text(
                '本月暂无收支记录',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(150),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: _buildSfBarChart(context, colorScheme),
    );
  }

  /// 构建 Syncfusion 柱状图
  Widget _buildSfBarChart(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    // 准备图表数据，根据切换状态只显示收入或支出
    final List<DailyChartData> chartData = dailyStats.map((stat) {
      final dateParts = stat.date.split('-');
      final day = dateParts.length >= 3 ? dateParts[2] : stat.date;
      return DailyChartData(
        date: day,
        income: stat.income,
        expense: stat.expense.abs(), // 支出取绝对值用于显示
      );
    }).toList();

    // 计算Y轴范围（根据当前显示的数据类型）
    final yAxisRange = _calculateYAxisRange();

    return SfCartesianChart(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        labelRotation: 0,
        // 根据数据量动态调整标签间隔，避免重叠
        interval: _calculateXAxisInterval(),
        // 设置X轴标签的间距和样式
        labelIntersectAction: AxisLabelIntersectAction.hide,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: AxisLine(
          color: colorScheme.outline.withAlpha(50),
          width: 1,
        ),
      ),
      primaryYAxis: NumericAxis(
        // 设置Y轴范围，避免过大的空白区间
        minimum: yAxisRange.min,
        maximum: yAxisRange.max,
        majorGridLines: MajorGridLines(
          color: colorScheme.outline.withAlpha(20),
          width: 0.5,
          dashArray: const [3, 3],
        ),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
        // 动态计算Y轴间隔
        interval: _calculateYAxisInterval(yAxisRange),
        numberFormat: NumberFormat.compact(),
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: AxisLine(
          color: colorScheme.outline.withAlpha(50),
          width: 1,
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y',
        color: colorScheme.surface,
        textStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        borderColor: colorScheme.outline.withAlpha(100),
        borderWidth: 1,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(30),
      ),
      legend: Legend(
        isVisible: false, // 隐藏图例，因为我们在DailyStatisticCard中单独显示
      ),
      plotAreaBorderWidth: 0,
      series: <CartesianSeries>[
        // 根据切换状态显示收入或支出
        if (showIncome)
          // 收入柱状图系列
          ColumnSeries<DailyChartData, String>(
            dataSource: chartData,
            xValueMapper: (DailyChartData data, _) => data.date,
            yValueMapper: (DailyChartData data, _) => data.income,
            name: '收入',
            color: ColorUtil.INCOME.withAlpha(220),
            width: 0.6, // 单列显示时可以稍微宽一些
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: false, // 隐藏数据标签，避免图表过于拥挤
            ),
            animationDuration: 600,
            animationDelay: 100,
            // 添加渐变效果
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorUtil.INCOME.withAlpha(180),
                ColorUtil.INCOME.withAlpha(220),
              ],
            ),
          )
        else
          // 支出柱状图系列
          ColumnSeries<DailyChartData, String>(
            dataSource: chartData,
            xValueMapper: (DailyChartData data, _) => data.date,
            yValueMapper: (DailyChartData data, _) => data.expense,
            name: '支出',
            color: ColorUtil.EXPENSE.withAlpha(220),
            width: 0.6, // 单列显示时可以稍微宽一些
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: false, // 隐藏数据标签，避免图表过于拥挤
            ),
            animationDuration: 600,
            animationDelay: 100,
            // 添加渐变效果
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
    );
  }

  /// 计算Y轴间隔
  double _calculateYAxisInterval(YAxisRange range) {
    final min = range.min;
    final max = range.max;
    final rangeSize = max - min;

    // 根据范围大小计算合适的间隔
    if (rangeSize <= 100) {
      // 小范围：使用较小的间隔
      if (rangeSize <= 20) return 5;
      if (rangeSize <= 50) return 10;
      return 20;
    } else if (rangeSize <= 1000) {
      // 中等范围：使用中等间隔
      if (rangeSize <= 200) return 50;
      if (rangeSize <= 500) return 100;
      return 200;
    } else if (rangeSize <= 10000) {
      // 大范围：使用较大间隔
      if (rangeSize <= 2000) return 500;
      if (rangeSize <= 5000) return 1000;
      return 2000;
    } else {
      // 超大范围：使用更大间隔
      if (rangeSize <= 20000) return 5000;
      if (rangeSize <= 50000) return 10000;
      return 20000;
    }
  }

  /// 计算X轴标签间隔
  double _calculateXAxisInterval() {
    if (dailyStats.isEmpty) {
      return 1.0; // 空数据时返回默认值
    }

    if (dailyStats.length <= 10) {
      return 1.0; // 数据点较少时，显示所有标签
    } else if (dailyStats.length <= 20) {
      return 2.0; // 数据点较多时，每2个显示一个标签
    } else if (dailyStats.length <= 30) {
      return 3.0; // 数据点更多时，每3个显示一个标签
    } else {
      return 5.0; // 数据点非常多时，每5个显示一个标签
    }
  }

  /// 计算Y轴范围
  YAxisRange _calculateYAxisRange() {
    if (dailyStats.isEmpty) {
      return YAxisRange(min: 0, max: 100);
    }

    double minAmount = double.infinity;
    double maxAmount = -double.infinity;

    for (final stat in dailyStats) {
      // 根据当前显示的数据类型来计算
      final value = showIncome ? stat.income : stat.expense.abs();
      if (value < minAmount) {
        minAmount = value;
      }
      if (value > maxAmount) {
        maxAmount = value;
      }
    }

    // 确保最小值为0，如果最小值小于0，则最小值为0
    if (minAmount < 0) {
      minAmount = 0;
    }

    // 记录原始值用于调试
    final originalMin = minAmount;
    final originalMax = maxAmount;

    // 如果最大值和最小值差异很大，调整最小值以保持小数值可见
    if (maxAmount > 0 && minAmount > 0) {
      final ratio = maxAmount / minAmount;
      if (ratio > 1000) {
        // 当最大值是最小值的1000倍以上时，调整最小值
        minAmount = maxAmount / 1000;
      } else if (ratio > 500) {
        // 当最大值是最小值的500倍以上时，调整最小值
        minAmount = maxAmount / 500;
      } else if (ratio > 200) {
        // 当最大值是最小值的200倍以上时，调整最小值
        minAmount = maxAmount / 200;
      } else if (ratio > 100) {
        // 当最大值是最小值的100倍以上时，调整最小值
        minAmount = maxAmount / 100;
      } else if (ratio > 50) {
        // 当最大值是最小值的50倍以上时，调整最小值
        minAmount = maxAmount / 50;
      }
    }

    // 确保最大值是合适的倍数，并且至少是100
    if (maxAmount < 100) {
      maxAmount = 100;
    } else {
      // 根据最大值的大小，选择合适的倍数
      if (maxAmount <= 1000) {
        maxAmount = (maxAmount / 10).ceil() * 10;
      } else if (maxAmount <= 10000) {
        maxAmount = (maxAmount / 100).ceil() * 100;
      } else {
        maxAmount = (maxAmount / 1000).ceil() * 1000;
      }
    }

    // 确保最小值也是合适的倍数
    if (minAmount > 0 && minAmount < 10) {
      minAmount = (minAmount * 10).floor() / 10;
    } else if (minAmount >= 10) {
      minAmount = (minAmount / 10).floor() * 10;
    }

    // 最终检查：确保最小值不会太小，影响视觉效果
    if (minAmount > 0 && (maxAmount / minAmount) > 100) {
      minAmount = maxAmount / 100;
    }

    // 调试信息：打印Y轴范围调整前后的对比
    if (originalMin != minAmount || originalMax != maxAmount) {
      print('Y轴范围优化: 原始(${originalMin.toStringAsFixed(2)}, ${originalMax.toStringAsFixed(2)}) -> 调整后(${minAmount.toStringAsFixed(2)}, ${maxAmount.toStringAsFixed(2)})');
    }

    return YAxisRange(min: minAmount, max: maxAmount);
  }
}

/// 每日图表数据模型
class DailyChartData {
  DailyChartData({
    required this.date,
    required this.income,
    required this.expense,
  });

  final String date;
  final double income;
  final double expense;
}

/// Y轴范围模型
class YAxisRange {
  final double min;
  final double max;

  YAxisRange({required this.min, required this.max});
}
