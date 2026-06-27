import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/provider_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/shop_provider.dart';
import '../../theme/theme_radius.dart';
import '../../routes/app_routes.dart';

class MerchantsPage extends StatefulWidget {
  const MerchantsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  State<MerchantsPage> createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  ShopProvider get _provider => ProviderManager.shopProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTree(widget.accountBook.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(L10nManager.l10n.merchant),
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(L10nManager.l10n.treeIncludeChildren,
                      style: Theme.of(context).textTheme.labelSmall),
                  Switch(
                    value: _provider.includeChildren,
                    onChanged: (v) => _provider.includeChildren = v,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
          body: _provider.tree.isEmpty
              ? _buildEmptyState(colorScheme)
              : _buildTreeView(),
          floatingActionButton: FloatingActionButton.small(
            heroTag: 'add_shop',
            onPressed: () => _showAddDialog(null),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(L10nManager.l10n.treeEmptyShop,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _showAddDialog(null),
            icon: const Icon(Icons.add, size: 18),
            label: Text(L10nManager.l10n.treeAddChildShop),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView() {
    final flattened = TreeBuilder.flatten(
      _provider.tree,
      isExpanded: (n) => _provider.expandedIds.contains(n.data.id),
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 4),
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final node = flattened[index];
        return _buildTreeTile(node);
      },
    );
  }

  Widget _buildTreeTile(TreeNode<AccountShop> node) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _provider.expandedIds.contains(node.data.id);
    final levelColors = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
    ];
    final accent = levelColors[node.level % levelColors.length];

    return Padding(
      padding: EdgeInsets.only(left: node.level * 24.0),
      child: Dismissible(
        key: ValueKey(node.data.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(L10nManager.l10n.treeDeleteTitle),
              content: Text(L10nManager.l10n.treeDeleteMessageShop(node.data.name)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(L10nManager.l10n.delete(node.data.name)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await _provider.delete(node.data.id);
          }
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete_outline, color: colorScheme.onError),
        ),
        child: InkWell(
          onTap: () {
            final filter = ItemFilterDTO(
              shopCodes: _provider.expandCodes(node.data.code),
            );
            Navigator.of(context).pushNamed(
              AppRoutes.items,
              arguments: [widget.accountBook, filter, node.data.name],
            );
          },
          onLongPress: () => _showMoveDialog(node),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                if (hasChildren)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => _provider.toggleExpand(node.data.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(Icons.chevron_right,
                              size: 20, color: colorScheme.primary),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 36),
                const SizedBox(width: 8),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    node.data.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: node.isRoot ? FontWeight.w600 : FontWeight.w400,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditDialog(node.data),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.edit_outlined,
                        size: 18, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddDialog(node.data.id),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.add_circle_outline,
                        size: 20, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(String? parentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _MerchantDialog(
        title: parentId == null ? L10nManager.l10n.addNew('商户') : L10nManager.l10n.treeAddChildShop,
        controller: controller,
        hint: '输入商户名称',
        onConfirm: () async {
          if (controller.text.trim().isEmpty) return false;
          final result = await _provider.create(
            name: controller.text.trim(),
            parentId: parentId,
          );
          return result.ok;
        },
      ),
    );
  }

  void _showEditDialog(AccountShop shop) {
    final controller = TextEditingController(text: shop.name);
    showDialog(
      context: context,
      builder: (ctx) => _MerchantDialog(
        title: L10nManager.l10n.treeEditName,
        controller: controller,
        hint: '输入新名称',
        onConfirm: () async {
          if (controller.text.trim().isEmpty) return false;
          final result = await _provider.update(
            shop.id,
            name: controller.text.trim(),
          );
          return result.ok;
        },
      ),
    );
  }

  void _showMoveDialog(TreeNode<AccountShop> node) {
    final excludeIds = TreeBuilder.getDescendantIds(
      _provider.tree, node.data.id, idGetter: (c) => c.id,
    ).toSet();
    final allNodes = TreeBuilder.flatten(_provider.tree);
    final filtered = allNodes.where((n) => !excludeIds.contains(n.data.id)).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        final localColor = Theme.of(ctx).colorScheme;
        return Container(
          constraints: BoxConstraints(maxHeight: screenH * 0.75, minHeight: 300),
          decoration: BoxDecoration(
            color: localColor.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: localColor.onSurfaceVariant.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.drive_file_move_outlined, size: 18, color: localColor.primary),
                    const SizedBox(width: 8),
                    Text(L10nManager.l10n.treeMoveTo(node.data.name),
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Divider(height: 1, color: localColor.outline.withAlpha(20)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                  ),
                  title: Text(L10nManager.l10n.treeRootDir, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text(''),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final r = await _provider.batchUpdatePositions(
                      ids: [node.data.id], parentIds: [null], sortOrders: [0],
                    );
                    if (r.ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10nManager.l10n.treeMoveSuccess)));
                    }
                  },
                ),
              ),
              Divider(height: 1, color: localColor.outline.withAlpha(20)),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(L10nManager.l10n.treeNoOptions))
                    : ListView(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        children: filtered.map((n) => Padding(
                          padding: EdgeInsets.only(left: n.level * 24.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: localColor.outline.withAlpha(40),
                                ),
                              ),
                              title: Text(n.data.name, style: Theme.of(ctx).textTheme.bodyMedium),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final r = await _provider.batchUpdatePositions(
                                  ids: [node.data.id], parentIds: [n.data.id], sortOrders: [0],
                                );
                                if (r.ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10nManager.l10n.treeMoveSuccess)));
                                }
                              },
                            ),
                          ),
                        )).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

}

/// 统一风格的操作对话框
class _MerchantDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final Future<bool> Function() onConfirm;

  const _MerchantDialog({
    required this.title,
    required this.controller,
    required this.hint,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) async {
          if (await onConfirm() && context.mounted) Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            if (await onConfirm() && context.mounted) Navigator.pop(context);
          },
          child: Text(L10nManager.l10n.confirm),
        ),
      ],
    );
  }
}
