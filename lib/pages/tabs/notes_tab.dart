import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/l10n_manager.dart';
import '../../services/monthly_report_service.dart';
import '../../utils/toast_util.dart';
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

  void _handleGroupChanged(List<String>? codes) {
    if (codes != null && codes.contains(kReportFilterCode)) {
      context.read<NoteListProvider>().setFilterType(NoteFilterType.report);
    } else {
      context.read<NoteListProvider>().setGroupCodes(codes);
    }
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
          final isReport = noteListProvider.filterType == NoteFilterType.report;
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
                    selectedGroupCodes: isReport ? [kReportFilterCode] : noteListProvider.groupCodes,
                    onGroupCodesChanged: _handleGroupChanged,
                    isReportActive: isReport,
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
                        footerItems: isReport
                            ? _buildMissingMonthWidgets(noteListProvider)
                            : null,
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

  List<Widget> _buildMissingMonthWidgets(NoteListProvider provider) {
    final cs = Theme.of(context).colorScheme;
    return provider.missingMonths.map((m) => _MissingMonthCard(
      year: m.year,
      month: m.month,
      cs: cs,
      onGenerate: () => _generateReport(provider, m.year, m.month),
    )).toList();
  }

  Future<void> _generateReport(NoteListProvider provider, int year, int month) async {
    final bookId = context.read<BooksProvider>().selectedBook?.id;
    if (bookId == null) return;
    final service = MonthlyReportService();
    final noteId = await service.regenerateReport(bookId, year, month);
    if (mounted) {
      if (noteId != null) {
        ToastUtil.showSuccess(L10nManager.l10n.reportRegenerated);
        provider.loadNotes(true);
      } else {
        ToastUtil.showError(L10nManager.l10n.reportNoData);
      }
    }
  }
}

/// 缺失月份占位卡片
class _MissingMonthCard extends StatelessWidget {
  final int year;
  final int month;
  final ColorScheme cs;
  final VoidCallback onGenerate;

  const _MissingMonthCard({
    required this.year,
    required this.month,
    required this.cs,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withValues(alpha: 0.06)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('$month',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$year年$month月', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
              const SizedBox(height: 1),
              Text(L10nManager.l10n.reportNotGenerated, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ]),
          ),
          SizedBox(
            height: 30,
            child: OutlinedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.add, size: 14),
              label: Text(L10nManager.l10n.reportGenerate, style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
