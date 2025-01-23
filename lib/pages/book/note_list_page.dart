import 'package:clsswjz/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_note_vo.dart';
import '../../providers/books_provider.dart';
import '../../providers/note_list_provider.dart';
import '../../widgets/common/common_app_bar.dart';

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.tabNotes),
      ),
      body: Consumer2<BooksProvider, NoteListProvider>(
        builder: (context, booksProvider, noteListProvider, child) {
          if (noteListProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noteListProvider.notes.length,
            itemBuilder: (context, index) {
              final note = noteListProvider.notes[index];
              return _NoteCard(note: note);
            },
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final UserNoteVO note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<BooksProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.noteEdit, arguments: [note, provider.selectedBook]);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 内容预览
              Text(
                note.content ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 日期
              Text(
                note.noteDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
