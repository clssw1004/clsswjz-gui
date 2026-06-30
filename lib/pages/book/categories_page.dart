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
import '../../theme/theme_radius.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/tree_select/tree_select_sheet.dart';

class AccountCategoriesPage extends StatefulWidget {
  const AccountCategoriesPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  State<AccountCategoriesPage> createState() => _AccountCategoriesPageState();
}

class _AccountCategoriesPageState extends State<AccountCategoriesPage> {
  CategoryProvider get _provider => ProviderManager.categoryProvider;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTree(widget.accountBook.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_provider.isBatchMode
                ? '已选择 ${_provider.batchSelectedIds.length} 项'
                : L10nManager.l10n.category),
            actions: _provider.isBatchMode
                ? [
                    TextButton(
                      onPressed: () => _provider.exitBatchMode(),
                      child: Text(L10nManager.l10n.cancel),
                    ),
                  ]
                : const [],
          ),
          body: Column(
            children: [
              // 类型筛选
              Padding(
                padding: EdgeInsets.fromLTRB(
                    spacing.formItemSpacing, spacing.formItemSpacing,
                    spacing.formItemSpacing, 0),
                child: SizedBox(
                  width: double.infinity,
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
              ),
              // 树形内容
              Expanded(
                child: _provider.tree.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : _buildTreeView(),
              ),
              _buildBatchPanel(),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            heroTag: 'add_category',
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
          Icon(Icons.category_outlined,
              size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(L10nManager.l10n.treeEmptyCategory,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _showAddDialog(null),
            icon: const Icon(Icons.add, size: 18),
            label: Text(L10nManager.l10n.treeAddChildCategory),
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
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100, top: 4),
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final node = flattened[index];

        return _buildTreeTile(node);
      },
    );
  }

  Widget _buildTreeTile(TreeNode<AccountCategory> node) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _provider.expandedIds.contains(node.data.id);
    // 层级渐变色：根节点较深，子节点渐浅（左侧边框）
    final levelColors = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.primary.withValues(alpha: 0.6),
      colorScheme.tertiary.withValues(alpha: 0.6),
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
              content: Text(L10nManager.l10n.treeDeleteMessageCategory(node.data.name)),
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
          return false; // 由 Provider 刷新列表
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
          onLongPress: () {
            _provider.enterBatchMode();
            _provider.toggleBatchSelect(node.data.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // 展开指示（仅视觉）
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
                if (_provider.isBatchMode)
                  Checkbox(
                    value: _provider.batchSelectedIds.contains(node.data.id),
                    onChanged: (_) => _provider.toggleBatchSelect(node.data.id),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: accent,
                  ),
                // 层级色标
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                // 名称
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
                if (!_provider.isBatchMode) ...[
                  // 查看账目
                  GestureDetector(
                    onTap: () {
                      final filter = ItemFilterDTO(
                        categoryCodes: _provider.expandCodes(node.data.code),
                        types: [_provider.selectedType],
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
                  // 添加子分类
                  GestureDetector(
                    onTap: () => _showAddDialog(node.data.id),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.add_circle_outline,
                          size: 20, color: colorScheme.primary),
                    ),
                  ),
                ],
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
      builder: (ctx) => _TreeDialog(
        title: parentId == null ? L10nManager.l10n.addNew('分类') : L10nManager.l10n.treeAddChildCategory,
        controller: controller,
        hint: '输入分类名称',
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

  void _showEditDialog(AccountCategory category) {
    final nameCtrl = TextEditingController(text: category.name);
    bool selectable = category.isBookkeepingSelectable;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(L10nManager.l10n.treeEditName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: '输入新名称'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('记账时可选', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Switch(
                    value: selectable,
                    onChanged: (v) => setLocalState(() => selectable = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(L10nManager.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final result = await _provider.update(
                  category.id,
                  name: nameCtrl.text.trim(),
                  isBookkeepingSelectable: selectable,
                );
                if (result.ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(L10nManager.l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMoveDialog(TreeNode<AccountCategory> node) async {
    final excludeIds = TreeBuilder.getDescendantIds(
      _provider.tree,
      node.data.id,
      idGetter: (c) => c.id,
    ).toSet();
    // 重新建树（排除自身及子孙）
    List<TreeNode<AccountCategory>> filterTree(List<TreeNode<AccountCategory>> nodes) {
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
              // 拖拽条
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(50),
                    borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // 标题 + 根目录按钮
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
              // TreeSelectSheet (无外壳模式)
              TreeSelectSheet<AccountCategory>(
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

  Widget _buildBatchPanel() {
    if (!_provider.isBatchMode || _provider.batchSelectedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline.withAlpha(20))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '已选择 ${_provider.batchSelectedIds.length} 项',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.drive_file_move_outlined, size: 18),
              label: const Text('移动到...'),
              onPressed: () => _showBatchMoveDialog(),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _provider.exitBatchMode(),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchMoveDialog() async {
    if (_provider.batchSelectedIds.isEmpty) return;
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
                    '移动到...',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                  TextButton.icon(
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: Text(L10nManager.l10n.treeRootDir),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _provider.batchMove(null);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(L10nManager.l10n.treeMoveSuccess)));
                      }
                    },
                  ),
                ]),
              ),
              Divider(height: 1, color: cs.outline.withAlpha(20)),
              TreeSelectSheet<AccountCategory>(
                filtered: _getMoveTree(),
                displayField: (c) => c.name,
                idField: (c) => c.id,
                multiSelect: false,
                noShell: true,
                onNodeTap: (data) async {
                  Navigator.pop(ctx);
                  await _provider.batchMove(data.id);
                  if (mounted) {
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

  List<TreeNode<AccountCategory>> _getMoveTree() => _provider.tree;

}

/// 统一风格的操作对话框
class _TreeDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final Future<bool> Function() onConfirm;

  const _TreeDialog({
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
          child: Text(L10nManager.l10n.cancel),
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


