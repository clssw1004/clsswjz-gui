import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/l10n_manager.dart';
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
              // 分组筛选 + 报表切换
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
                          selectedGroupCodes: noteListProvider.filterType == NoteFilterType.report ? null : noteListProvider.groupCodes,
                          onGroupCodesChanged: (codes) {
                            noteListProvider.setGroupCodes(codes);
                            noteListProvider.setFilterType(null);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '报表',
                        icon: Icons.assessment_rounded,
                        selected: noteListProvider.filterType == NoteFilterType.report,
                        onTap: () {
                          noteListProvider.setFilterType(
                            noteListProvider.filterType == NoteFilterType.report
                                ? null : NoteFilterType.report,
                          );
                        },
                      ),
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
                            Navigator.pushNamed(
                              context, AppRoutes.reportDetail,
                              arguments: note,
                            );
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

/// 小型筛选切换块
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: selected
                  ? cs.primaryContainer
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: cs.primary.withValues(alpha: 0.3))
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: selected ? cs.onPrimaryContainer : cs.primary),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: selected ? cs.onPrimaryContainer : cs.onSurface,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
