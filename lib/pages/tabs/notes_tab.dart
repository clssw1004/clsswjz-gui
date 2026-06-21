import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/dao_manager.dart';
import '../../models/vo/user_note_vo.dart';
import '../../widgets/note_renderer.dart';
import '../../providers/books_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../providers/note_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/note_list.dart';
import '../../widgets/book/note_group_filter.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../widgets/common/common_search_field.dart';
import '../../widgets/report/report_month_filter.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NoteListProvider>();
      provider.loadNotes();
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
      final syncProvider = context.read<SyncProvider>();
      await syncProvider.syncData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _handleSearch() {
    final provider = context.read<NoteListProvider>();
    provider.setKeyword(_searchController.text);
  }

  void _handleGroupFilterChanged(List<String>? groupCodes) {
    final provider = context.read<NoteListProvider>();
    provider.setGroupCodes(groupCodes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booksProvider = Provider.of<BooksProvider>(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.tabNotes),
        showBackButton: false,
        centerTitle: false,
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
              // 分组筛选 + 报表入口
              if (booksProvider.selectedBook != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: spacing.contentPadding.left,
                    right: spacing.contentPadding.right,
                    bottom: spacing.formItemSpacing,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: NoteGroupFilter(
                          bookId: booksProvider.selectedBook!.id,
                          selectedGroupCodes: noteListProvider.groupCodes,
                          onGroupCodesChanged: _handleGroupFilterChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ReportFilterButton(bookId: booksProvider.selectedBook!.id),
                    ],
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
                            // 只读笔记 → 渲染器详情页
                            Navigator.pushNamed(
                              context,
                              AppRoutes.reportDetail,
                              arguments: note,
                            );
                          } else {
                            // 可编辑笔记 → 编辑页
                            Navigator.pushNamed(
                              context,
                              AppRoutes.noteEdit,
                              arguments: [note, booksProvider.selectedBook],
                            ).then((updated) {
                              if (updated == true) {
                                noteListProvider.loadNotes(true);
                              }
                            });
                          }
                        },
                      ),
                    ),
                    if (syncProvider.syncing && syncProvider.currentStep != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
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

/// 报表筛选按钮
class _ReportFilterButton extends StatelessWidget {
  final String bookId;
  const _ReportFilterButton({required this.bookId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReportSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assessment_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 4),
                Text('报表', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.68,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽手柄
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 内容
            Flexible(
              child: ReportMonthFilter(
                bookId: bookId,
                onReportSelected: (noteId) {
                  Navigator.of(ctx).pop();
                  // 通过 noteId 查找笔记并跳转
                  _navigateToReport(context, noteId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToReport(BuildContext context, String noteId) async {
    final note = await DaoManager.noteDao.findById(noteId);
    if (note != null && context.mounted) {
      final vo = UserNoteVO.fromAccountNote(note, null);
      Navigator.pushNamed(context, AppRoutes.reportDetail, arguments: vo);
    }
  }
}
