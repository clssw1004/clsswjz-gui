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

  const SearchResult({
    required this.id,
    required this.display,
    this.leading,
    this.subtitle,
    this.trailing,
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

  const RelationTargetConfig({
    required this.code,
    required this.label,
    this.multiSelect = false,
    this.searchBuilder,
    required this.displayBuilder,
    required this.onTap,
    this.bookListBuilder,
    this.initialBookId,
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
        else if (widget.displayMode == RelationDisplayMode.compact)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.contentPadding.left,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._relations.map((relation) => GestureDetector(
                  onLongPress: () => _handleDeleteRelation(relation),
                  onTap: () => widget.target.onTap(context, relation),
                  child: widget.target.displayBuilder(
                    context,
                    relation,
                    () => widget.target.onTap(context, relation),
                  ),
                )),
                _buildAddChip(colorScheme),
              ],
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
              confirmDismiss: (_) async {
                await _handleDeleteRelation(relation);
                return true;
              },
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

  Widget _buildAddChip(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _handleAddRelation,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withAlpha(30),
          ),
        ),
        child: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
      ),
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

  const _ItemMultiSearchDialog({
    required this.searchBuilder,
    required this.label,
    required this.multiSelect,
    this.bookListBuilder,
    this.initialBookId,
  });

  static Future<List<String>?> show({
    required BuildContext context,
    required Future<List<SearchResult>> Function(BuildContext, String, String?) searchBuilder,
    required String label,
    bool multiSelect = false,
    Future<List<BookSwitcherItem>> Function()? bookListBuilder,
    String? initialBookId,
  }) {
    return Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ItemMultiSearchDialog(
          searchBuilder: searchBuilder,
          label: label,
          multiSelect: multiSelect,
          bookListBuilder: bookListBuilder,
          initialBookId: initialBookId,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('选择${widget.label}'),
        actions: [
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
                              Icon(Icons.check, size: 18, color: colorScheme.primary),
                            if (book.id == _currentBookId) const SizedBox(width: 8),
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
                    Text(
                      _books.where((b) => b.id == _currentBookId).firstOrNull?.name ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
                  borderSide: BorderSide(color: colorScheme.outline.withAlpha(50)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline.withAlpha(30)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(40),
              ),
              onChanged: (_) => _search(),
            ),
          ),
          // 搜索结果
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? '暂无${widget.label}'
                              : '未找到匹配${widget.label}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final selected = _selectedIds.contains(item.id);
                          return ListTile(
                            leading: item.leading,
                            title: Text(
                              item.display,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: selected ? FontWeight.w600 : null,
                              ),
                            ),
                            subtitle: item.subtitle != null
                                ? Text(
                                    item.subtitle!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                            trailing: widget.multiSelect
                                ? Icon(
                                    selected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                    size: 22,
                                  )
                                : item.trailing,
                            selected: selected,
                            selectedTileColor:
                                colorScheme.primaryContainer.withAlpha(60),
                            onTap: () => _toggleSelection(item),
                          );
                        },
                      ),
          ),
          // 已选面板（多选模式）
          if (widget.multiSelect && _selectedIds.isNotEmpty)
            _buildSelectedPanel(theme, colorScheme),
        ],
      ),
      bottomNavigationBar:
          widget.multiSelect && _selectedIds.isNotEmpty
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _confirm,
                        child: Text('确定（${_selectedIds.length}）'),
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildSelectedPanel(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
        border: Border(
          top: BorderSide(color: colorScheme.outline.withAlpha(25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Text(
              '已选（${_selectedIds.length}）',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 6),
              itemCount: _selectedItems.values.length,
              itemBuilder: (context, index) {
                final item = _selectedItems.values.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      item.display.length > 12
                          ? '${item.display.substring(0, 12)}…'
                          : item.display,
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => _toggleSelection(item),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    backgroundColor: colorScheme.secondaryContainer,
                    labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
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
