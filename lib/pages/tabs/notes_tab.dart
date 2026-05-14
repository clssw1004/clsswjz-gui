import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/note_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/note_list.dart';
import '../../widgets/book/note_group_filter.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../widgets/common/common_search_field.dart';
import '../../widgets/activity/activity_calendar_view.dart';

class NotesTab extends StatefulWidget {
  final ValueChanged<bool>? onActivityTabChanged;

  const NotesTab({super.key, this.onActivityTabChanged});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onActivityTabChanged?.call(_tabController.index == 1);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NoteListProvider>();
      provider.loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Widget _buildNotesView(BooksProvider booksProvider) {
    return Consumer2<NoteListProvider, SyncProvider>(
      builder: (context, noteListProvider, syncProvider, child) {
        return Column(
          children: [
            if (booksProvider.selectedBook != null)
              NoteGroupFilter(
                bookId: booksProvider.selectedBook!.id,
                selectedGroupCodes: noteListProvider.groupCodes,
                onGroupCodesChanged: _handleGroupFilterChanged,
              ),
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
                        Navigator.pushNamed(
                          context,
                          AppRoutes.noteEdit,
                          arguments: [note, booksProvider.selectedBook],
                        ).then((updated) {
                          if (updated == true) {
                            noteListProvider.loadNotes(true);
                          }
                        });
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final l10n = L10nManager.l10n;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.tabNotes),
        showBackButton: false,
        centerTitle: false,
        actions: [
          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CommonSearchField(
                width: size.width * 0.35,
                controller: _searchController,
                hintText: l10n.search,
                onSubmitted: (_) => _handleSearch(),
                onClear: _handleSearch,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.tabNotes),
            Tab(text: l10n.tabActivity),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesView(booksProvider),
          const ActivityCalendarView(),
        ],
      ),
    );
  }
}
