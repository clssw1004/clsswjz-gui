import 'package:flutter/material.dart';
import '../../models/vo/user_note_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_empty_view.dart';
import '../common/common_loading_view.dart';
import '../note_renderer.dart';
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

  /// 列表底部额外组件（报表缺失月份等）
  final List<Widget>? footerItems;

  const NoteList({
    super.key,
    this.accountBook,
    required this.initialNotes,
    this.loading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onDelete,
    this.onNoteTap,
    this.footerItems,
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
    final renderer = NoteRendererRegistry.resolve(note.noteType, note.template);
    if (renderer != null) {
      return renderer.buildTile(
        note,
        () => widget.onNoteTap?.call(note),
        onDelete: widget.onDelete != null ? () => widget.onDelete!(note) : null,
      );
    }
    // 兜底：默认 Quill 笔记
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

    if (widget.loading && (_notes == null || _notes!.isEmpty)) {
      return const CommonLoadingView();
    }

    if (_notes == null || _notes!.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onLoadMore ?? Future.value,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: CommonEmptyView(
                message: L10nManager.l10n.noData,
                icon: Icons.note_outlined,
              ),
            ),
          ],
        ),
      );
    }

    final footer = widget.footerItems ?? [];
    return RefreshIndicator(
      onRefresh: widget.onLoadMore ?? Future.value,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _notes!.length + 1 + footer.length,
        itemBuilder: (context, index) {
          if (index < _notes!.length) {
            final note = _notes![index];
            return _buildListItem(note, index, theme);
          }
          final footerIdx = index - _notes!.length;
          if (footerIdx <= footer.length && footerIdx > 0) {
            return footer[footerIdx - 1];
          }
          return _buildLoadMoreIndicator(theme);
        },
      ),
    );
  }
}
