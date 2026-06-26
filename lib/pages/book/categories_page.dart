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

/// 带树状连线的层级指示器
class _TreeIndent extends StatelessWidget {
  final int level;
  final bool isLast;
  final List<bool> ancestorIsLast;

  const _TreeIndent({
    required this.level,
    required this.isLast,
    required this.ancestorIsLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return SizedBox(
      width: level * 24.0,
      child: CustomPaint(
        painter: _TreeLinePainter(
          level: level,
          isLast: isLast,
          ancestorIsLast: ancestorIsLast,
          color: color,
        ),
      ),
    );
  }
}

class _TreeLinePainter extends CustomPainter {
  final int level;
  final bool isLast;
  final List<bool> ancestorIsLast;
  final Color color;

  _TreeLinePainter({
    required this.level,
    required this.isLast,
    required this.ancestorIsLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const segW = 24.0;
    const midY = 28.0; // 对齐 ListTile 中心

    for (int i = 0; i < level; i++) {
      final x = i * segW + segW / 2;
      if (i < level - 1) {
        // 祖先层级：如果不是最后一个，画竖线
        if (!ancestorIsLast[i]) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
      } else {
        // 当前层级：画竖线 + 横线弯头
        canvas.drawLine(Offset(x, 0), Offset(x, midY), paint);
        canvas.drawLine(Offset(x, midY), Offset(x + segW / 2, midY), paint);
        if (isLast) {
          // 最后一个子节点，竖线只画到弯头处
        } else {
          canvas.drawLine(Offset(x, midY), Offset(x, size.height), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter old) =>
      level != old.level || isLast != old.isLast || color != old.color;
}

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
            title: Text(L10nManager.l10n.category),
            actions: [
              // 包含子类开关
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('子类',
                        style: Theme.of(context).textTheme.labelSmall),
                    Switch(
                      value: _provider.includeChildren,
                      onChanged: (v) => _provider.includeChildren = v,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            ],
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
              const SizedBox(height: 8),
              // 树形内容
              Expanded(
                child: _provider.tree.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : _buildTreeView(),
              ),
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
          Text('暂无分类',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _showAddDialog(null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加分类'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView() {
    final flattened = TreeBuilder.flatten(_provider.tree);
    // 需要知道每个节点的「祖先中哪些是最后一个子节点」用于画线
    final lastAncestors = _computeLastAncestors(flattened);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80, top: 4),
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final node = flattened[index];
        final isLast = index == flattened.length - 1 ||
            (index + 1 < flattened.length &&
                flattened[index + 1].level <= node.level);
        final ancestorLast = lastAncestors[index];

        return _buildTreeTile(node, isLast, ancestorLast);
      },
    );
  }

  Widget _buildTreeTile(
      TreeNode<AccountCategory> node, bool isLast, List<bool> ancestorIsLast) {
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
    // 每层背景轻微递变
    final bgOpacity = 1.0 - node.level * 0.06;

    return Padding(
      padding: EdgeInsets.only(left: node.level * 24.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1.5),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow.withValues(alpha: bgOpacity.clamp(0.7, 1.0)),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: accent, width: 3),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // 展开/折叠按钮
                  if (hasChildren)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(Icons.chevron_right,
                              size: 20, color: colorScheme.onSurfaceVariant),
                        ),
                        onPressed: () => _provider.toggleExpand(node.data.id),
                      ),
                    )
                  else
                    const SizedBox(width: 36),
                  const SizedBox(width: 4),
                  // 层级圆点
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: node.isRoot
                          ? accent
                          : accent.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 名称
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          node.data.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: node.isRoot
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '#${node.data.code}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // 操作菜单
                  _TreeActions(
                    onAddChild: () => _showAddDialog(node.data.id),
                    onEdit: () => _showEditDialog(node.data),
                    onDelete: () => _confirmDelete(node.data),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 计算每个 flatten 节点各层祖先是否是最后一个子节点
  List<List<bool>> _computeLastAncestors(
      List<TreeNode<AccountCategory>> nodes) {
    final result = <List<bool>>[];
    final ancestors = <_LevelLast>{};
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      // 清除比当前层级深的祖先记录
      ancestors.removeWhere((a) => a.level >= node.level);
      final isLast = i == nodes.length - 1 ||
          (i + 1 < nodes.length && nodes[i + 1].level <= node.level);
      ancestors.add(_LevelLast(level: node.level, isLast: isLast));
      result.add(ancestors
          .where((a) => a.level < node.level)
          .map((a) => a.isLast)
          .toList());
    }
    return result;
  }

  void _showAddDialog(String? parentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _TreeDialog(
        title: parentId == null ? '添加分类' : '添加子分类',
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
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => _TreeDialog(
        title: '编辑名称',
        controller: controller,
        hint: '输入新名称',
        onConfirm: () async {
          if (controller.text.trim().isEmpty) return false;
          final result = await _provider.update(
            category.id,
            name: controller.text.trim(),
          );
          return result.ok;
        },
      ),
    );
  }

  void _confirmDelete(AccountCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('删除「${category.name}」及其所有子分类？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              final result = await _provider.delete(category.id);
              if (result.ok && ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
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
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            if (await onConfirm() && context.mounted) Navigator.pop(context);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

/// 树节点操作按钮组
class _TreeActions extends StatelessWidget {
  final VoidCallback onAddChild;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TreeActions({
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz, size: 20, color: colorScheme.onSurfaceVariant),
      onSelected: (v) {
        switch (v) {
          case 'add': onAddChild();
          case 'edit': onEdit();
          case 'delete': onDelete();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'add', child: ListTile(
          leading: Icon(Icons.add_circle_outline, size: 20),
          title: Text('添加子分类'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
        const PopupMenuItem(value: 'edit', child: ListTile(
          leading: Icon(Icons.edit_outlined, size: 20),
          title: Text('编辑'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
        const PopupMenuItem(value: 'delete', child: ListTile(
          leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
          title: Text('删除', style: TextStyle(color: Colors.red)),
          dense: true,
          contentPadding: EdgeInsets.zero,
        )),
      ],
    );
  }
}

/// 辅助记录层级及是否为最后节点
class _LevelLast {
  final int level;
  final bool isLast;
  const _LevelLast({required this.level, required this.isLast});
}
