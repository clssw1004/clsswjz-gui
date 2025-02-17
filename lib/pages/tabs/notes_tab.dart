import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../enums/note_type.dart';
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

class _NotesTabState extends State<NotesTab>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _fabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NoteListProvider>();
      provider.loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
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

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _addTo(BuildContext context, NoteType type) {
    String route;
    switch (type) {
      case NoteType.debt:
        route = AppRoutes.debtAdd;
        break;
      case NoteType.todo:
        route = AppRoutes.todoAdd;
        break;
      case NoteType.note:
        route = AppRoutes.noteAdd;
        break;
    }
    final provider = Provider.of<BooksProvider>(context, listen: false);
    _toggleFab();
    Navigator.pushNamed(
      context,
      route,
      arguments: [provider.selectedBook, type],
    ).then((added) {
      if (added == true) {
        Provider.of<NoteListProvider>(context, listen: false).loadNotes();
      }
    });
  }

  Widget _buildFabItem(
    BuildContext context,
    NoteType type,
    IconData icon,
    String label,
    Animation<double> animation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          heroTag: type.code,
          elevation: 2,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          onPressed: () => _addTo(context, type),
          icon: Icon(icon, size: 20),
          label: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BooksProvider>(context);
    final l10n = L10nManager.l10n;
    final size = MediaQuery.of(context).size;

    final fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabExpanded) ...[
            _buildFabItem(
              context,
              NoteType.debt,
              Icons.account_balance_wallet_outlined,
              l10n.addNew(l10n.debt),
              fabScale,
            ),
            _buildFabItem(
              context,
              NoteType.todo,
              Icons.check_circle_outline,
              l10n.addNew(l10n.todo),
              fabScale,
            ),
            _buildFabItem(
              context,
              NoteType.note,
              Icons.note_outlined,
              l10n.addNew(l10n.note),
              fabScale,
            ),
          ],
          FloatingActionButton(
            onPressed: _toggleFab,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _isFabExpanded ? 0.125 : 0,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
