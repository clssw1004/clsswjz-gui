import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/provider_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/category_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';

class AccountCategoriesPage extends StatefulWidget {
  const AccountCategoriesPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  State<AccountCategoriesPage> createState() => _AccountCategoriesPageState();
}

class _AccountCategoriesPageState extends State<AccountCategoriesPage> {
  CategoryProvider get _provider => ProviderManager.categoryProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTree(widget.accountBook.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(L10nManager.l10n.category)),
          body: Column(
            children: [
              // Type filter
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.formItemSpacing, 0,
                    spacing.formItemSpacing, spacing.listItemSpacing),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: AccountItemType.expense.code,
                      label: Text(L10nManager.l10n.expense),
                    ),
                    ButtonSegment<String>(
                      value: AccountItemType.income.code,
                      label: Text(L10nManager.l10n.income),
                    ),
                  ],
                  selected: {_provider.selectedType},
                  onSelectionChanged: (Set<String> newSelection) {
                    _provider.selectedType = newSelection.first;
                    _provider.loadTree(widget.accountBook.id);
                  },
                ),
              ),
              // Tree content
              Expanded(
                child: _provider.tree.isEmpty
                    ? const Center(child: Text('暂无分类'))
                    : _buildTreeView(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showAddDialog(null),
          ),
        );
      },
    );
  }

  Widget _buildTreeView() {
    final flattened = TreeBuilder.flatten(_provider.tree);
    return ListView.builder(
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final node = flattened[index];
        final hasChildren = node.children.isNotEmpty;
        return Padding(
          padding: EdgeInsets.only(left: node.level * 24.0),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: hasChildren
                  ? IconButton(
                      icon: Icon(
                        _provider.expandedIds.contains(node.data.id)
                            ? Icons.expand_more
                            : Icons.chevron_right,
                      ),
                      onPressed: () =>
                          _provider.toggleExpand(node.data.id),
                    )
                  : const SizedBox(width: 48),
              title: Text(node.data.name),
              subtitle: Text('#${node.data.code}'),
              onTap: () {
                final filter = ItemFilterDTO(
                  categoryCodes: _provider.expandCodes(node.data.code),
                  types: [_provider.selectedType],
                );
                Navigator.of(context).pushNamed(
                  AppRoutes.items,
                  arguments: [
                    widget.accountBook,
                    filter,
                    node.data.name,
                  ],
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => _showAddDialog(node.data.id),
                    tooltip: '添加子分类',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditDialog(node.data),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _confirmDelete(node.data),
                    tooltip: '删除',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(String? parentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? '添加分类' : '添加子分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final result = await _provider.create(
                name: controller.text.trim(),
                parentId: parentId,
              );
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AccountCategory category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final result = await _provider.update(
                category.id,
                name: controller.text.trim(),
              );
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AccountCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定删除「${category.name}」及其所有子分类？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final result = await _provider.delete(category.id);
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
