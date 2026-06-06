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
  final String? subtitle;
  final Widget? trailing;
  final int? colorValue;
  final String? trailingText;

  const SearchResult({
    required this.id,
    required this.display,
    this.leading,
    this.subtitle,
    this.trailing,
    this.colorValue,
    this.trailingText,
  });
}

/// 账本切换项
class BookSwitcherItem {
  final String id;
  final String name;

  const BookSwitcherItem({required this.id, required this.name});
}

/// 关联目标配置
class RelationTargetConfig {
  final String code;
  final String label;
  final bool multiSelect;
  final Future<List<SearchResult>> Function(
    BuildContext context,
    String query,
    String? bookId,
  )? searchBuilder;
  final Widget Function(
    BuildContext context,
    ItemRelationVO relation,
    VoidCallback onTap,
  ) displayBuilder;
  final void Function(BuildContext context, ItemRelationVO relation) onTap;
  final Future<List<BookSwitcherItem>> Function()? bookListBuilder;
  final String? initialBookId;
  final Future<String?> Function(BuildContext context, String bookId)? onCreateItem;

  const RelationTargetConfig({
    required this.code,
    required this.label,
    this.multiSelect = false,
    this.searchBuilder,
    required this.displayBuilder,
    required this.onTap,
    this.bookListBuilder,
    this.initialBookId,
    this.onCreateItem,
  });
}

/// 关联展示模式
enum RelationDisplayMode {
  /// 紧凑模式 - Wrap 布局, 长按删除
  compact,

  /// 列表模式 - Column + Dismissible 滑动删除
  list,
}

/// 通用关联面板
class ItemRelationPanel extends StatefulWidget {
  final String relationCode;
  final String relationId;
  final String accountBookId;
  final RelationTargetConfig target;
  final RelationDisplayMode displayMode;

  const ItemRelationPanel({
    super.key,
    required this.relationCode,
    required this.relationId,
    required this.accountBookId,
    required this.target,
    this.displayMode = RelationDisplayMode.list,
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
    if (widget.target.searchBuilder == null) return;

    final itemIds = await _ItemMultiSearchDialog.show(
      context: context,
      searchBuilder: widget.target.searchBuilder!,
      label: widget.target.label,
      multiSelect: widget.target.multiSelect,
      bookListBuilder: widget.target.bookListBuilder,
      initialBookId: widget.target.initialBookId,
      onCreateItem: widget.target.onCreateItem,
    );

    if (itemIds != null && itemIds.isNotEmpty && mounted) {
      final provider = context.read<ItemRelationProvider>();
      for (final itemId in itemIds) {
        await provider.createRelation(
          itemId: itemId,
          accountBookId: widget.accountBookId,
          relationCode: widget.relationCode,
          relationId: widget.relationId,
        );
      }
      if (mounted) {
        _loadRelations();
      }
    }
  }

  Future<void> _confirmDeleteRelation(ItemRelationVO relation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除关联'),
        content: Text('确定移除该${widget.target.label}关联？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _handleDeleteRelation(relation);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              Icon(Icons.link, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '关联${widget.target.label}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _handleAddRelation,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text('关联${widget.target.label}'),
              ),
            ],
          ),
        ),
        // 内容区域（可滚动，防止溢出）
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _relations.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.contentPadding.left,
                      ),
                      child: Text(
                        '暂无关联${widget.target.label}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : widget.displayMode == RelationDisplayMode.compact
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.contentPadding.left,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._relations.map((relation) => GestureDetector(
                                onLongPress: () =>
                                    _confirmDeleteRelation(relation),
                                onTap: () =>
                                    widget.target.onTap(context, relation),
                                child: widget.target.displayBuilder(
                                  context,
                                  relation,
                                  () => widget.target
                                      .onTap(context, relation),
                                ),
                              )),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.contentPadding.left,
                          ),
                          itemCount: _relations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final relation = _relations[index];
                            return Dismissible(
                              key: ValueKey(relation.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color:
                                    Theme.of(context).colorScheme.error,
                                child: Icon(Icons.delete_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onError),
                              ),
                              confirmDismiss: (_) async {
                                await _handleDeleteRelation(relation);
                                return true;
                              },
                              child: widget.target.displayBuilder(
                                context,
                                relation,
                                () => widget.target
                                    .onTap(context, relation),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

}

/// 多选/分栏搜索对话框
class _ItemMultiSearchDialog extends StatefulWidget {
  final Future<List<SearchResult>> Function(BuildContext, String, String?) searchBuilder;
  final String label;
  final bool multiSelect;
  final Future<List<BookSwitcherItem>> Function()? bookListBuilder;
  final String? initialBookId;
  final Future<String?> Function(BuildContext context, String bookId)? onCreateItem;

  const _ItemMultiSearchDialog({
    required this.searchBuilder,
    required this.label,
    required this.multiSelect,
    this.bookListBuilder,
    this.initialBookId,
    this.onCreateItem,
  });

  static Future<List<String>?> show({
    required BuildContext context,
    required Future<List<SearchResult>> Function(BuildContext, String, String?) searchBuilder,
    required String label,
    bool multiSelect = false,
    Future<List<BookSwitcherItem>> Function()? bookListBuilder,
    String? initialBookId,
    Future<String?> Function(BuildContext context, String bookId)? onCreateItem,
  }) {
    final maxHeight = MediaQuery.of(context).size.height * 0.66;
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: _ItemMultiSearchDialog(
          searchBuilder: searchBuilder,
          label: label,
          multiSelect: multiSelect,
          bookListBuilder: bookListBuilder,
          initialBookId: initialBookId,
          onCreateItem: onCreateItem,
        ),
      ),
    );
  }

  @override
  State<_ItemMultiSearchDialog> createState() => _ItemMultiSearchDialogState();
}

class _ItemMultiSearchDialogState extends State<_ItemMultiSearchDialog> {
  final _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _searching = false;

  final Set<String> _selectedIds = {};
  final Map<String, SearchResult> _selectedItems = {};

  List<BookSwitcherItem> _books = [];
  String? _currentBookId;

  @override
  void initState() {
    super.initState();
    _currentBookId = widget.initialBookId;
    _loadBooks();
    _search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    if (widget.bookListBuilder == null) return;
    try {
      final books = await widget.bookListBuilder!();
      if (mounted) {
        setState(() => _books = books);
      }
    } catch (_) {}
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    try {
      final results = await widget.searchBuilder(
        context,
        _searchController.text,
        _currentBookId,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _toggleSelection(SearchResult item) {
    if (!widget.multiSelect) {
      Navigator.pop(context, [item.id]);
      return;
    }
    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
        _selectedItems.remove(item.id);
      } else {
        _selectedIds.add(item.id);
        _selectedItems[item.id] = item;
      }
    });
  }

  void _confirm() {
    Navigator.pop(context, _selectedIds.toList());
  }

  Future<void> _handleCreateItem() async {
    if (widget.onCreateItem == null || _currentBookId == null) return;
    final newItemId = await widget.onCreateItem!(context, _currentBookId!);
    if (newItemId != null && mounted) {
      if (!widget.multiSelect) {
        Navigator.pop(context, [newItemId]);
      } else {
        setState(() {
          _selectedIds.add(newItemId);
        });
        _search();
      }
    } else if (mounted) {
      _search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 头部
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, size: 18,
                    color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '选择${widget.label}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_books.length > 1)
                  PopupMenuButton<BookSwitcherItem>(
                    onSelected: (book) {
                      setState(() => _currentBookId = book.id);
                      _search();
                    },
                    itemBuilder: (context) => _books
                        .map((book) => PopupMenuItem(
                              value: book,
                              child: Row(
                                children: [
                                  if (book.id == _currentBookId)
                                    Icon(Icons.check, size: 18,
                                        color: colorScheme.primary),
                                  if (book.id == _currentBookId)
                                    const SizedBox(width: 8),
                                  Text(book.name),
                                ],
                              ),
                            ))
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 14,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            _books
                                    .where(
                                        (b) => b.id == _currentBookId)
                                    .firstOrNull
                                    ?.name ??
                                '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                if (widget.onCreateItem != null)
                  TextButton.icon(
                    onPressed: _handleCreateItem,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('新建'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colorScheme.primary,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索${widget.label}（描述、金额）',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _search();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (_) => _search(),
            ),
          ),
          // 已选面板（多选模式）
          if (widget.multiSelect && _selectedIds.isNotEmpty)
            _buildSelectedPanel(theme, colorScheme),
          // 搜索结果
          Flexible(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.inbox_outlined
                                  : Icons.search_off,
                              size: 36,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? '暂无${widget.label}'
                                  : '未找到匹配${widget.label}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final selected = _selectedIds.contains(item.id);
                          final amtColor = item.colorValue != null
                              ? Color(item.colorValue!)
                              :
                              colorScheme.onSurface;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => _toggleSelection(item),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.06)
                                      : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? colorScheme.primary
                                            .withValues(alpha: 0.4)
                                        : colorScheme.outline
                                            .withValues(alpha: 0.06),
                                    width: selected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // 色条
                                          Container(
                                            width: 3.5,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  amtColor,
                                                  amtColor.withValues(alpha: 0.2),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // 分类 + 描述
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    item.display,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontWeight: selected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: selected
                                                          ? colorScheme.primary
                                                          : colorScheme
                                                              .onSurface,
                                                    ),
                                                  ),
                                                  if (item.subtitle !=
                                                      null) ...[
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      item.subtitle!,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant
                                                            .withValues(
                                                                alpha: 0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 金额
                                          if (item.trailingText != null)
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(vertical: 10),
                                              child: Text(
                                                item.trailingText!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: amtColor,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.check,
                                            size: 12,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // 确认按钮（多选模式）
          if (widget.multiSelect && _selectedIds.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _confirm,
                    child: Text('确定（${_selectedIds.length}）'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedPanel(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 76),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Icon(Icons.checklist, size: 14,
                    color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  '已选（${_selectedIds.length}）',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              itemCount: _selectedItems.values.length,
              itemBuilder: (context, index) {
                final item = _selectedItems.values.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      item.display.length > 14
                          ? '${item.display.substring(0, 14)}…'
                          : item.display,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _toggleSelection(item),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
