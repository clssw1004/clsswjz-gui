import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/note_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/note_list.dart';
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
      // 只进行同步操作，刷新由事件总线统一处理
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BooksProvider>(context);
    final noteListProvider = Provider.of<NoteListProvider>(context);
    final l10n = L10nManager.l10n;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.tabNotes),
        showBackButton: false,
        centerTitle: false,
        actions: [
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
      ),
      body: Consumer2<NoteListProvider, SyncProvider>(
        builder: (context, noteListProvider, syncProvider, child) {
          return Stack(
            children: [
              CustomRefreshIndicator(
                onRefresh: _handleRefresh,
                builder: (context, child, controller) => child,
                child: NoteList(
                  accountBook: provider.selectedBook,
                  initialNotes: noteListProvider.notes,
                  loading: noteListProvider.loading,
                  hasMore: noteListProvider.hasMore,
                  onLoadMore: () => noteListProvider.loadMore(),
                  onDelete: noteListProvider.deleteNote,
                  onNoteTap: (note) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.noteEdit,
                      arguments: [note, provider.selectedBook],
                    ).then((updated) {
                      if (updated == true) {
                        noteListProvider.loadNotes();
                      }
                    });
                  },
                ),
              ),
              // 同步进度条
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.noteAdd,
            arguments: [provider.selectedBook],
          ).then((added) {
            if (added == true) {
              noteListProvider.loadNotes();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
