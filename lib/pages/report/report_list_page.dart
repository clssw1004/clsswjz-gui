import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/report_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/monthly_report_service.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../widgets/book/note_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_search_field.dart';
import '../../widgets/common/progress_indicator_bar.dart';

/// 报表列表页（从「工具」Tab 宫格进入）。
///
/// 展示所有月度收支报告（noteType='REPORT'），点击进入报表详情，
/// 底部附带缺失月份补生成入口。
class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportListProvider>().loadNotes();
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
    context.read<ReportListProvider>().setKeyword(_searchController.text);
  }

  Future<void> _generateReport(ReportListProvider provider, int year, int month) async {
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

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final spacing = Theme.of(context).spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.reportListTitle),
        centerTitle: false,
      ),
      body: Consumer2<ReportListProvider, SyncProvider>(
        builder: (context, reportListProvider, syncProvider, child) {
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
              // 报表列表
              Expanded(
                child: Stack(
                  children: [
                    CustomRefreshIndicator(
                      onRefresh: _handleRefresh,
                      builder: (context, child, controller) => child,
                      child: NoteList(
                        accountBook: booksProvider.selectedBook,
                        initialNotes: reportListProvider.reports,
                        loading: reportListProvider.loading,
                        hasMore: reportListProvider.hasMore,
                        onLoadMore: () => reportListProvider.loadMore(),
                        onDelete: reportListProvider.deleteReport,
                        onNoteTap: (note) {
                          Navigator.pushNamed(
                            context, AppRoutes.reportDetail,
                            arguments: note,
                          ).then((_) => reportListProvider.loadNotes(true));
                        },
                        footerItems: reportListProvider.missingMonths
                            .map((m) => _MissingMonthCard(
                              year: m.year,
                              month: m.month,
                              cs: Theme.of(context).colorScheme,
                              onGenerate: () =>
                                  _generateReport(reportListProvider, m.year, m.month),
                            ))
                            .toList(),
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
