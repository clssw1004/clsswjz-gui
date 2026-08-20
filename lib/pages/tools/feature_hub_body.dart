import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/books_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_grid_feature_item.dart';
import '../../widgets/common/common_section_header.dart';
import 'feature_hub_registry.dart';

/// 「工作台」宫格主体（无 Scaffold/AppBar 的无壳组件）。
///
/// 按 [HubFeatureGroup] 分组渲染所有功能入口，新增功能只需在
/// [buildHubGroups] 注册表加一条即可。作为底部「工具」Tab 的主体使用，
/// 也可被其它需要展示功能宫格的页面复用。
class FeatureHubBody extends StatelessWidget {
  const FeatureHubBody({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final book = context.watch<BooksProvider>().selectedBook;
    final groups = buildHubGroups(context, book);

    return CustomScrollView(
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.contentPadding.copyWith(top: 16, bottom: 0),
              child: CommonSectionHeader(
                icon: group.groupIcon,
                title: group.title,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.contentPadding.copyWith(top: 12),
              child: _GroupCard(items: group.items),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

/// 单组功能的圆角卡片容器，内部为 4 列功能宫格。
class _GroupCard extends StatelessWidget {
  final List<HubFeatureItem> items;

  const _GroupCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        childAspectRatio: 0.88,
        padding: const EdgeInsets.all(12),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final item in items)
            CommonGridFeatureItem(
              icon: item.icon,
              label: item.label,
              onTap: item.onTap,
              isHighlighted: item.isHighlighted,
            ),
        ],
      ),
    );
  }
}
