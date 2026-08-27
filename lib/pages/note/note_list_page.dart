import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/note_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/book/note_group_filter.dart';
import '../../widgets/book/note_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_search_field.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../widgets/note_renderer.dart';

/// 普通记事列表页（从「工具」Tab 宫格进入）。
///
/// 仅展示 NOTE 类型的笔记，点击进入编辑页。
class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteListProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await context.read<SyncProvider>().syncData();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _handleSearch() {
    context.read<NoteListProvider>().setKeyword(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final spacing = Theme.of(context).spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.noteListTitle),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: L10nManager.l10n.addNew(L10nManager.l10n.note),
            icon: const Icon(Icons.add_rounded),
            onPressed: () => NavigationUtil.toNoteAdd(context),
          ),
        ],
      ),
      body: Consumer2<NoteListProvider, SyncProvider>(
        builder: (context, noteListProvider, syncProvider, child) {
          return Column(
            children: [
              // 搜索栏
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.contentPadding.left,
                  spacing.contentPadding.top,
                  spacing.contentPadding.right,
                  spacing.formItemSpacing,
                ),
                child: CommonSearchField(
                  width: double.infinity,
                  controller: _searchController,
                  hintText: L10nManager.l10n.search,
                  onSubmitted: (_) => _handleSearch(),
                  onClear: _handleSearch,
                ),
              ),
              // 分组筛选
              if (booksProvider.selectedBook != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: spacing.contentPadding.left,
                    right: spacing.contentPadding.right,
                    bottom: spacing.formItemSpacing,
                  ),
                  child: NoteGroupFilter(
                    bookId: booksProvider.selectedBook!.id,
                    selectedGroupCodes: noteListProvider.groupCodes,
                    onGroupCodesChanged: noteListProvider.setGroupCodes,
                  ),
                ),
              // 笔记列表
              Expanded(
                child: Stack(
                  children: [
                    CustomRefreshIndicator(
                      onRefresh: _handleRefresh,
                      builder: (context, child, controller) => child,
                      child: NoteList(
                        accountBook: booksProvider.selectedBook,
                        initialNotes: noteListProvider.notes,
                        loading: noteListProvider.loading,
                        hasMore: noteListProvider.hasMore,
                        onLoadMore: () => noteListProvider.loadMore(),
                        onDelete: noteListProvider.deleteNote,
                        onNoteTap: (note) {
                          final renderer = NoteRendererRegistry.resolve(
                              note.noteType, note.template);
                          if (renderer != null && !renderer.isEditable) {
                            Navigator.pushNamed(
                              context, AppRoutes.reportDetail,
                              arguments: note,
                            ).then((_) => noteListProvider.loadNotes(true));
                          } else {
                            Navigator.pushNamed(
                              context, AppRoutes.noteEdit,
                              arguments: [note, booksProvider.selectedBook],
                            ).then((updated) {
                              if (updated == true) noteListProvider.loadNotes(true);
                            });
                          }
                        },
                      ),
                    ),
                    if (syncProvider.syncing && syncProvider.currentStep != null)
                      Positioned(
                        left: 0, right: 0, bottom: 0,
                        child: ProgressIndicatorBar(
                          value: syncProvider.progress,
                          label: syncProvider.currentStep!,
                          height: 24,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
