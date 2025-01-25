import 'package:flutter/material.dart';
import '../../models/vo/user_note_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'note_tile.dart';

/// 笔记列表
class NoteList extends StatefulWidget {
  /// 账本
  final UserBookVO? accountBook;

  /// 初始笔记列表
  final List<UserNoteVO> initialNotes;

  /// 是否加载中
  final bool loading;

  /// 是否还有更多数据
  final bool hasMore;

  /// 加载更多回调
  final Future<void> Function()? onLoadMore;

  /// 删除回调
  final Future<bool> Function(UserNoteVO note)? onDelete;

  /// 点击笔记回调
  final void Function(UserNoteVO note)? onNoteTap;

  const NoteList({
    super.key,
    this.accountBook,
    required this.initialNotes,
    this.loading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onDelete,
    this.onNoteTap,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  /// 笔记列表
  List<UserNoteVO>? _notes;

  /// 是否正在加载更多
  bool _loadingMore = false;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _notes = widget.initialNotes;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (!widget.hasMore || _loadingMore || widget.onLoadMore == null) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// 加载更多数据
  Future<void> _loadMore() async {
    if (_loadingMore || !widget.hasMore) return;

    setState(() => _loadingMore = true);

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  @override
  void didUpdateWidget(NoteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNotes != widget.initialNotes) {
      _notes = widget.initialNotes;
    }
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(ThemeData theme) {
    if (!widget.hasMore) {
      return Container(
        padding: theme.spacing.loadMorePadding,
        child: Center(
          child: Text(
            L10nManager.l10n.noMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: theme.spacing.loadMorePadding,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: theme.spacing.listItemSpacing),
            Text(
              L10nManager.l10n.loading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建列表项
  Widget _buildListItem(UserNoteVO note, int index, ThemeData theme) {
    return NoteTile(
      note: note,
      index: index,
      onTap: () => widget.onNoteTap?.call(note),
      onDelete: widget.onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    if (widget.loading && (_notes == null || _notes!.isEmpty)) {
      return Center(child: Text(L10nManager.l10n.loading));
    }

    if (_notes == null || _notes!.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onLoadMore ?? Future.value,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  SizedBox(height: spacing.listItemSpacing * 2),
                  Text(
                    '暂无笔记',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onLoadMore ?? Future.value,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _notes!.length + 1,
        itemBuilder: (context, index) {
          if (index == _notes!.length) {
            return _buildLoadMoreIndicator(theme);
          }

          final note = _notes![index];
          return _buildListItem(note, index, theme);
        },
      ),
    );
  }
}
