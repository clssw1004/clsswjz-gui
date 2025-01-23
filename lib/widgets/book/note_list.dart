import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/user_note_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import 'note_tile.dart';

/// 笔记列表
class NoteList extends StatefulWidget {
  /// 账本
  final UserBookVO? accountBook;

  /// 初始笔记列表
  final List<UserNoteVO>? initialNotes;

  /// 是否加载中
  final bool loading;

  /// 点击笔记回调
  final void Function(UserNoteVO note)? onNoteTap;

  /// 加载更多回调
  final Future<void> Function()? onLoadMore;

  /// 是否还有更多数据
  final bool hasMore;

  const NoteList({
    super.key,
    this.accountBook,
    this.initialNotes,
    this.loading = false,
    this.onNoteTap,
    this.onLoadMore,
    this.hasMore = true,
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.loading && (_notes == null || _notes!.isEmpty)) {
      return Center(child: Text(L10nManager.l10n.loading));
    }

    if (_notes == null || _notes!.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                const SizedBox(height: 16),
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
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _notes!.length + 1,
      itemBuilder: (context, index) {
        if (index == _notes!.length) {
          return _buildLoadMoreIndicator(theme);
        }

        final note = _notes![index];
        return NoteTile(
          note: note,
          index: index,
          onTap: widget.onNoteTap == null ? null : () => widget.onNoteTap!(note),
        );
      },
    );
  }
}
