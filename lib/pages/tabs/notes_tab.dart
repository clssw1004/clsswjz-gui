import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../database/database.dart';
import '../../enums/note_type.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/dao_manager.dart';
import '../../models/vo/user_note_vo.dart';
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

class _NotesTabState extends State<NotesTab> with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  final GlobalKey<_ReportTabState> _reportTabKey = GlobalKey<_ReportTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        _reportTabKey.currentState?._refresh();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NoteListProvider>();
      provider.loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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

  void _handleGroupFilterChanged(List<String>? groupCodes) {
    context.read<NoteListProvider>().setGroupCodes(groupCodes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final booksProvider = Provider.of<BooksProvider>(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.tabNotes),
        showBackButton: false,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            color: cs.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '笔记'),
                Tab(text: '报表'),
              ],
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 0: 笔记列表 ──
          Consumer2<NoteListProvider, SyncProvider>(
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
                        onGroupCodesChanged: _handleGroupFilterChanged,
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

          // ── Tab 1: 报表 ──
          if (booksProvider.selectedBook != null)
            _ReportTab(
              key: _reportTabKey,
              bookId: booksProvider.selectedBook!.id,
            )
          else
            Center(child: Text(L10nManager.l10n.noData)),
        ],
      ),
    );
  }
}

/// 报表标签页
class _ReportTab extends StatefulWidget {
  final String bookId;
  const _ReportTab({super.key, required this.bookId});

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  final _service = MonthlyReportService();
  late Future<List<_MonthItem>> _monthsFuture;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _monthsFuture = _loadMonths();
  }

  void _refresh() {
    setState(() {
      _monthsFuture = _loadMonths();
    });
  }

  Future<List<_MonthItem>> _loadMonths() async {
    final now = DateTime.now();
    final months = <_MonthItem>[];

    // 今年已过去的月份（不含本月）
    for (int m = 1; m < now.month; m++) {
      months.add(_MonthItem(year: now.year, month: m));
    }

    // 查询已有报告
    final allNotes = await DaoManager.noteDao.listByBook(widget.bookId, limit: 200);
    final reportNotes = allNotes.where((n) => n.noteType == NoteType.report.code).toList();

    for (final m in months) {
      final title = '月度收支报告 —— ${m.year}年${m.month}月';
      final match = reportNotes.cast<AccountNote?>().firstWhere(
        (n) => n!.title == title,
        orElse: () => null,
      );
      if (match != null) {
        m.noteId = match.id;
        m.generated = true;
      }
    }

    // 倒序（最新的在前）
    return months.reversed.toList();
  }

  Future<void> _generate(_MonthItem m) async {
    setState(() => _generating = true);
    final noteId = await _service.regenerateReport(widget.bookId, m.year, m.month);
    if (mounted) {
      if (noteId != null) {
        m.noteId = noteId;
        m.generated = true;
        setState(() {});
        ToastUtil.showSuccess('${m.year}年${m.month}月报告已生成');
      } else {
        ToastUtil.showError('该月无记账数据或已存在报告');
      }
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return FutureBuilder<List<_MonthItem>>(
      future: _monthsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final months = snapshot.data ?? [];
        if (months.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('当年暂无已完成的月份',
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          itemCount: months.length,
          separatorBuilder: (_, __) => Divider(height: 1,
              color: cs.outline.withValues(alpha: 0.08)),
          itemBuilder: (context, index) {
            final m = months[index];
            return _MonthRow(
              item: m,
              generating: _generating,
              onGenerate: () => _generate(m),
              onTap: m.generated ? () => _openReport(m.noteId!) : null,
            );
          },
        );
      },
    );
  }

  void _openReport(String noteId) async {
    final note = await DaoManager.noteDao.findById(noteId);
    if (note != null && mounted) {
      final vo = UserNoteVO.fromAccountNote(note, null);
      if (!mounted) return;
      // 从详情页返回后刷新状态
      await Navigator.pushNamed(context, AppRoutes.reportDetail, arguments: vo);
      _refresh();
    }
  }
}

class _MonthItem {
  final int year;
  final int month;
  bool generated;
  String? noteId;
  _MonthItem({required this.year, required this.month, this.generated = false, this.noteId});
}

class _MonthRow extends StatelessWidget {
  final _MonthItem item;
  final bool generating;
  final VoidCallback onGenerate;
  final VoidCallback? onTap;

  const _MonthRow({
    required this.item,
    required this.generating,
    required this.onGenerate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: item.generated ? cs.surface : cs.surfaceContainerLow.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: item.generated
              ? cs.outline.withValues(alpha: 0.1)
              : cs.outline.withValues(alpha: 0.05),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            // 月份
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: item.generated
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('${item.month}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: item.generated ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
              ),
            ),
            const SizedBox(width: 14),
            // 标题 + 状态
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.year}年${item.month}月',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(item.generated ? '已生成，点击查看' : '未生成',
                      style: TextStyle(fontSize: 12, color: item.generated ? cs.primary : cs.onSurfaceVariant)),
                ],
              ),
            ),
            if (item.generated)
              Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant)
            else
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: generating ? null : onGenerate,
                  icon: generating
                      ? SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add, size: 15),
                  label: Text(generating ? '生成中' : '生成',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
