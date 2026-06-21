import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/statistic_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/statistics_provider.dart';
import '../../routes/app_routes.dart';
import '../common/common_card_container.dart';

/// 当月按项目统计（列表形式）
class ProjectMonthlyStatisticChart extends StatelessWidget {
  final List<ProjectMonthlyStatisticVO> data;
  final bool loading;
  final UserBookVO? accountBook;

  /// 项目颜色列表
  static const List<Color> projectColors = [
    Color(0xFF43A047), // 绿色
    Color(0xFFE53935), // 红色
    Color(0xFF1E88E5), // 蓝色
    Color(0xFFFF9800), // 橙色
    Color(0xFF8E24AA), // 紫色
    Color(0xFF00ACC1), // 青色
    Color(0xFFFFB300), // 琥珀色
    Color(0xFF5E35B1), // 深紫色
    Color(0xFF00897B), // 蓝绿色
    Color(0xFFD81B60), // 粉红色
  ];

  const ProjectMonthlyStatisticChart({
    super.key,
    required this.data,
    this.loading = false,
    this.accountBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (data.isEmpty) {
      return CommonCardContainer(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stacked_bar_chart_outlined,
                  size: 32,
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                ),
                const SizedBox(height: 8),
                Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodySmall?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '按项目统计',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // 列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colorScheme.outline.withAlpha(30),
            ),
            itemBuilder: (context, index) {
              final item = data[index];
              final color = projectColors[index % projectColors.length];
              final total = item.income + item.expense.abs();

              return InkWell(
                onTap: () {
                  // 使用传入的账本跳转
                  final book = accountBook;
                  if (book != null) {
                    final filter = ItemFilterDTO(projectCodes: [item.projectId]);
                    // 带时间范围
                    final statsProvider =
                        Provider.of<StatisticsProvider>(context, listen: false);
                    final start = statsProvider.currentStart;
                    final end = statsProvider.currentEnd;
                    if (start != null || end != null) {
                      final s = start?.toIso8601String().substring(0, 10);
                      final e = end?.toIso8601String().substring(0, 10);
                      final withDate = filter.copyWith(startDate: s, endDate: e);
                      Navigator.of(context).pushNamed(
                        AppRoutes.items,
                        arguments: [book, withDate, item.projectName],
                      );
                      return;
                    }
                    Navigator.of(context).pushNamed(
                      AppRoutes.items,
                      arguments: [book, filter, item.projectName],
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // 颜色指示条
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 项目名称
                      Expanded(
                        child: Text(
                          item.projectName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 笔数
                      Text(
                        '${item.count}笔',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 金额
                      Text(
                        total.toStringAsFixed(0),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: colorScheme.onSurfaceVariant.withAlpha(100),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}