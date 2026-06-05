import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vo/item_relation_vo.dart';
import '../../providers/item_relation_provider.dart';
import '../../theme/theme_spacing.dart';

/// 搜索结果项
class SearchResult {
  final String id;
  final String display;
  final Widget? leading;

  const SearchResult({
    required this.id,
    required this.display,
    this.leading,
  });
}

/// 关联目标配置
class RelationTargetConfig {
  final String code;
  final String label;
  final Future<List<SearchResult>> Function(
    BuildContext context,
    String query,
  )? searchBuilder;
  final Widget Function(
    BuildContext context,
    ItemRelationVO relation,
    VoidCallback onTap,
  ) displayBuilder;
  final void Function(BuildContext context, ItemRelationVO relation) onTap;

  const RelationTargetConfig({
    required this.code,
    required this.label,
    this.searchBuilder,
    required this.displayBuilder,
    required this.onTap,
  });
}

/// 通用关联面板
class ItemRelationPanel extends StatefulWidget {
  final String relationCode;
  final String relationId;
  final String accountBookId;
  final RelationTargetConfig target;

  const ItemRelationPanel({
    super.key,
    required this.relationCode,
    required this.relationId,
    required this.accountBookId,
    required this.target,
  });

  @override
  State<ItemRelationPanel> createState() => _ItemRelationPanelState();
}

class _ItemRelationPanelState extends State<ItemRelationPanel> {
  List<ItemRelationVO> _relations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRelations();
  }

  Future<void> _loadRelations() async {
    final provider = context.read<ItemRelationProvider>();
    final relations = await provider.getSourceRelations(
      widget.relationCode,
      widget.relationId,
    );
    if (mounted) {
      setState(() {
        _relations = relations;
        _loading = false;
      });
    }
  }

  Future<void> _handleAddRelation() async {
    final provider = context.read<ItemRelationProvider>();

    if (widget.target.searchBuilder == null) return;

    final result = await showSearch<String?>(
      context: context,
      delegate: _ItemSearchDelegate(
        searchBuilder: widget.target.searchBuilder!,
        label: widget.target.label,
      ),
    );

    if (result != null && mounted) {
      await provider.createRelation(
        itemId: result,
        accountBookId: widget.accountBookId,
        relationCode: widget.relationCode,
        relationId: widget.relationId,
      );
      if (mounted) {
        _loadRelations();
      }
    }
  }

  Future<void> _handleDeleteRelation(ItemRelationVO relation) async {
    final provider = context.read<ItemRelationProvider>();
    await provider.deleteRelation(
      relationId: relation.id,
      itemId: relation.itemId,
      relationCode: widget.relationCode,
      sourceId: widget.relationId,
    );
    if (mounted) {
      _loadRelations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.contentPadding.left,
            vertical: spacing.formItemSpacing,
          ),
          child: Row(
            children: [
              Text(
                '关联${widget.target.label}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _handleAddRelation,
                icon: const Icon(Icons.add, size: 18),
                label: Text('关联${widget.target.label}'),
              ),
            ],
          ),
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_relations.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.contentPadding.left,
            ),
            child: Text(
              '暂无关联${widget.target.label}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(_relations.length, (index) {
            final relation = _relations[index];
            return Dismissible(
              key: ValueKey(relation.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Theme.of(context).colorScheme.error,
                child: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onError),
              ),
              onDismissed: (_) => _handleDeleteRelation(relation),
              child: widget.target.displayBuilder(
                context,
                relation,
                () => widget.target.onTap(context, relation),
              ),
            );
          }),
      ],
    );
  }
}

/// 搜索委托
class _ItemSearchDelegate extends SearchDelegate<String?> {
  final Future<List<SearchResult>> Function(BuildContext, String) searchBuilder;
  final String label;

  _ItemSearchDelegate({
    required this.searchBuilder,
    required this.label,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Widget _buildSearchList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text('输入关键字搜索$label'),
      );
    }

    return FutureBuilder<List<SearchResult>>(
      future: searchBuilder(context, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('未找到匹配结果'));
        }
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return ListTile(
              leading: item.leading,
              title: Text(item.display),
              onTap: () => close(context, item.id),
            );
          },
        );
      },
    );
  }
}
