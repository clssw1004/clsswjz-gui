import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/provider_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/shop_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_radius.dart';
import '../../widgets/common/tree_select/tree_select_sheet.dart';

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
            actions: const [],
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
      padding: const EdgeInsets.only(bottom: 100, top: 4),
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
            if (node.children.isNotEmpty) {
              _provider.toggleExpand(node.data.id);
            }
          },
          onLongPress: () => _showEditDialog(node.data),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                if (hasChildren)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.chevron_right,
                          size: 20, color: colorScheme.primary),
                    ),
                  )
                else
                  const SizedBox(width: 28),
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
                // 查看账目
                GestureDetector(
                  onTap: () {
                    final filter = ItemFilterDTO(
                      shopCodes: _provider.expandCodes(node.data.code),
                    );
                    Navigator.of(context).pushNamed(
                      AppRoutes.items,
                      arguments: [widget.accountBook, filter, node.data.name],
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 20, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                // 移动
                GestureDetector(
                  onTap: () => _showMoveDialog(node),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.drive_file_move_outlined,
                        size: 18, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                // 编辑
                GestureDetector(
                  onTap: () => _showEditDialog(node.data),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.edit_outlined,
                        size: 18, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                // 添加子商户
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

  Future<void> _showMoveDialog(TreeNode<AccountShop> node) async {
    final excludeIds = TreeBuilder.getDescendantIds(
      _provider.tree, node.data.id, idGetter: (c) => c.id,
    ).toSet();
    List<TreeNode<AccountShop>> filterTree(List<TreeNode<AccountShop>> nodes) {
      return nodes
          .where((n) => !excludeIds.contains(n.data.id))
          .map((n) => n.copyWith(children: filterTree(n.children)))
          .toList();
    }
    final filteredRoots = filterTree(_provider.tree);

    final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(50),
                    borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                child: Row(children: [
                  Icon(Icons.drive_file_move_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    L10nManager.l10n.treeMoveTo(node.data.name),
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                  TextButton.icon(
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: Text(L10nManager.l10n.treeRootDir),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final r = await _provider.batchUpdatePositions(
                        ids: [node.data.id], parentIds: [null], sortOrders: [0]);
                      if (r.ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(L10nManager.l10n.treeMoveSuccess)));
                      }
                    },
                  ),
                ]),
              ),
              Divider(height: 1, color: cs.outline.withAlpha(20)),
              TreeSelectSheet<AccountShop>(
                filtered: filteredRoots,
                displayField: (c) => c.name,
                idField: (c) => c.id,
                multiSelect: false,
                noShell: true,
                onNodeTap: (data) async {
                  Navigator.pop(ctx);
                  final r = await _provider.batchUpdatePositions(
                    ids: [node.data.id], parentIds: [data.id], sortOrders: [0]);
                  if (r.ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(L10nManager.l10n.treeMoveSuccess)));
                  }
                },
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
